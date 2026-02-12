import 'package:flutter/material.dart';

class AppFonts {
  // ===== Font Families =====
  static const String poppins = 'Poppins';
  static const String nunito = 'Nunito';

  // ===== Poppins =====
  static TextStyle poppinsRegular({
    double fontSize = 12,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: poppins,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: color,
      height: height,
    );
  }

  static TextStyle poppinsMedium({
    double fontSize = 12,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: poppins,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      color: color,
      height: height,
    );
  }

  static TextStyle poppinsSemiBold({
    double fontSize = 16,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: poppins,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: color,
      height: height,
    );
  }

  static TextStyle poppinsBold({
    double fontSize = 16,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: poppins,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      color: color,
      height: height,
    );
  }

  // ===== Nunito =====
  static TextStyle nunitoRegular({
    double fontSize = 12,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: nunito,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle nunitoMedium({
    double fontSize = 12,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: nunito,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle nunitoSemiBold({
    double fontSize = 16,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: nunito,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle nunitoBold({
    double fontSize = 16,
    Color color = Colors.black,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: nunito,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }
}
