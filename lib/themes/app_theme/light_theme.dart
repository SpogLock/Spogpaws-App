import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';

class LightTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.secondary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.secondary,
      primary: AppColors.secondary,
      secondary: AppColors.primary,
      surface: AppColors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14),
    ),

    cardTheme: const CardThemeData(
      color: AppStyle.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppStyle.outline),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppStyle.radius(AppStyle.radiusMd),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        textStyle: AppFonts.nunitoSemiBold(fontSize: 12),
        side: const BorderSide(color: AppStyle.outlineStrong),
        shape: RoundedRectangleBorder(
          borderRadius: AppStyle.radius(AppStyle.radiusMd),
        ),
        backgroundColor: AppStyle.surface,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondary,
        textStyle: AppFonts.nunitoSemiBold(fontSize: 12),
      ),
    ),
  );
}
