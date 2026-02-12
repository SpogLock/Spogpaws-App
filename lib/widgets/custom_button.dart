import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/widgets/app_pressable.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.isLoading = false,
    this.icon,
    this.iconSize = 16,
  });

  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool isLoading;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? AppColors.primary;
    final Color borderColor = AppStyle.pressDepthColor(bg, amount: 0.25);
    final Color textColor = _isDark(bg)
        ? Colors.white
        : AppStyle.pressDepthColor(borderColor, amount: 0.10);
    final bool isEnabled = onTap != null && !isLoading;

    return AppPressable(
      onTap: isEnabled ? onTap : null,
      enabled: isEnabled,
      backgroundColor: bg,
      borderColor: borderColor,
      radius: AppStyle.radiusMd,
      depth: 2,
      height: 45,
      child: Center(
        child: isLoading
            ? SpinKitThreeBounce(color: textColor, size: 12)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize, color: textColor),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: AppFonts.poppinsMedium().copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  // ---------- Helpers ----------
  bool _isDark(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
  }
}
