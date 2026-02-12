import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/widgets/app_pressable.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.backgroundColor, this.onTap});

  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? AppColors.white;
    final Color borderColor = AppStyle.outlineStrong;
    final Color iconColor = _isDark(bg)
        ? AppColors.white
        : AppStyle.pressDepthColor(borderColor, amount: 0.10);

    return AppPressable(
      onTap: () {
        if (onTap != null) {
          onTap!.call();
          return;
        }
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
      backgroundColor: bg,
      borderColor: borderColor,
      radius: AppStyle.radiusMd,
      depth: 1,
      height: 30,
      width: 30,
      child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 15),
    );
  }

  bool _isDark(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
  }
}
