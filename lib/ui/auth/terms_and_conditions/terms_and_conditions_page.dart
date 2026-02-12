import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/widgets/custom_back_button.dart';
import 'package:spogpaws/widgets/custom_button.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(title: ""),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          text: "I Agree",
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            SizedBox(height: 20),
            CustomBackButton(),
            SizedBox(height: 20),
            Text(
              "Last updated: Jan 2026",
              style: AppFonts.nunitoRegular(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text("1. Introduction", style: AppFonts.nunitoBold(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              "By using SpogPaws, you agree to the following terms and conditions...",
              style: AppFonts.nunitoRegular(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              "2. User Responsibilities",
              style: AppFonts.nunitoBold(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "You are responsible for maintaining the confidentiality of your account...",
              style: AppFonts.nunitoRegular(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text("3. Privacy Policy", style: AppFonts.nunitoBold(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              "We value your privacy and handle your data responsibly...",
              style: AppFonts.nunitoRegular(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
