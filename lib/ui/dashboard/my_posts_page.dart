import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/models/adoption_post.dart';
import 'package:spogpaws/repositories/adoption_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/ui/adoption/adoption_detail_page.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_dropdown.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  bool _isLoading = true;
  String? _error;
  List<AdoptionPost> _posts = const [];
  final Set<String> _updatingIds = <String>{};

  static const _statusOptions = [
    'under_review',
    'approved',
    'adopted',
    'closed',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await context.read<AdoptionRepository>().getMyPosts();
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
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
      setState(() => _error = 'Failed to load posts.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateStatus(AdoptionPost post, String newStatus) async {
    if (_updatingIds.contains(post.id) || post.status == newStatus) {
      return;
    }

    setState(() => _updatingIds.add(post.id));
    try {
      await context.read<AdoptionRepository>().updatePostStatus(
        postId: post.id,
        status: newStatus,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _posts = _posts
            .map(
              (item) => item.id == post.id
                  ? AdoptionPost(
                      id: item.id,
                      userId: item.userId,
                      petType: item.petType,
                      petName: item.petName,
                      breed: item.breed,
                      age: item.age,
                      vaccinated: item.vaccinated,
                      aboutPet: item.aboutPet,
                      city: item.city,
                      nearbyArea: item.nearbyArea,
                      status: newStatus,
                      contactName: item.contactName,
                      contactPhone: item.contactPhone,
                      contactEmail: item.contactEmail,
                      createdAt: item.createdAt,
                      photoUrls: item.photoUrls,
                    )
                  : item,
            )
            .toList();
      });
    } on AdoptionRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      AppToast.show(context, message: e.message, type: AppToastType.error);
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Failed to update post status.',
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(post.id));
      }
    }
  }

  String _prettyStatus(String value) {
    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'adopted':
        return AppColors.secondary;
      case 'closed':
        return AppColors.darkGrey;
      case 'under_review':
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts', style: AppFonts.nunitoBold(fontSize: 20)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(
                  child: Text(
                    _error!,
                    style: AppFonts.nunitoMedium(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                )
              else if (_posts.isEmpty)
                Center(
                  child: Text(
                    'No adoption posts yet.',
                    style: AppFonts.nunitoMedium(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children: _posts.map((post) {
                    final isUpdating = _updatingIds.contains(post.id);
                    final color = _statusColor(post.status);
                    return Container(
                      width: double.infinity,
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
                            children: [
                              Expanded(
                                child: Text(
                                  post.petName,
                                  style: AppFonts.nunitoBold(fontSize: 16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => NavigatorHelper.push(
                                  context,
                                  AdoptionDetailPage(post: post),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.black),
                                  ),
                                  child: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 14,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: color),
                                ),
                                child: Text(
                                  _prettyStatus(post.status),
                                  style: AppFonts.nunitoSemiBold(
                                    fontSize: 11,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${post.petType.toUpperCase()} - ${post.breed} - ${post.city}',
                            style: AppFonts.nunitoRegular(
                              fontSize: 12,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Update status',
                            style: AppFonts.nunitoMedium(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          CustomDropdownField(
                            value: post.status,
                            hintText: 'Select status',
                            sheetTitle: 'Update Post Status',
                            options: _statusOptions,
                            onChanged: isUpdating
                                ? null
                                : (value) => _updateStatus(post, value),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
