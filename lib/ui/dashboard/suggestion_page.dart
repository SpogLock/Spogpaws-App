import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:spogpaws/widgets/custom_textfield.dart';

class SuggestionPage extends StatelessWidget {
  const SuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Suggestion', style: AppFonts.nunitoBold(fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share ideas to improve SpogPaws for everyone.',
              style: AppFonts.nunitoRegular(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'Your suggestion',
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Send',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
