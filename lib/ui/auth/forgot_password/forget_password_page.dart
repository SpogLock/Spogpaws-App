import 'package:flutter/material.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/ui/auth/forgot_password/reset_password_page.dart';
import 'package:spogpaws/widgets/custom_appbar.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:spogpaws/widgets/custom_textfield.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ""),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomButton(
          text: "Send Reset Link",
          onTap: () {
            NavigatorHelper.push(context, ResetPasswordPage());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Image.asset(AppImages.forgotSticker, width: 220),
            const SizedBox(height: 40),
            Text("Forgot Password?", style: AppFonts.nunitoBold(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              "Enter your registered email to reset your password.",
              textAlign: TextAlign.center,
              style: AppFonts.nunitoRegular(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Email", style: AppFonts.nunitoMedium()),
            ),
            CustomTextField(
              hintText: "you@example.com",
              controller: TextEditingController(),
            ),
          ],
        ),
      ),
    );
  }
}
