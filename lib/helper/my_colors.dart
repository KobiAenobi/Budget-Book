import 'package:flutter/material.dart';

class MyAppColors {
  // ----------------------------
  // GENERAL / BACKGROUNDS
  // ----------------------------
  // used for the very back-most container in Homescreen
  // static const Color background = Color.fromARGB(255, 145, 107, 86);
  static const Color background = const Color.fromRGBO(255, 109, 31, 1.000);

  // scaffold background used inside the Scaffold
  static const Color scaffoldBackground = Color.fromRGBO(250, 243, 225, 1.0);

  // shadow used for Material elevation in various places
  static const Color shadowColor = Color.fromARGB(255, 71, 71, 71);

  // ----------------------------
  // TEXT
  // ----------------------------
  static const Color textPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color textSecondary = Color.fromARGB(136, 0, 0, 0);
  static const Color textAccent = Color(0xFFE84545);

  // ----------------------------
  // ICONS
  // ----------------------------
  static const Color iconPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color iconOnDark = Colors.white70;

  // ----------------------------
  // CARDS / BORDERS
  // ----------------------------
  static const Color cardBackground = Color.fromRGBO(245, 231, 198, 1.000);
  static const Color cardShadow = Colors.black38;
  static const Color borderColor = Color.fromRGBO(177, 177, 177, 1);

  // ----------------------------
  // APP BAR
  // ----------------------------
  static const Color appBarBackground = Color.fromRGBO(245, 231, 198, 1.000);

  // ----------------------------
  // SLIDABLE / ACTION BUTTONS
  // ----------------------------
  static const Color editButtonBackground = Color.fromARGB(255, 44, 16, 16);
  static const Color editButtonText = Colors.white;

  static const Color deleteButtonBackground = Color.fromARGB(255, 44, 16, 16);
  static const Color deleteButtonText = Colors.white;

  // ----------------------------
  // FAB
  // ----------------------------
  static const Color fabBackground = Color.fromARGB(255, 0, 201, 104);
  static const Color fabIconColor = Colors.white;

  // ----------------------------
  // DARK THEME (optional values if you plan to use)
  // ----------------------------
  static const Color darkBackground = Color.fromARGB(255, 129, 58, 0);
  static const Color darkScaffoldBackground = Color.fromARGB(255, 70, 31, 0);

  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  static const Color darkIconPrimary = Colors.white;
  static const Color darkCardBackground = Color.fromARGB(255, 49, 25, 11);
  static const Color darkCardShadow = Colors.black87;
  static const Color darkAppBarBackground = Color.fromARGB(255, 49, 25, 11);
}
