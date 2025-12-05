import 'dart:developer' show log;

import 'package:budget_book_app/widgets/account_settings_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ============================================================================
/// 🌟 customAppBar — Reusable AppBar Widget
/// ----------------------------------------------------------------------------
/// This widget allows you to:
///   • Set a title
///   • Provide a list of PopupMenu entries
///   • Handle onSelected menu callbacks
///
/// It implements PreferredSizeWidget → required for use as an AppBar.
/// NOTHING in the logic or structure has been modified.
/// ============================================================================
class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text shown in the center/left of the AppBar
  final String title;

  

  /// List of popup menu entries (PopupMenuItem, CheckedPopupMenuItem, etc.)
  // final List<PopupMenuEntry<String>> menuItems;

  /// Callback triggered when a popup menu option is tapped
  final void Function(String)? onSelected;

  const customAppBar({
    super.key,
    required this.title,
    // required this.menuItems,
    this.onSelected,
  });

  /// ---------------------------------------------------------------------------
  /// preferredSize
  ///
  /// Required when creating a custom AppBar widget; without this,
  /// Flutter doesn't know how tall your AppBar should be.
  /// kToolbarHeight = default height of a Material AppBar.
  /// ---------------------------------------------------------------------------
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// ---------------------------------------------------------------------------
  /// BUILD METHOD — Returns a normal AppBar with:
  ///   • Custom icon color
  ///   • Custom title text color
  ///   • Popup menu on the right
  /// ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // final user=FirebaseAuth.instance.currentUser;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return AppBar(
          iconTheme: const IconThemeData(color: Colors.white70),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                log("\nphoto url: ${user?.photoURL}");
                AccountSettingsDialog().showAccountSettingDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );

  }
}
