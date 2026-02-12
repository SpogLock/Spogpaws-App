import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';

class CustomOtpField extends StatelessWidget {
  const CustomOtpField({super.key, required this.onCompleted, this.onChanged});

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final baseBorderColor = _darken(AppColors.black, 0.25);

    return OtpTextField(
      numberOfFields: 5,
      fieldWidth: 45,
      margin: const EdgeInsets.symmetric(horizontal: 6),

      /// Behavior
      showFieldAsBox: true,
      keyboardType: TextInputType.number,
      autoFocus: true,

      /// Styling
      filled: true,
      fillColor: AppColors.white,
      borderRadius: BorderRadius.circular(8),

      borderColor: baseBorderColor,
      enabledBorderColor: baseBorderColor,
      focusedBorderColor: AppColors.secondary,

      /// Text
      textStyle: AppFonts.nunitoRegular().copyWith(
        fontSize: 18,
        color: AppColors.black,
      ),

      /// Callbacks
      onCodeChanged: onChanged,
      onSubmit: onCompleted,
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
