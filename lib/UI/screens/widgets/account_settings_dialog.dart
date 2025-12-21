import 'dart:developer' show log;

import 'package:budget_book_app/UI/helper/api.dart';
import 'package:budget_book_app/UI/screens/homeScreen.dart';
import 'package:budget_book_app/UI/screens/permissions_screen.dart';
import 'package:budget_book_app/blocs/budgets/budget_bloc.dart';
import 'package:budget_book_app/blocs/budgets/budget_event.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountSettingsDialog {
  final currUser = FirebaseAuth.instance.currentUser;

  // static ChatUser me;
  void showAccountSettingDialog(BuildContext context) {
    final myThemeVar = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: const Color.fromARGB(135, 0, 0, 0),
      builder: (context) {
        return Dialog(
          backgroundColor: myThemeVar.cardColor,
          insetPadding: EdgeInsets.only(top: 60, right: 10),
          alignment: Alignment.topRight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            child: Container(
              // color: Colors.amber,
              width: 320,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== MAIN ACCOUNT HEADER =====
                  FittedBox(
                    child: Container(
                      // color: Colors.amberAccent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(7),
                        onTap: () {
                          log("user name clicked");
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,

                              // backgroundImage:NetworkImage(currUser!.photoURL.toString()),
                              // child:Icon(Icons.person),
                              backgroundImage: currUser?.photoURL != null
                                  ? NetworkImage(currUser!.photoURL!)
                                  : null,
                              child: currUser?.photoURL == null
                                  ? Icon(
                                      Icons.person,
                                      color: myThemeVar.iconTheme.color,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currUser?.displayName ?? "Guest",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: myThemeVar.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  currUser?.email ?? "guest",
                                  style: TextStyle(
                                    color: myThemeVar.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Divider(),

                  // ===== MANAGE =====
                  InkWell(
                    borderRadius: BorderRadius.circular(7),
                    onTap: () {
                      final budgetBloc = context
                          .read<BudgetBloc>(); // ✅ capture once

                      Navigator.pop(context); // close dialog safely

                      // handleLoginButtonClick(budgetBloc); // ✅ correct argument
                      budgetBloc.add(SignInToGoogleRequested());
                      log("Manage account");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Manage your Google Account",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Divider(),

                  // ===== Settings Tiles =====
                  otherTile(
                    "Budget Book Settings",
                    Icons.settings,
                    context,
                    PermissionsScreen(),
                  ),

                  // SizedBox(height: 16),
                  Divider(),

                  Row(
                    children: [
                      // ===== SIGN OUT =====
                      Flexible(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(7),
                          onTap: () {
                            context.read<BudgetBloc>().add(SignOutRequested());
                            // try {
                            //   signOut();
                            //   if (FirebaseAuth.instance.currentUser == null) {
                            //     Api.showAppSnack("Already Logged out");
                            //   } else {
                            //     Api.showAppSnack("Logged Out");
                            //   }
                            // } catch (e) {
                            //   Api.showAppSnack("error: $e");
                            // }

                            // signOut();

                            Navigator.pop(context);
                            log("Sign out Clicked");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              // width: double.infinity,
                              child: Text(
                                "Sign out",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10),
                      // ===== Sync =====
                      Flexible(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(7),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  icon: const Icon(Icons.warning_amber_rounded),
                                  title: const Text('Sync data?'),
                                  content: const Text(
                                    'This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Sync'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == true) {
                              Navigator.pop(context);
                              // ✅ DO YOUR ACTION HERE
                              // syncLocalItemsToCloud();
                              // migrateKeysToId();

                              // try {
                              //   await syncLocalItemsToCloud();
                              //   Api.showAppSnack("Data Synced");
                              // } catch (e) {
                              //   Api.showAppSnack("Error: $e");
                              // }

                              try {
                                context.read<BudgetBloc>().add(
                                  CloudSyncRequested(),
                                );
                                Api.showAppSnack("Data Synced");
                              } catch (e) {
                                Api.showAppSnack("Error: $e");
                              }

                              // close AccountSettingsDialog AFTER confirm
                              log("Sync confirmed");
                            } else {
                              log("Sync cancelled");
                            }
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              // width: double.infinity,
                              child: Text(
                                "Sync Data",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget otherTile(String name, IconData Iconss, BuildContext context, screen) {
  final myThemeVar = Theme.of(context);
  return InkWell(
    borderRadius: BorderRadius.circular(7),
    onTap: () {
      log("Switched to");
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    },
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Iconss, color: myThemeVar.iconTheme.color),
          SizedBox(width: 14),
          Text(
            name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

/// --------------------- Login Logic ---------------------
void handleLoginButtonClick(BudgetBloc budgetBloc) {
  budgetBloc.add(SignInToGoogleRequested());
}

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

// Future<void> signOut() async {
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn.instance.signOut();
//   await GoogleSignIn.instance.disconnect();
// }

// Future<void> migrateKeysToId() async {
//   final box = Hive.box<BudgetItem>('itemsBox');

//   final oldKeys = <dynamic>[];

//   for (var key in box.keys) {
//     final item = box.get(key);
//     if (item == null) continue;

//     // If the key is NOT the item.id, migrate it
//     if (key != item.id) {
//       await box.put(item.id, item);
//       oldKeys.add(key);
//     }
//   }

//   for (var k in oldKeys) {
//     await box.delete(k);
//   }
// }
