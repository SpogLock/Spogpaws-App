import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:spogpaws/widgets/custom_textfield.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hasEightCharacters = false;
  bool _hasSpecialCharOrNumber = false;

  @override
  void initState() {
    super.initState();
    // Listen to password changes to update validation checklist
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final text = _passwordController.text;
    setState(() {
      _hasEightCharacters = text.length >= 8;
      _hasSpecialCharOrNumber = text.contains(
        RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: "Update Password",
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            const SizedBox(height: 8),
            // Contact Support TextButton
            TextButton(
              onPressed: () {
                // Handle Contact Support
              },
              child: Text(
                "Contact Support",
                style: AppFonts.nunitoMedium(
                  fontSize: 14,
                  color: Colors.blueAccent, // Use your theme primary color
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            const SizedBox(height: 150),
            Text(
              "Create New Password",
              style: AppFonts.nunitoBold(fontSize: 22),
            ),
            const SizedBox(height: 30),

            // --- OTP Field ---
            _buildLabel("Verification Code (OTP)"),
            CustomTextField(
              hintText: "Enter 6-digit code",
              controller: _otpController,
              // keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            // --- Password Field ---
            _buildLabel("New Password"),
            CustomTextField(
              hintText: "Enter new password",
              controller: _passwordController,
              // isPassword:
              //     true, // Assuming your custom widget handles obscureText
            ),

            // --- Password Validation Checklist ---
            const SizedBox(height: 12),
            _buildValidationRow("Minimum 8 characters", _hasEightCharacters),
            const SizedBox(height: 8),
            _buildValidationRow(
              "Include a special character or number",
              _hasSpecialCharOrNumber,
            ),

            const SizedBox(height: 15),

            // --- Confirm Password Field ---
            _buildLabel("Confirm Password"),
            CustomTextField(
              hintText: "Re-enter password",
              controller: _confirmPasswordController,
              // isPassword: true,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper to build field labels
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: AppFonts.nunitoMedium()),
      ),
    );
  }

  // Helper to build the checklist items like in your image
  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.check_circle_outline,
          size: 15,
          color: isValid ? const Color(0xFF42D0AC) : Colors.grey.shade400,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppFonts.nunitoRegular(
            fontSize: 12,
            color: isValid ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
