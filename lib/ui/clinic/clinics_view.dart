import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/models/clinic.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/repositories/clinic_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/ui/clinic/clinic_detail_page.dart';
import 'package:spogpaws/widgets/app_pressable.dart';
import 'package:spogpaws/widgets/custom_button.dart';

class ClinicsView extends StatefulWidget {
  const ClinicsView({super.key});

  @override
  State<ClinicsView> createState() => _ClinicsViewState();
}

class _ClinicsViewState extends State<ClinicsView> {
  static const int _pageSize = 10;

  final List<Clinic> _clinics = <Clinic>[];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  String _cityFilter = 'all';
  String _hoursFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _error = null;
      _clinics.clear();
      _hasMore = true;
    });

    try {
      final items = await context.read<ClinicRepository>().getActiveClinics(
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _clinics.addAll(items);
        _hasMore = items.length == _pageSize;
      });
    } on ClinicRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Failed to load clinics.');
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoadingInitial) {
      return;
    }

    setState(() => _isLoadingMore = true);
    try {
      final items = await context.read<ClinicRepository>().getActiveClinics(
        limit: _pageSize,
        offset: _clinics.length,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _clinics.addAll(items);
        _hasMore = items.length == _pageSize;
      });
    } on ClinicRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Failed to load more clinics.');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadMore();
    }
  }

  List<Clinic> get _visibleClinics {
    return _clinics.where((clinic) {
      final city = clinic.city.trim().toLowerCase();
      final matchesCity = _cityFilter == 'all' || city == _cityFilter;
      final matchesHours =
          _hoursFilter == 'all' ||
          (_hoursFilter == '24_7' ? clinic.is24Hours : !clinic.is24Hours);
      return matchesCity && matchesHours;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    String tempCity = _cityFilter;
    String tempHours = _hoursFilter;
    final cityOptions =
        _clinics
            .map((item) => item.city.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FILTER CLINICS',
                    style: AppFonts.nunitoBold(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text('City', style: AppFonts.nunitoSemiBold(fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'All',
                        selected: tempCity == 'all',
                        onTap: () => setModalState(() => tempCity = 'all'),
                      ),
                      ...cityOptions.map(
                        (city) => _filterChip(
                          label: city,
                          selected: tempCity == city.toLowerCase(),
                          onTap: () => setModalState(
                            () => tempCity = city.toLowerCase(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Hours', style: AppFonts.nunitoSemiBold(fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'All',
                        selected: tempHours == 'all',
                        onTap: () => setModalState(() => tempHours = 'all'),
                      ),
                      _filterChip(
                        label: '24/7',
                        selected: tempHours == '24_7',
                        onTap: () => setModalState(() => tempHours = '24_7'),
                      ),
                      _filterChip(
                        label: 'Regular',
                        selected: tempHours == 'regular',
                        onTap: () => setModalState(() => tempHours = 'regular'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Reset',
                          backgroundColor: AppColors.lightGrey,
                          onTap: () {
                            Navigator.pop(context, {
                              'city': 'all',
                              'hours': 'all',
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Apply',
                          onTap: () {
                            Navigator.pop(context, {
                              'city': tempCity,
                              'hours': tempHours,
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _cityFilter = result['city'] ?? 'all';
      _hoursFilter = result['hours'] ?? 'all';
    });
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.black),
          boxShadow: selected
              ? []
              : const [
                  BoxShadow(
                    color: AppColors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          label.toUpperCase(),
          style: AppFonts.nunitoSemiBold(fontSize: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Find Clinics',
                    style: AppFonts.poppinsMedium(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 10),
                AppPressable(
                  onTap: _openFilterSheet,
                  backgroundColor: const Color(0xFFF7F8FA),
                  borderColor: AppStyle.outlineStrong,
                  radius: AppStyle.radiusMd,
                  depth: 2,
                  height: 42,
                  width: 42,
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 19,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadInitial,
              child: _isLoadingInitial
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _clinics.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      children: [
                        const SizedBox(height: 80),
                        _StateCard(
                          icon: Icons.wifi_off_rounded,
                          title: 'Could not load clinics',
                          description: _error!,
                          iconColor: AppColors.error,
                          buttonText: 'Try Again',
                          onTap: _loadInitial,
                        ),
                      ],
                    )
                  : _clinics.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      children: [
                        const SizedBox(height: 80),
                        _StateCard(
                          icon: Icons.local_hospital_outlined,
                          title: 'No clinics yet',
                          description:
                              'No clinics are available right now. Pull to refresh and check again.',
                          iconColor: AppColors.secondary,
                          buttonText: 'Refresh',
                          onTap: _loadInitial,
                        ),
                      ],
                    )
                  : _visibleClinics.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      children: [
                        const SizedBox(height: 80),
                        _StateCard(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'No clinics match filters',
                          description:
                              'Try changing or resetting filters to see more clinics.',
                          iconColor: AppColors.secondary,
                          buttonText: 'Reset Filters',
                          onTap: () {
                            setState(() {
                              _cityFilter = 'all';
                              _hoursFilter = 'all';
                            });
                          },
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      itemCount:
                          _visibleClinics.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _visibleClinics.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final clinic = _visibleClinics[index];
                        return _ClinicCard(clinic: clinic);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({required this.clinic});

  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    final services = clinic.services.take(2).toList();
    return GestureDetector(
      onTap: () =>
          NavigatorHelper.push(context, ClinicDetailPage(clinic: clinic)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppStyle.radiusMd),
          border: Border.all(color: AppStyle.clinicCardBorder),
          boxShadow: const [
            BoxShadow(
              color: AppStyle.clinicCardShadow,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppStyle.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppStyle.outline),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          clinic.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.nunitoBold(fontSize: 16, height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(text: clinic.is24Hours ? '24/7' : 'Open'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clinic.fullLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.nunitoRegular(
                            fontSize: 11,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          clinic.hoursLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.nunitoRegular(
                            fontSize: 11,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: services.isEmpty
                        ? <Widget>[_chip('General Care')]
                        : services.map(_chip).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyle.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyle.outline),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppFonts.nunitoSemiBold(fontSize: 10),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyle.outline),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppFonts.nunitoSemiBold(fontSize: 10),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        border: Border.all(color: AppStyle.clinicStateBorder),
        boxShadow: const [
          BoxShadow(
            color: AppStyle.clinicStateShadow,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppStyle.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppStyle.outline),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.nunitoBold(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppFonts.nunitoRegular(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(text: buttonText, onTap: onTap),
        ],
      ),
    );
  }
}
