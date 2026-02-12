import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: AppFonts.nunitoBold(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              title: '1. Information We Collect',
              body:
                  'We collect account details you provide and activity needed to offer core app features like profile management and adoption posts.',
            ),
            _section(
              title: '2. How We Use Information',
              body:
                  'Data is used to operate the service, improve reliability, prevent abuse, and communicate important account updates.',
            ),
            _section(
              title: '3. Data Sharing',
              body:
                  'We do not sell personal data. Information is shared only with providers required to run the platform or when required by law.',
            ),
            _section(
              title: '4. Contact',
              body:
                  'If you have privacy questions, contact support through the in-app report and suggestion forms.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppFonts.nunitoBold(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              body,
              style: AppFonts.nunitoRegular(fontSize: 12, color: AppColors.darkGrey),
            ),
          ],
        ),
      ),
    );
  }
}
