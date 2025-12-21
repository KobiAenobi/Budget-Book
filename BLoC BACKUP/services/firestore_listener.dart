import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/budget_item.dart';

void startRemoteListener() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final box = Hive.box<BudgetItem>('itemsBox');

  FirebaseFirestore.instance
      .collection('users_BLoC')
      .doc(uid)
      .collection('budgets')
      .snapshots()
      .listen((snapshot) {

    // 1. Convert all remote docs to BudgetItem objects
    final remoteItems = snapshot.docs
        .map((d) => BudgetItem.fromMap(d.data()))
        .toList();

    // 2. Write updates to Hive
    for (var remote in remoteItems) {
      final local = box.get(remote.id);

      // If new or updated
      if (local == null || remote.dateTime.isAfter(local.dateTime)) {
        box.put(remote.id, remote);
      }
    }

    // 3. Detect remote-deleted items
    final remoteIds = remoteItems.map((e) => e.id).toSet();

    for (var localItem in box.values.toList()) {
      if (!remoteIds.contains(localItem.id)) {
        // Remote deleted → delete locally
        box.delete(localItem.id);
      }
    }
  });
}
