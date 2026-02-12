import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/bloc/user/user_bloc.dart';
import 'package:spogpaws/models/user_profile.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/ui/auth/account_status/account_status_page.dart';
import 'package:spogpaws/ui/auth/terms_and_conditions/terms_and_conditions_page.dart';
import 'package:spogpaws/ui/dashboard/app_dashboard.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:spogpaws/widgets/custom_checkbox.dart';
import 'package:spogpaws/widgets/custom_textfield.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleCreateAccount() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms agreement
    if (!_agreedToTerms) {
      AppToast.show(
        context,
        message: 'Please agree to the Terms & Privacy Policy',
        type: AppToastType.warning,
      );
      return;
    }

    context.read<UserBloc>().add(
      UserSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state.status == UserStatus.authenticated) {
          NavigatorHelper.replace(context, _pageForStatus(state.accountStatus));
        }

        if (state.status == UserStatus.success && state.message != null) {
          AppToast.show(
            context,
            message: state.message!,
            type: AppToastType.info,
          );
          NavigatorHelper.replace(context, AccountStatusPage.pending());
        }

        if (state.status == UserStatus.failure && state.message != null) {
          AppToast.show(
            context,
            message: state.message!,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == UserStatus.loading;

        return Scaffold(
            bottomNavigationBar: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppFonts.nunitoMedium(
                            fontSize: 12,
                          ).copyWith(color: AppColors.secondary),
                          text: "Already have an account? ",
                          children: [
                            TextSpan(
                              text: "Login",
                              style: AppFonts.nunitoBold(fontSize: 12).copyWith(
                                decoration: TextDecoration.underline,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CustomButton(
                    text: "Create Account",
                    isLoading: isLoading,
                    onTap: isLoading ? null : _handleCreateAccount,
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(118, 79, 55, 138),
                              Color.fromARGB(0, 255, 255, 255),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        Image.asset(AppLogos.appLogo, width: 220),
                        const SizedBox(height: 40),
                        Text(
                          "Create Account",
                          textAlign: TextAlign.center,
                          style: AppFonts.nunitoBold(fontSize: 22),
                        ),
                        Text(
                          "Join us and explore the world of pets.",
                          textAlign: TextAlign.center,
                          style: AppFonts.nunitoRegular(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// Full Name
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Full Name",
                            style: AppFonts.nunitoMedium(),
                          ),
                        ),
                        CustomTextField(
                          hintText: "John Doe",
                          controller: _fullNameController,
                          validator: _validateFullName,
                        ),

                        const SizedBox(height: 15),

                        /// Username
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Username",
                            style: AppFonts.nunitoMedium(),
                          ),
                        ),
                        CustomTextField(
                          hintText: "Unique username",
                          controller: _usernameController,
                          validator: _validateUsername,
                        ),

                        const SizedBox(height: 15),

                        /// Email
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Email", style: AppFonts.nunitoMedium()),
                        ),
                        CustomTextField(
                          hintText: "you@example.com",
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 15),

                        /// Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: AppFonts.nunitoMedium(),
                          ),
                        ),
                        CustomTextField(
                          hintText: "Create password",
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: true,
                        ),

                        const SizedBox(height: 15),

                        /// Confirm Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Confirm Password",
                            style: AppFonts.nunitoMedium(),
                          ),
                        ),
                        CustomTextField(
                          hintText: "Re-enter password",
                          controller: _confirmPasswordController,
                          validator: _validateConfirmPassword,
                          obscureText: true,
                        ),

                        const SizedBox(height: 15),

                        /// Terms
                        CustomCheckbox(
                          label: "I agree to the Terms & Privacy Policy",
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() => _agreedToTerms = value);
                            if (value == true) {
                              NavigatorHelper.push(
                                context,
                                TermsAndConditionsPage(),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}
  Widget _pageForStatus(AccountStatus status) {
    switch (status) {
      case AccountStatus.pending:
        return AccountStatusPage.pending();
      case AccountStatus.suspended:
        return AccountStatusPage.suspended();
      case AccountStatus.banned:
        return AccountStatusPage.banned();
      case AccountStatus.active:
        return const DashboardPage();
      case AccountStatus.unknown:
        return AccountStatusPage.unknown();
    }
  }
