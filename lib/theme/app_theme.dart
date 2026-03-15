import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightBg2 = Color(0xFFEDEDED);
  static const Color lightBg3 = Color(0xFFF5F5F5);
  static const Color lightAccent = Color(0xFF847E75);
  static const Color lightButtonBg = Color(0xFFA0B8FF);
  static const Color lightButtonText = Color(0xFFF5F5F5);

  // Dark theme colors
  static const Color darkBg = Color(0xFF000000);
  static const Color darkBg2 = Color(0xFF0A0A0A);
  static const Color darkBg3 = Color(0xFF121212);
  static const Color darkAccent = Color(0xFF7B818A);
  static const Color darkButtonBg = Color(0xFFA0B8FF);
  static const Color darkButtonText = Color(0xFF30374C);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: darkBg),
      titleTextStyle: const TextStyle(
        color: darkBg,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightButtonBg,
        foregroundColor: lightButtonText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightButtonBg,
      foregroundColor: lightButtonText,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBg2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBg2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightButtonBg, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkBg, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: darkBg, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: darkBg, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkBg),
      bodyMedium: TextStyle(color: lightAccent),
    ),
    colorScheme: const ColorScheme.light(
      primary: lightButtonBg,
      secondary: lightBg2,
      surface: lightBg,
      error: Color(0xFFFF6B6B),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg2,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      titleTextStyle: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkButtonBg,
        foregroundColor: darkButtonText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkButtonBg,
      foregroundColor: darkButtonText,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkBg3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkAccent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkButtonBg, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: darkAccent),
    ),
    colorScheme: const ColorScheme.dark(
      primary: darkButtonBg,
      secondary: darkBg3,
      surface: darkBg2,
      error: Color(0xFFFF6B6B),
    ),
  );
}
