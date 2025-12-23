import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppTheme {
  // ---------------- LIGHT THEME (UNCHANGED) ----------------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    useMaterial3: true,

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      backgroundColor: const Color(0xFFCDCDCD), // Inverted from 0xFF323232
      contentTextStyle: const TextStyle(
        color: Colors.black, // Inverted from White
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actionTextColor: Colors.deepOrange,
      showCloseIcon: true,
      closeIconColor: Colors.black54,
    ),

    // scaffoldBackgroundColor: const Color.fromRGBO(209, 199, 191, 1),
    scaffoldBackgroundColor: const Color.fromARGB(255, 194, 185, 154),

    colorScheme: const ColorScheme.light(
      surface: Color.fromRGBO(209, 199, 191, 1),
      primary: Colors.black,
      secondary: Color.fromARGB(180, 80, 80, 80),
      onPrimary: Color.fromARGB(255, 255, 255, 255),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
      bodySmall: TextStyle(color: Color.fromARGB(136, 0, 0, 0), fontSize: 11),
      titleLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleMedium: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      titleSmall: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    ),

    iconTheme: const IconThemeData(color: Color.fromARGB(255, 80, 80, 80)),

    // cardColor: const Color.fromRGBO(231, 222, 190, 1),
    cardColor: const Color.fromARGB(255, 216, 207, 175),
    shadowColor: const Color.fromARGB(96, 71, 71, 71),
    dividerColor: const Color.fromRGBO(65, 65, 65, 1),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(245, 231, 198, 1.0),
      foregroundColor: Color.fromARGB(255, 0, 0, 0),
      elevation: 0,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 19, 173, 99),
      foregroundColor: Colors.black,
    ),
  );

  // ---------------- DARK THEME (EXACT OPPOSITE) ----------------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    // SNACKBAR
    // Inverted: Light background with Dark text
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      backgroundColor: const Color.fromARGB(255, 78, 76, 76),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actionTextColor: Colors.orange,
      showCloseIcon: true,
      closeIconColor: Colors.white70,
    ),

    // GLOBAL BACKGROUND COLORS
    // Mathematically inverted: 255 - LightValue
    // R:255-209=46, G:255-199=56, B:255-191=64
    scaffoldBackgroundColor:  Color.fromRGBO(44,16,16,1.000),

    // COLOR SCHEME
    colorScheme: const ColorScheme.dark(
      surface: Color.fromRGBO(46, 56, 64, 1), // Slate Blue
      primary: Colors.white, // Opposite of Black
      secondary: Color.fromARGB(255, 155, 155, 155), // Opposite of 80,80,80
      onPrimary: Colors.black, // Text on primary
      onSurface: Colors.white,
    ),

    // TEXT THEME
    // All text inverted to Pure White (255, 255, 255)
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 24),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
      bodySmall: TextStyle(
        color: Color.fromARGB(180, 255, 255, 255),
        fontSize: 11,
      ),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
    ),

    // ICON COLORS
    // Inverted from Dark Grey to Light Grey
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 175, 175, 175)),

    // CARD THEME
    // Inverted from Cream (231, 222, 190) to Dark Blue (24, 33, 65)
    cardColor:  Color.fromRGBO(24,8,2,1.000),
    shadowColor: const Color.fromARGB(255, 58, 58, 58),

    dividerColor: const Color.fromARGB(
      172,
      190,
      190,
      190,
    ), // Inverted from 65,65,65
    // APPBAR THEME
    // Inverted from Pale Yellow (245, 231, 198) to Deep Midnight (10, 24, 57)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(10, 24, 57, 1.0),
      foregroundColor: Colors.white, // Inverted from Black
      elevation: 0,
    ),

    // FAB
    // Keeping Green for brand consistency, but using White icon for contrast
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 19, 173, 99),
      foregroundColor: Colors.white,
    ),
  );
}
