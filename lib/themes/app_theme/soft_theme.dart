import 'package:flutter/material.dart';

class SoftTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F2FA),
    primaryColor: const Color(0xFF7B61FF),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0EDFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7B61FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
