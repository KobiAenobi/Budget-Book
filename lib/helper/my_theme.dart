import 'package:flutter/material.dart';

class MyAppTheme {
  // static Color scaffoldBackgroundColorSecondaryLight = Color.fromRGBO(
  //   255,
  //   109,
  //   31,
  //   1.0,
  // );
  // ---------------- LIGHT THEME ----------------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    // GLOBAL BACKGROUND COLORS
    scaffoldBackgroundColor: Color.fromRGBO(209, 199, 191, 1),
    // scaffoldBackgroundColor: Color.fromRGBO(255, 166, 25, 1.000),

    //MOSTLY FOR TEXT
    colorScheme: const ColorScheme.light(
      surface: Color.fromRGBO(255, 109, 31, 1.0),
      primary: Color.fromARGB(255, 0, 0, 0),
      secondary: Color.fromARGB(255, 80, 80, 80),
      onPrimary: Color.fromARGB(255, 0, 0, 0),
    ),

    // GLOBAL TEXT COLORS
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      bodySmall: TextStyle(color: Color.fromARGB(136, 0, 0, 0)),
      titleLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleSmall: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    ),

    // ICON COLORS
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),

    // CARD THEME
    cardColor: Color.fromRGBO(231, 222, 190, 1),
    // cardColor: Color.fromRGBO(201, 181, 156, 1.000),
    shadowColor: const Color.fromARGB(96, 71, 71, 71),

    dividerColor: Color.fromRGBO(65, 65, 65, 1),

    // APPBAR THEME
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(245, 231, 198, 1.0),
      foregroundColor: Color.fromARGB(255, 0, 0, 0),
      elevation: 0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 19, 173, 99),
      foregroundColor: Colors.black,
    ),
  );

  // static Color scaffoldBackgroundColorSecondaryDark = Color.fromRGBO(
  //   255,
  //   109,
  //   31,
  //   1.0,
  // );

  // ---------------- DARK THEME ----------------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    // GLOBAL BACKGROUND COLORS

    // GLOBAL BACKGROUND COLORS
    scaffoldBackgroundColor: Color.fromRGBO(209, 199, 191, 1),
    // scaffoldBackgroundColor: Color.fromRGBO(255, 166, 25, 1.000),

    //MOSTLY FOR TEXT
    colorScheme: const ColorScheme.dark(
      surface: Color.fromRGBO(255, 109, 31, 1.0),
      primary: Color.fromARGB(255, 0, 0, 0),
      secondary: Color.fromARGB(255, 80, 80, 80),
      onPrimary: Color.fromARGB(255, 0, 0, 0),
    ),

    // GLOBAL TEXT COLORS
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      bodySmall: TextStyle(color: Color.fromARGB(136, 0, 0, 0)),
      titleLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleSmall: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    ),

    // ICON COLORS
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 80, 80, 80)),

    // CARD THEME
    cardColor: Color.fromRGBO(231, 222, 190, 1),
    // cardColor: Color.fromRGBO(201, 181, 156, 1.000),
    shadowColor: const Color.fromARGB(96, 71, 71, 71),

    dividerColor: Color.fromRGBO(65, 65, 65, 1),

    // APPBAR THEME
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(245, 231, 198, 1.0),
      foregroundColor: Color.fromARGB(255, 0, 0, 0),
      elevation: 0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 19, 173, 99),
      foregroundColor: Colors.black,
    ),
  );
}
