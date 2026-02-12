import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';

class AppStyle {
  static const double radiusMd = 10;

  static const Color surface = AppColors.white;
  static const Color surfaceMuted = Color(0xFFF8FAFF);
  static const Color outline = Color(0xFFE6EAF0);
  static const Color outlineStrong = AppColors.black;
  static const Color shadowSoft = Color(0x12000000);

  // Dashboard accents (non-black border/shadow palette).
  static const Color dashboardHeroBorder = Color(0xFF6B8FCB);
  static const Color dashboardHeroShadow = Color(0x336B8FCB);
  static const Color dashboardSectionBorder = Color(0xFF7A78B8);
  static const Color dashboardSectionShadow = Color(0x334F378A);
  static const Color dashboardTipBorder = Color(0xFFD89E2C);
  static const Color dashboardTipShadow = Color(0x33D89E2C);
  static const Color dashboardTileBorder = Color(0xFFD6E4FA);

  // Clinic accents.
  static const Color clinicCardBorder = Color(0xFF4B8F9D);
  static const Color clinicCardShadow = Color(0x334B8F9D);
  static const Color clinicStateBorder = Color(0xFF6D87B4);
  static const Color clinicStateShadow = Color(0x336D87B4);
  static const Color clinicDetailBorder = Color(0xFF3E8292);
  static const Color clinicDetailShadow = Color(0x333E8292);

  static BorderRadius radius(double value) => BorderRadius.circular(value);

  static BoxDecoration outlinedSurface({
    Color background = surface,
    Color borderColor = outline,
    double radiusValue = 16,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: radius(radiusValue),
      border: Border.all(color: borderColor),
      boxShadow: withShadow
          ? const [
              BoxShadow(
                color: shadowSoft,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ]
          : null,
    );
  }

  static Color pressDepthColor(Color color, {double amount = 0.25}) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
