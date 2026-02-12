import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/widgets/app_pressable.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPress;
  final bool includeDivider;

  const CustomAppBar({
    super.key,
    this.includeDivider = false,
    required this.title,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back Button on the left
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppPressable(
                    onTap: onBackPress ?? () => Navigator.maybePop(context),
                    backgroundColor: AppColors.white,
                    borderColor: AppStyle.outlineStrong,
                    radius: 30,
                    depth: 1,
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                  ),
                ),

                // Centered Bold Title
                Text(
                  title,
                  style: AppFonts.nunitoBold(
                    fontSize: 20,
                  ).copyWith(color: AppColors.black, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          // Subtle divider line as seen in your screenshot flow
          if (includeDivider)
            Divider(height: 1, color: Colors.grey.shade100, thickness: 1),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
