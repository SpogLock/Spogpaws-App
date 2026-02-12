import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/ui/auth/signup/account_success_page.dart';
import 'package:spogpaws/widgets/spog_keypad.dart'; // Import the new widget

class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  const VerificationPage({super.key, this.phoneNumber = "+1 ••• ••• 4567"});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String _otpCode = "";
  final int _otpLength = 6;

  void _handleKeyTap(String value) {
    if (_otpCode.length < _otpLength) {
      setState(() => _otpCode += value);
      if (_otpCode.length == _otpLength) _verifyAndProceed();
    }
  }

  void _handleBackspace() {
    if (_otpCode.isNotEmpty) {
      setState(() => _otpCode = _otpCode.substring(0, _otpCode.length - 1));
    }
  }

  void _verifyAndProceed() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate to Success Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              SizedBox(height: 15),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Verify your human paws! 🐾",
                      textAlign: .center,
                      style: AppFonts.nunitoBold(fontSize: 22),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "Enter the 6-digit code sent to \n${widget.phoneNumber}",
                      textAlign: TextAlign.center,
                      style: AppFonts.nunitoRegular(
                        fontSize: 14,
                      ).copyWith(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 50),

                    // OTP Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_otpLength, (index) {
                        bool isFilled = index < _otpCode.length;
                        return Container(
                          width: 40,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isFilled
                                    ? AppColors.secondary
                                    : Colors.grey.shade200,
                                width: 4,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isFilled ? _otpCode[index] : "",
                            style: AppFonts.nunitoBold(
                              fontSize: 26,
                            ).copyWith(color: AppColors.secondary),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 15),
                    InkWell(
                      onTap: () {},
                      borderRadius: .circular(30),
                      child: Padding(
                        padding: const .symmetric(horizontal: 8, vertical: 4),
                        child: RichText(
                          textAlign: .center,
                          text: TextSpan(
                            style: AppFonts.nunitoMedium(
                              fontSize: 12,
                            ).copyWith(color: AppColors.secondary),
                            text: "Didn't receive the code? ",

                            children: [
                              TextSpan(
                                text: "Resend!",
                                style: AppFonts.nunitoBold(fontSize: 12)
                                    .copyWith(
                                      decoration: .underline,
                                      color: AppColors.secondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Using the separated widget
              SpogKeypad(
                onKeyTap: _handleKeyTap,
                onBackspace: _handleBackspace,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
