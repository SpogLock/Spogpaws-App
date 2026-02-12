import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/models/user_profile.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/repositories/user_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/ui/auth/auth_choice_page.dart';
import 'package:spogpaws/ui/dashboard/my_posts_page.dart';
import 'package:spogpaws/ui/dashboard/privacy_policy_page.dart';
import 'package:spogpaws/ui/dashboard/report_problem_page.dart';
import 'package:spogpaws/ui/dashboard/suggestion_page.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await context.read<UserRepository>().getCurrentProfile();
      if (!mounted) {
        return;
      }
      setState(() => _profile = profile);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Could not load profile details.',
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _profile;
    final fullName = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!
        : 'John Stones';
    final username = user?.username?.trim().isNotEmpty == true
        ? user!.username!
        : 'sarah1234';
    final email = user?.email ?? 'example@mail.com';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppIcons.cat,
                        width: 62,
                        height: 62,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_loading)
                    const CircularProgressIndicator(strokeWidth: 2)
                  else ...[
                    Text(
                      fullName,
                      style: AppFonts.nunitoBold(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      username,
                      style: AppFonts.nunitoRegular(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      email,
                      style: AppFonts.nunitoRegular(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _optionTile(
              title: 'My Posts',
              icon: Icons.post_add_rounded,
              onTap: () => NavigatorHelper.push(context, const MyPostsPage()),
            ),
            const SizedBox(height: 10),
            _optionTile(
              title: 'Report a Problem',
              icon: Icons.report_gmailerrorred_rounded,
              onTap: () =>
                  NavigatorHelper.push(context, const ReportProblemPage()),
            ),
            const SizedBox(height: 10),
            _optionTile(
              title: 'Make a Suggestion',
              icon: Icons.lightbulb_outline_rounded,
              onTap: () => NavigatorHelper.push(context, const SuggestionPage()),
            ),
            const SizedBox(height: 10),
            _optionTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () =>
                  NavigatorHelper.push(context, const PrivacyPolicyPage()),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Log Out',
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) {
                  return;
                }
                NavigatorHelper.replace(context, const AuthChoicePage());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return _ProfileActionTile(
      title: title,
      icon: icon,
      onTap: onTap,
    );
  }
}

class _ProfileActionTile extends StatefulWidget {
  const _ProfileActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ProfileActionTile> createState() => _ProfileActionTileState();
}

class _ProfileActionTileState extends State<_ProfileActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0,
          _isPressed ? 2 : 0,
          0,
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: AppColors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: AppFonts.nunitoMedium(fontSize: 13),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.black),
          ],
        ),
      ),
    );
  }
}
