import 'dart:async';
import 'dart:developer' show Service, log;

import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetRepository {
  final Box<BudgetItem> box;
  final Box settingsBox;
  FirebaseFirestore? _db;
  String? _uid;

  StreamSubscription? _remoteSub;
  StreamSubscription? _localSub;

  BudgetRepository(this.box, this.settingsBox);

  //Read the Items from box and return it
  List<BudgetItem> getAllItems() {
    return box.values.toList();
  }

  //Add items
  Future<void> addItems(BudgetItem item) async {
    await box.put(item.id, item);
    log('from budget_repository.dart: Saved item to HIVE: ${item.id}');

    // if (_db == null || _uid == null) {
    //   log(
    //     "from budget_repository.dart: ❌ Firebase NOT READY — skipping upload",
    //   );
    //   return;
    // }

    try {
      if (_db != null && _uid != null) {
        await uploadItem(item);
        log(
          'from budget_repository.dart: Uploaded item ${item.id} to Firestore',
        );
      }
    } catch (e) {
      log('from budget_repository.dart: Failed upload: $e');
    }
  }

  //update item
  Future<void> updateItem(BudgetItem updatedItem) async {
    await box.put(updatedItem.id, updatedItem);
  }

  //delete item
  Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  Future<void> setBudget(int newBudget) async {
    await settingsBox.put('monthlyBudget', newBudget);
  }
  int get monthlyBudget =>
    settingsBox.get('monthlyBudget', defaultValue: 0) as int;


  Future<void> currentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _uid = user.uid;
    _db = FirebaseFirestore.instance;

    // await initialSync();
    // await syncLocalItemsToCloud();
    // _startRemoteListener();
    // _listenForLocalChanges();

    log("from budget_repository.dart: user data for user $_uid");
  }

  //upload item to fire base
  CollectionReference<Map<String, dynamic>> get _budgets =>
      _db!.collection('users_BLoC').doc(_uid).collection('budgets');
  Future<void> uploadItem(BudgetItem item) async {
    await _budgets.doc(item.id).set(item.toMap(), SetOptions(merge: true));
  }

  /// Google Signin
  Future<UserCredential?> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      // if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('\nCANCELLED LOGIN');
      // Dialogs.showSnackbar(context, 'Something went wrong! Try again...');
      return null;
    }
  }

  // ============================================================
  // SYNC LOGIC (YOUR ORIGINAL LOGIC)
  // ============================================================

  Future<void> initialSync() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;

    final box = Hive.box<BudgetItem>('itemsBox');

    final snap = await db
        .collection('users_BLoC')
        .doc(uid)
        .collection('budgets')
        .get();

    for (var doc in snap.docs) {
      final data = doc.data();
      final item = BudgetItem.fromMap(data);
      final local = box.get(item.id);

      if (local == null || item.dateTime.isAfter(local.dateTime)) {
        box.put(item.id, item);
      }
    }
  }

  Future<void> syncLocalItemsToCloud() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    final box = Hive.box<BudgetItem>('itemsBox');

    // 1. Get cloud items
    final remoteSnap = await db
        .collection('users_BLoC')
        .doc(uid)
        .collection('budgets')
        .get();

    final remoteIds = remoteSnap.docs.map((d) => d.id).toSet();

    // 2. Upload all local items that are missing in Cloud
    for (var localItem in box.values) {
      if (!remoteIds.contains(localItem.id)) {
        await db
            .collection('users_BLoC')
            .doc(uid)
            .collection('budgets')
            .doc(localItem.id)
            .set(localItem.toMap());

        log(
          "from budget_repository.dart: Uploaded missing local item: ${localItem.id}",
        );
      }
    }
  }

  Future<void> startSync() async {
    if (_db == null || _uid == null) {
      log(
        "from budget_repository.dart: ⚠️ startSync skipped — Firebase not ready",
      );
      return;
    }
    // startRemoteListener();
    _listenForLocalChanges();
    _startRemoteListener();

    log("from budget_repository.dart: ✅ Firebase sync ACTIVE");
  }

  void _listenForLocalChanges() {
    _localSub?.cancel();

    _localSub = box.watch().listen((event) async {
      if (_uid == null || _db == null) return;

      final docRef = _db!
          .collection('users_BLoC')
          .doc(_uid)
          .collection('budgets')
          .doc(event.key);

      // 🔥 HANDLE DELETE
      if (event.deleted) {
        await docRef.delete();
        log(
          "from budget_repository.dart: 🗑 Local → cloud delete: ${event.key}",
        );
        return;
      }

      // 🔥 HANDLE ADD / UPDATE
      final item = box.get(event.key);
      if (item == null) return;

      await docRef.set(item.toMap(), SetOptions(merge: true));
      log("from budget_repository.dart: 🔥 Local → cloud sync: ${item.id}");
    });

    log("from budget_repository.dart: 📦 Local listener started");
  }

  void _startRemoteListener() {
    _remoteSub?.cancel(); // safety

    if (_db == null || _uid == null) return;

    _remoteSub = _db!
        .collection('users_BLoC')
        .doc(_uid)
        .collection('budgets')
        .snapshots()
        .listen((snapshot) {
          final remoteItems = snapshot.docs
              .map((d) => BudgetItem.fromMap(d.data()))
              .toList();

          for (final remote in remoteItems) {
            final local = box.get(remote.id);
            if (local == null || remote.dateTime.isAfter(local.dateTime)) {
              box.put(remote.id, remote);
              log(
                "from budget_repository.dart: 🔥 cloud → Local sync: ${remote.id}",
              );
            }
          }

          final remoteIds = remoteItems.map((e) => e.id).toSet();
          for (final localItem in box.values.toList()) {
            if (!remoteIds.contains(localItem.id)) {
              box.delete(localItem.id);
            }
          }
        });

    log("from budget_repository.dart: 📡 Remote listener started");
  }

  Future<void> stopSync() async {
    log("from budget_repository.dart: 🛑 Stopping Firebase sync");

    await _remoteSub?.cancel();
    await _localSub?.cancel();

    _remoteSub = null;
    _localSub = null;

    _db = null;
    _uid = null;

    log("from budget_repository.dart: 🛑 Firebase sync STOPPED");
  }

  

  // Future<void> disableCloudSync() async {
  //   log("from budget_repository.dart: ☁️ Disabling cloud sync...");

  //   await _remoteSub?.cancel();
  //   await _localSub?.cancel();

  //   _remoteSub = null;
  //   _localSub = null;
  //   _db = null;
  //   _uid = null;

  //   log("from budget_repository.dart: ☁️ Cloud sync DISABLED");
  // }
}
