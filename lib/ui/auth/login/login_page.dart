import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spogpaws/bloc/user/user_bloc.dart';
import 'package:spogpaws/models/user_profile.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/themes/app_prefs_keys.dart';
import 'package:spogpaws/ui/auth/account_status/account_status_page.dart';
import 'package:spogpaws/ui/auth/forgot_password/forget_password_page.dart';
import 'package:spogpaws/ui/auth/signup/signup_page.dart';
import 'package:spogpaws/ui/dashboard/app_dashboard.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:spogpaws/widgets/custom_checkbox.dart';
import 'package:spogpaws/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _stayLoggedIn = true;

  @override
  void initState() {
    super.initState();
    _loadStayLoggedInPreference();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadStayLoggedInPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(AppPrefsKeys.stayLoggedIn);
    if (!mounted || value == null) {
      return;
    }
    setState(() => _stayLoggedIn = value);
  }

  Future<void> _saveStayLoggedInPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppPrefsKeys.stayLoggedIn, _stayLoggedIn);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void _handleLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<UserBloc>().add(
      UserLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state.status == UserStatus.authenticated) {
          _saveStayLoggedInPreference();
          NavigatorHelper.replace(context, _pageForStatus(state.accountStatus));
        }

        if (state.status == UserStatus.blocked) {
          _saveStayLoggedInPreference();
          NavigatorHelper.replace(context, _pageForStatus(state.accountStatus));
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
              margin: const .only(bottom: 16),
              padding: const .symmetric(horizontal: 16, vertical: 8.0),
              child: Column(
                mainAxisSize: .min,
                children: [
                  InkWell(
                    onTap: () {
                      NavigatorHelper.push(context, SignupPage());
                    },
                    borderRadius: .circular(30),
                    child: Padding(
                      padding: const .symmetric(horizontal: 8, vertical: 4),
                      child: RichText(
                        textAlign: .center,
                        text: TextSpan(
                          style: AppFonts.nunitoMedium(
                            fontSize: 12,
                          ).copyWith(color: AppColors.secondary),
                          text: "Not a member yet? ",
                          children: [
                            TextSpan(
                              text: "Register now",
                              style: AppFonts.nunitoBold(fontSize: 12).copyWith(
                                decoration: .underline,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  CustomButton(
                    text: "Login",
                    isLoading: isLoading,
                    onTap: isLoading ? null : () => _handleLogin(context),
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
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: .topCenter,
                            end: .bottomCenter,
                            colors: [
                              Color.fromARGB(118, 79, 55, 138),
                              Color.fromARGB(0, 255, 255, 255),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      children: [
                        Image.asset(AppLogos.appLogo, width: 250),
                        SizedBox(height: 50),
                        Text(
                          "Welcome back!",
                          textAlign: .center,
                          style: AppFonts.nunitoBold(fontSize: 22),
                        ),
                        Text(
                          "Sign in to continue exploring the world of pets.",
                          textAlign: .center,
                          style: AppFonts.nunitoRegular(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 25),
                        Align(
                          alignment: .centerLeft,
                          child: Text(
                            "Email",
                            style: AppFonts.nunitoMedium(),
                          ),
                        ),
                        CustomTextField(
                          hintText: "you@example.com",
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 15),
                        Align(
                          alignment: .centerLeft,
                          child: Text(
                            "Password",
                            style: AppFonts.nunitoMedium(fontSize: 12),
                          ),
                        ),
                        CustomTextField(
                          hintText: "Password",
                          obscureText: true,
                          controller: _passwordController,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Expanded(
                              child: CustomCheckbox(
                                label: "Stay logged in",
                                value: _stayLoggedIn,
                                onChanged: (value) {
                                  setState(() => _stayLoggedIn = value);
                                },
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  NavigatorHelper.push(
                                    context,
                                    ForgotPasswordPage(),
                                  );
                                },
                                borderRadius: .circular(30),
                                child: Padding(
                                  padding: const .symmetric(
                                    horizontal: 8.0,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    "Forgot Password?",
                                    textAlign: .end,
                                    style: AppFonts.nunitoMedium(
                                      fontSize: 12,
                                    ).copyWith(color: AppColors.secondary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
