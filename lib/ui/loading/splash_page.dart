import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spogpaws/models/user_profile.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/repositories/update_policy_repository.dart';
import 'package:spogpaws/repositories/user_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/themes/app_prefs_keys.dart';
import 'package:spogpaws/ui/auth/account_status/account_status_page.dart';
import 'package:spogpaws/ui/auth/auth_choice_page.dart';
import 'package:spogpaws/ui/dashboard/app_dashboard.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _minimumVersionForSheet = '';
  String _updateUrlForSheet = '';

  @override
  void initState() {
    super.initState();
    _resolveStartupRoute();
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

  Future<void> _resolveStartupRoute() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    final shouldBlockForUpdate = await _shouldForceUpdate();
    if (shouldBlockForUpdate) {
      if (!mounted) {
        return;
      }
      await _showForcedUpdateSheet();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final shouldStayLoggedIn = prefs.getBool(AppPrefsKeys.stayLoggedIn) ?? true;
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) {
      return;
    }

    if (!shouldStayLoggedIn) {
      if (session != null) {
        await Supabase.instance.client.auth.signOut();
      }
      if (!mounted) {
        return;
      }
      NavigatorHelper.replace(context, const AuthChoicePage());
      return;
    }

    if (session == null) {
      if (!mounted) {
        return;
      }
      NavigatorHelper.replace(context, const AuthChoicePage());
      return;
    }

    try {
      final profile = await UserRepository().getCurrentProfile();
      if (!mounted) {
        return;
      }
      NavigatorHelper.replace(context, _pageForStatus(profile.accountStatus));
    } catch (_) {
      if (!mounted) {
        return;
      }
      NavigatorHelper.replace(context, const AuthChoicePage());
    }
  }

  Future<bool> _shouldForceUpdate() async {
    final policy = await context
        .read<UpdatePolicyRepository>()
        .fetchPolicyForCurrentPlatform();

    String minimumVersion = (dotenv.env['MIN_REQUIRED_VERSION'] ?? '').trim();
    String updateUrl = (dotenv.env['FORCE_UPDATE_URL'] ?? '').trim();
    bool isEnabled = minimumVersion.isNotEmpty;

    if (policy != null) {
      minimumVersion = policy.minRequiredVersion.trim();
      updateUrl = policy.forceUpdateUrl.trim();
      isEnabled = policy.isEnabled;
    }

    if (!isEnabled || minimumVersion.isEmpty) {
      return false;
    }

    String? currentVersion;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }

    final shouldUpdate = _compareVersions(currentVersion, minimumVersion) < 0;
    if (shouldUpdate) {
      _minimumVersionForSheet = minimumVersion;
      _updateUrlForSheet = updateUrl;
    }
    return shouldUpdate;
  }

  int _compareVersions(String current, String minimum) {
    List<int> parse(String value) {
      return value.split('.').map((part) {
        final normalized = part.replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(normalized) ?? 0;
      }).toList();
    }

    final currentParts = parse(current);
    final minimumParts = parse(minimum);
    final maxLength = currentParts.length > minimumParts.length
        ? currentParts.length
        : minimumParts.length;

    for (var i = 0; i < maxLength; i++) {
      final cur = i < currentParts.length ? currentParts[i] : 0;
      final min = i < minimumParts.length ? minimumParts[i] : 0;
      if (cur != min) {
        return cur.compareTo(min);
      }
    }
    return 0;
  }

  Future<void> _showForcedUpdateSheet() async {
    final minimumVersion = _minimumVersionForSheet;
    final updateUrl = _updateUrlForSheet;
    final hasUpdateUrl = updateUrl.isNotEmpty;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return PopScope(
          canPop: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Update Required',
                    textAlign: TextAlign.center,
                    style: AppFonts.nunitoBold(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To continue using SpogPaws, install the latest app version (minimum $minimumVersion).',
                    textAlign: TextAlign.center,
                    style: AppFonts.nunitoRegular(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                  if (!hasUpdateUrl) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Set FORCE_UPDATE_URL in .env to direct users to your update page.',
                      textAlign: TextAlign.center,
                      style: AppFonts.nunitoRegular(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Update Now',
                    onTap: hasUpdateUrl ? () async {
                      final uri = Uri.tryParse(updateUrl);
                      if (uri == null) {
                        return;
                      }
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECE7F8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppLogos.companyLogo, width: 140),
              const SizedBox(height: 20),
              Text(
                'SpogPaws',
                style: AppFonts.nunitoBold(fontSize: 30, color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Where happy pets begin',
                style: AppFonts.nunitoMedium(fontSize: 14, color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
