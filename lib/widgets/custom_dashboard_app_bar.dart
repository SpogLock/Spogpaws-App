import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/widgets/app_pressable.dart';

class CustomDashboardAppBar extends StatelessWidget {
  const CustomDashboardAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showFilterButton = false,
    this.onBackTap,
    this.onFilterTap,
  });

  final String title;
  final bool showBackButton;
  final bool showFilterButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    const depth = 4.0;
    const barHeight = 58.0;
    return SizedBox(
      height: barHeight + depth,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: depth,
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppStyle.outlineStrong),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppStyle.outlineStrong),
              ),
              child: Row(
                children: [
                  if (showBackButton)
                    _ActionButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: onBackTap ?? () => Navigator.maybePop(context),
                    ),
                  if (showBackButton) const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.nunitoBold(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showFilterButton) ...[
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.tune_rounded,
                      onTap: onFilterTap,
                      isPrimary: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.icon, this.onTap, this.isPrimary = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    return AppPressable(
      onTap: widget.onTap,
      enabled: isEnabled,
      backgroundColor: !isEnabled
          ? AppColors.lightGrey
          : widget.isPrimary
          ? AppColors.primary
          : const Color(0xFFF7F8FA),
      borderColor: AppStyle.outlineStrong,
      radius: 13,
      depth: 2,
      height: 42,
      width: 42,
      child: Icon(
        widget.icon,
        size: 19,
        color: isEnabled ? AppColors.secondary : AppColors.grey,
      ),
    );
  }
}
