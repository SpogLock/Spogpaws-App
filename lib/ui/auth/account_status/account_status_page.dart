import 'package:flutter/material.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/ui/auth/login/login_page.dart';
import 'package:spogpaws/widgets/custom_button.dart';

class AccountStatusPage extends StatelessWidget {
  const AccountStatusPage({
    super.key,
    required this.title,
    required this.message,
    required this.badge,
    required this.badgeColor,
    this.actionText = 'Back to Login',
    this.onActionTap,
  });

  final String title;
  final String message;
  final String badge;
  final Color badgeColor;
  final String actionText;
  final VoidCallback? onActionTap;

  factory AccountStatusPage.pending() {
    return const AccountStatusPage(
      title: 'Account Pending',
      message:
          'Your account is created and waiting for approval. We will notify you once activated.',
      badge: 'PENDING',
      badgeColor: AppColors.warning,
    );
  }

  factory AccountStatusPage.suspended() {
    return const AccountStatusPage(
      title: 'Account Suspended',
      message:
          'Your account is temporarily suspended. Please contact support for help.',
      badge: 'SUSPENDED',
      badgeColor: Color(0xFFE57373),
    );
  }

  factory AccountStatusPage.banned() {
    return const AccountStatusPage(
      title: 'Account Restricted',
      message:
          'This account has been restricted. Reach out to support if you think this is a mistake.',
      badge: 'BANNED',
      badgeColor: AppColors.error,
    );
  }

  factory AccountStatusPage.unknown() {
    return const AccountStatusPage(
      title: 'Status Unavailable',
      message:
          'We could not verify your account status right now. Please try again shortly.',
      badge: 'UNKNOWN',
      badgeColor: AppColors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(AppLogos.appLogo, width: 200),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  border: Border.all(color: badgeColor),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  badge,
                  style: AppFonts.poppinsSemiBold(fontSize: 11, color: badgeColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.nunitoBold(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppFonts.nunitoRegular(fontSize: 14, color: AppColors.grey),
              ),
              const Spacer(),
              CustomButton(
                text: actionText,
                onTap:
                    onActionTap ??
                    () => NavigatorHelper.replace(context, const LoginPage()),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
