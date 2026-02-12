import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/models/adoption_post.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/repositories/adoption_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/ui/adoption/adoption_detail_page.dart';
import 'package:spogpaws/widgets/app_pressable.dart';
import 'package:spogpaws/widgets/custom_button.dart';

class AdoptionView extends StatefulWidget {
  const AdoptionView({super.key});

  @override
  State<AdoptionView> createState() => _AdoptionViewState();
}

class _AdoptionViewState extends State<AdoptionView> {
  static const int _pageSize = 10;

  final List<AdoptionPost> _posts = <AdoptionPost>[];
  final ScrollController _scrollController = ScrollController();
  String _petTypeFilter = 'all';
  String _vaccinatedFilter = 'all';

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

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
      _posts.clear();
      _hasMore = true;
    });

    try {
      final items = await context.read<AdoptionRepository>().getActivePosts(
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _posts.addAll(items);
        _hasMore = items.length == _pageSize;
      });
    } on AdoptionRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Failed to load adoption posts.');
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
      final items = await context.read<AdoptionRepository>().getActivePosts(
        limit: _pageSize,
        offset: _posts.length,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _posts.addAll(items);
        _hasMore = items.length == _pageSize;
      });
    } on AdoptionRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Failed to load more posts.');
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

  List<AdoptionPost> get _visiblePosts {
    return _posts.where((post) {
      final normalizedType = post.petType.trim().toLowerCase();
      final normalizedVaccinated = post.vaccinated.trim().toLowerCase();
      final matchesType =
          _petTypeFilter == 'all' || normalizedType == _petTypeFilter;
      final matchesVaccinated =
          _vaccinatedFilter == 'all' ||
          (_vaccinatedFilter == 'yes'
              ? normalizedVaccinated == 'yes'
              : normalizedVaccinated != 'yes');
      return matchesType && matchesVaccinated;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    String tempPetType = _petTypeFilter;
    String tempVaccinated = _vaccinatedFilter;

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
                    'FILTER POSTS',
                    style: AppFonts.nunitoBold(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pet Type',
                    style: AppFonts.nunitoSemiBold(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'All',
                        selected: tempPetType == 'all',
                        onTap: () => setModalState(() => tempPetType = 'all'),
                      ),
                      _filterChip(
                        label: 'Cat',
                        selected: tempPetType == 'cat',
                        onTap: () => setModalState(() => tempPetType = 'cat'),
                      ),
                      _filterChip(
                        label: 'Dog',
                        selected: tempPetType == 'dog',
                        onTap: () => setModalState(() => tempPetType = 'dog'),
                      ),
                      _filterChip(
                        label: 'Bird',
                        selected: tempPetType == 'bird',
                        onTap: () => setModalState(() => tempPetType = 'bird'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vaccinated',
                    style: AppFonts.nunitoSemiBold(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'All',
                        selected: tempVaccinated == 'all',
                        onTap: () =>
                            setModalState(() => tempVaccinated = 'all'),
                      ),
                      _filterChip(
                        label: 'Yes',
                        selected: tempVaccinated == 'yes',
                        onTap: () =>
                            setModalState(() => tempVaccinated = 'yes'),
                      ),
                      _filterChip(
                        label: 'No',
                        selected: tempVaccinated == 'no',
                        onTap: () => setModalState(() => tempVaccinated = 'no'),
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
                              'petType': 'all',
                              'vaccinated': 'all',
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
                              'petType': tempPetType,
                              'vaccinated': tempVaccinated,
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
      _petTypeFilter = result['petType'] ?? 'all';
      _vaccinatedFilter = result['vaccinated'] ?? 'all';
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
                  child: RichText(
                    text: TextSpan(
                      style: AppFonts.nunitoRegular(
                        fontSize: 22,
                        color: AppColors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Find Your '),
                        TextSpan(
                          text: 'Friend!',
                          style: AppFonts.poppinsSemiBold(
                            fontSize: 22,
                            color: AppColors.secondary,
                          ).copyWith(fontStyle: .italic),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                AppPressable(
                  onTap: _openFilterSheet,
                  backgroundColor: const Color(0xFFF7F8FA),
                  borderColor: AppStyle.outlineStrong,
                  radius: 13,
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
                  : _error != null && _posts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      children: [
                        const SizedBox(height: 80),
                        _StateCard(
                          icon: Icons.wifi_off_rounded,
                          title: 'Could not load posts',
                          description: _error!,
                          iconColor: AppColors.error,
                          buttonText: 'Try Again',
                          onTap: _loadInitial,
                        ),
                      ],
                    )
                  : _posts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      children: [
                        const SizedBox(height: 80),
                        _StateCard(
                          icon: Icons.pets_outlined,
                          title: 'No active posts yet',
                          description:
                              'Approved adoption posts will show up here. Pull to refresh or check back in a bit.',
                          iconColor: AppColors.secondary,
                          buttonText: 'Refresh',
                          onTap: _loadInitial,
                        ),
                      ],
                    )
                  : _visiblePosts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      children: [
                        const SizedBox(height: 80),
                        _StateCard(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'No posts match filters',
                          description:
                              'Try changing or resetting filters to see more pets.',
                          iconColor: AppColors.secondary,
                          buttonText: 'Reset Filters',
                          onTap: () {
                            setState(() {
                              _petTypeFilter = 'all';
                              _vaccinatedFilter = 'all';
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
                          _visiblePosts.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _visiblePosts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final post = _visiblePosts[index];
                        return _AdoptionPostCard(post: post);
                      },
                    ),
            ),
          ),
        ],
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

class _AdoptionPostCard extends StatelessWidget {
  const _AdoptionPostCard({required this.post});

  final AdoptionPost post;

  @override
  Widget build(BuildContext context) {
    final photoUrl = post.photoUrls.isNotEmpty ? post.photoUrls.first : null;
    final location = post.city;

    return GestureDetector(
      onTap: () =>
          NavigatorHelper.push(context, AdoptionDetailPage(post: post)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppStyle.outline),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) =>
                                _fallbackImage(post.petType),
                          )
                        : _fallbackImage(post.petType),
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
                              post.petName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.nunitoBold(
                                fontSize: 16,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatRelativeCreatedDate(post.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.nunitoRegular(
                              fontSize: 10,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${post.petType.toUpperCase()} - ${post.breed}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.nunitoSemiBold(
                          fontSize: 12,
                          color: AppColors.darkGrey,
                        ),
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
                              location,
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
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip(post.age),
                          _chip(
                            post.vaccinated.toLowerCase() == 'yes'
                                ? 'Vaccinated'
                                : 'Not Vaccinated',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _fallbackImage(String petType) {
    final normalized = petType.trim().toLowerCase();
    final asset = normalized == 'dog'
        ? AppIcons.dog
        : normalized == 'bird'
        ? AppIcons.bird
        : AppIcons.cat;
    return Container(
      color: AppColors.lightGrey,
      child: Center(child: Image.asset(asset, width: 42, height: 42)),
    );
  }

  String _formatRelativeCreatedDate(DateTime? value) {
    if (value == null) {
      return 'Date unavailable';
    }

    final now = DateTime.now();
    final safeValue = value.isAfter(now) ? now : value;
    final days = now.difference(safeValue).inDays;

    if (days < 1) {
      return 'Today';
    }
    if (days < 7) {
      return _pluralize(days, 'day');
    }
    if (days < 30) {
      return _pluralize(days ~/ 7, 'week');
    }
    if (days < 365) {
      return _pluralize(days ~/ 30, 'month');
    }
    return _pluralize(days ~/ 365, 'year');
  }

  String _pluralize(int value, String unit) {
    final suffix = value == 1 ? '' : 's';
    return '$value $unit$suffix ago';
  }
}
