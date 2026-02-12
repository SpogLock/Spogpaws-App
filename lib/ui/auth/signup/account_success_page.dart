import 'package:flutter/material.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/ui/dashboard/app_dashboard.dart';
import 'package:spogpaws/widgets/custom_button.dart';

class AccountSuccessPage extends StatelessWidget {
  const AccountSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // --- Success Illustration/Icon ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative background circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Success Icon
                  Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: AppColors.primary,
                  ),
                  // Small decorative paw prints
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.pets,
                      color: AppColors.secondary.withOpacity(0.2),
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- Success Text ---
              Text(
                "Wag-tastic!",
                style: AppFonts.nunitoBold(
                  fontSize: 28,
                ).copyWith(color: AppColors.secondary),
              ),

              const SizedBox(height: 12),

              Text(
                "Your account has been created successfully. Your journey with Spogpaws starts now!",
                textAlign: TextAlign.center,
                style: AppFonts.nunitoRegular(
                  fontSize: 16,
                ).copyWith(color: AppColors.grey, height: 1.5),
              ),

              const Spacer(),

              // --- Action Button ---
              CustomButton(
                text: "Get Started",
                onTap: () {
                  // Navigate to Home Page and clear navigation stack
                  NavigatorHelper.push(context, DashboardPage());
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
