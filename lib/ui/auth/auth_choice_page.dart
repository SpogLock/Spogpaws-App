import 'package:flutter/material.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/ui/auth/login/login_page.dart';
import 'package:spogpaws/ui/auth/signup/signup_page.dart';
import 'package:spogpaws/widgets/custom_button.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Image.asset(AppLogos.appLogo, height: 100),
              const SizedBox(height: 28),
              Text(
                'Welcome to SpogPaws',
                textAlign: TextAlign.center,
                style: AppFonts.nunitoBold(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to continue.',
                textAlign: TextAlign.center,
                style: AppFonts.nunitoRegular(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Login',
                onTap: () => NavigatorHelper.push(context, const LoginPage()),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Sign Up',
                backgroundColor: AppColors.white,
                onTap: () => NavigatorHelper.push(context, const SignupPage()),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
