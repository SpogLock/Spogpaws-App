import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';

class CheckboxPressedCubit extends Cubit<bool> {
  CheckboxPressedCubit() : super(false);

  void press() => emit(true);
  void release() => emit(false);
}

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final borderColor = _darken(AppColors.black, 0.25);
    final bgColor = AppColors.white;

    return BlocProvider(
      create: (_) => CheckboxPressedCubit(),
      child: BlocBuilder<CheckboxPressedCubit, bool>(
        builder: (context, isPressed) {
          final notifier = context.read<CheckboxPressedCubit>();

          return GestureDetector(
            onTapDown: (_) => notifier.press(),
            onTapUp: (_) => notifier.release(),
            onTapCancel: notifier.release,
            onTap: () => onChanged(!value),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 40),
                  transform: Matrix4.translationValues(
                    isPressed ? 1 : 0,
                    isPressed ? 1 : 0,
                    0,
                  ),
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: borderColor),
                    boxShadow: isPressed
                        ? []
                        : [
                            BoxShadow(
                              color: borderColor,
                              offset: const Offset(1, 1),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: value
                      ? Icon(Icons.check, size: 13, color: AppColors.black)
                      : null,
                ),
                if (label != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label!,
                      style: AppFonts.nunitoRegular().copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
