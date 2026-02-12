import 'profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/models/tip_of_the_day.dart';
import 'package:spogpaws/repositories/adoption_repository.dart';
import 'package:spogpaws/repositories/clinic_repository.dart';
import 'package:spogpaws/repositories/tip_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/widgets/custom_button.dart';

export 'adoption_view.dart';
export 'package:spogpaws/ui/clinic/clinics_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = true;
  String? _error;
  TipOfTheDay? _tip;
  int _activeAdoptionCount = 0;
  int _activeClinicCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        context.read<TipRepository>().getLatestActiveTip(),
        context.read<AdoptionRepository>().getActivePosts(limit: 6, offset: 0),
        context.read<ClinicRepository>().getActiveClinics(limit: 6, offset: 0),
      ]);

      if (!mounted) {
        return;
      }

      final tip = results[0] as TipOfTheDay?;
      final adoptions = results[1] as List<dynamic>;
      final clinics = results[2] as List<dynamic>;

      setState(() {
        _tip = tip;
        _activeAdoptionCount = adoptions.length;
        _activeClinicCount = clinics.length;
      });
    } on TipRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } on AdoptionRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } on ClinicRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Failed to load dashboard data.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
          children: [
            _HeroHeader(greeting: _greeting()),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Today at a glance',
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.favorite_rounded,
                      label: 'Active Adoption',
                      value: _activeAdoptionCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_hospital_rounded,
                      label: 'Available Clinics',
                      value: _activeClinicCount.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _TipCard(
              isLoading: _isLoading,
              error: _error,
              tip: _tip,
              onRetry: _loadDashboard,
            ),
            const SizedBox(height: 12),
            const _SectionCard(
              title: 'Quick reminders',
              child: Column(
                children: [
                  _ReminderLine(
                    icon: Icons.pets_rounded,
                    text:
                        'Review vaccination history before each clinic visit.',
                  ),
                  SizedBox(height: 8),
                  _ReminderLine(
                    icon: Icons.clean_hands_outlined,
                    text:
                        'Keep food and water bowls clean to avoid infections.',
                  ),
                  SizedBox(height: 8),
                  _ReminderLine(
                    icon: Icons.calendar_month_rounded,
                    text: 'Set monthly reminders for grooming and flea checks.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) => const ProfilePage();
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEFFF8), Color(0xFFE7F0FF)],
        ),
        border: Border.all(color: AppStyle.dashboardHeroBorder),
        boxShadow: const [
          BoxShadow(
            color: AppStyle.dashboardHeroShadow,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppFonts.nunitoBold(
                    fontSize: 20,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here is your pet-care dashboard for today.',
                  style: AppFonts.nunitoRegular(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppStyle.radiusMd),
              border: Border.all(color: AppStyle.outline),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        border: Border.all(color: AppStyle.dashboardSectionBorder),
        boxShadow: const [
          BoxShadow(
            color: AppStyle.dashboardSectionShadow,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.nunitoBold(fontSize: 14, color: AppColors.black),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppStyle.outlinedSurface(
        background: AppStyle.surfaceMuted,
        borderColor: AppStyle.dashboardTileBorder,
        radiusValue: AppStyle.radiusMd,
        withShadow: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppFonts.nunitoBold(fontSize: 20, color: AppColors.black),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppFonts.nunitoRegular(fontSize: 11, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.isLoading,
    required this.error,
    required this.tip,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final TipOfTheDay? tip;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF9E9), Color(0xFFFFF0CD)],
        ),
        border: Border.all(color: AppStyle.dashboardTipBorder),
        boxShadow: const [
          BoxShadow(
            color: AppStyle.dashboardTipShadow,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  size: 17,
                  color: Color(0xFFB67D00),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tip of the day',
                style: AppFonts.nunitoBold(
                  fontSize: 15,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error!,
                  style: AppFonts.nunitoRegular(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  child: CustomButton(
                    text: 'Retry',
                    onTap: () => onRetry(),
                    backgroundColor: AppColors.white,
                  ),
                ),
              ],
            )
          else if (tip == null)
            Text(
              'No tip has been published yet.',
              style: AppFonts.nunitoRegular(
                fontSize: 12,
                color: AppColors.darkGrey,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip!.title,
                  style: AppFonts.nunitoBold(fontSize: 16, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  tip!.content,
                  style: AppFonts.nunitoRegular(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                _TipMeta(
                  category: tip!.category,
                  publishedOn: tip!.publishedOn,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TipMeta extends StatelessWidget {
  const _TipMeta({required this.category, required this.publishedOn});

  final String category;
  final DateTime? publishedOn;

  @override
  Widget build(BuildContext context) {
    final date = publishedOn;
    final dateText = date == null
        ? 'Date unavailable'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(
          icon: Icons.sell_outlined,
          text: category.trim().isEmpty ? 'care' : category,
        ),
        _MetaChip(icon: Icons.event_outlined, text: dateText),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        border: Border.all(color: const Color(0xFFF4D587)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFB67D00)),
          const SizedBox(width: 4),
          Text(
            text.toUpperCase(),
            style: AppFonts.nunitoSemiBold(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ReminderLine extends StatelessWidget {
  const _ReminderLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppFonts.nunitoRegular(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ),
      ],
    );
  }
}
