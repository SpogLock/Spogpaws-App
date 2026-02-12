import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/models/adoption_post.dart';
import 'package:spogpaws/repositories/adoption_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/ui/adoption/adoption_image_preview_page.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_back_button.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoptionDetailPage extends StatefulWidget {
  const AdoptionDetailPage({super.key, required this.post});

  final AdoptionPost post;

  @override
  State<AdoptionDetailPage> createState() => _AdoptionDetailPageState();
}

class _AdoptionDetailPageState extends State<AdoptionDetailPage> {
  late final PageController _pageController;
  late final List<String> _images;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _images = widget.post.photoUrls.isNotEmpty ? widget.post.photoUrls : [''];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final location = post.nearbyArea.trim().isEmpty
        ? post.city
        : '${post.nearbyArea}, ${post.city}';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _buildImageGallery(post.petType),
                  ),
                  Positioned(
                    top: 10,
                    left: 12,
                    child: SafeArea(
                      bottom: false,
                      child: const CustomBackButton(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: SafeArea(
                      bottom: false,
                      child: GestureDetector(
                        onTap: _showReportSheet,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE1E5EC)),
                          ),
                          child: const Icon(
                            Icons.flag_outlined,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.petName,
                                style: AppFonts.nunitoBold(
                                  fontSize: 22,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${post.petType.toUpperCase()} - ${post.breed}',
                                style: AppFonts.nunitoSemiBold(
                                  fontSize: 13,
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
                                      style: AppFonts.nunitoRegular(
                                        fontSize: 11,
                                        color: AppColors.darkGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _StatusChip(status: post.status),
                            const SizedBox(height: 8),
                            Text(
                              _formatCreatedDate(post.createdAt),
                              style: AppFonts.nunitoRegular(
                                fontSize: 10,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FactRow(post: post),
                    const SizedBox(height: 12),
                    _SurfaceCard(
                      title: 'About ${post.petName}',
                      child: Text(
                        post.aboutPet.trim().isEmpty
                            ? 'No additional details were provided for this pet.'
                            : post.aboutPet,
                        style: AppFonts.nunitoRegular(
                          fontSize: 13,
                          color: AppColors.darkGrey,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SurfaceCard(
                      title: 'Owner Details',
                      child: Column(
                        children: [
                          _ContactLine(
                            icon: Icons.person_outline_rounded,
                            label: 'Name',
                            value: post.contactName,
                            fallback: 'Not provided',
                          ),
                          const SizedBox(height: 8),
                          _ContactLine(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: post.contactPhone,
                            fallback: 'Not provided',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Meet ${post.petName}',
                      onTap: () => _showContactOptionsSheet(post.contactPhone),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(String petType) {
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (value) {
              setState(() => _currentImageIndex = value);
            },
            itemBuilder: (context, index) {
              final imageUrl = _images[index];
              return GestureDetector(
                onTap: _openImagePreview,
                child: imageUrl.isEmpty
                    ? _fallbackImage(petType)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _fallbackImage(petType),
                      ),
              );
            },
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${_images.length}',
                style: AppFonts.nunitoSemiBold(
                  fontSize: 11,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage(String petType) {
    final normalized = petType.trim().toLowerCase();
    final iconAsset = normalized == 'dog'
        ? AppIcons.dog
        : normalized == 'bird'
        ? AppIcons.bird
        : AppIcons.cat;

    return Container(
      color: AppColors.lightGrey,
      child: Center(child: Image.asset(iconAsset, width: 120, height: 120)),
    );
  }

  String _formatCreatedDate(DateTime? value) {
    if (value == null) {
      return 'Date unavailable';
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[value.month - 1];
    return 'Posted $month ${value.day}, ${value.year}';
  }

  void _openImagePreview() {
    NavigatorHelper.push(
      context,
      AdoptionImagePreviewPage(
        images: _images,
        initialIndex: _currentImageIndex,
        petType: widget.post.petType,
      ),
    );
  }

  Future<void> _showContactOptionsSheet(String phone) async {
    final trimmedPhone = phone.trim();
    if (trimmedPhone.isEmpty) {
      AppToast.show(
        context,
        message: 'Phone number is not available.',
        type: AppToastType.warning,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose contact option',
                  style: AppFonts.nunitoBold(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'How would you like to contact the owner?',
                  style: AppFonts.nunitoRegular(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.call_outlined,
                        label: 'Call',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _launchPhoneCall(trimmedPhone);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'WhatsApp',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _launchWhatsApp(trimmedPhone);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReportSheet() async {
    final reasons = <String>[
      'Spam or misleading information',
      'Inappropriate photos or language',
      'Fraud or suspicious behavior',
      'Wrong category / not an adoption post',
      'Other',
    ];
    String? selectedReason;
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
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
                      'Report This Post',
                      style: AppFonts.nunitoBold(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tell us what is inappropriate. Our team will review it.',
                      style: AppFonts.nunitoRegular(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...reasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ReportReasonTile(
                          text: reason,
                          selected: selectedReason == reason,
                          onTap: () =>
                              setModalState(() => selectedReason = reason),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Submit Report',
                      isLoading: isSubmitting,
                      onTap: () async {
                        if (isSubmitting) {
                          return;
                        }
                        if (selectedReason == null) {
                          AppToast.show(
                            context,
                            message: 'Please select a reason.',
                            type: AppToastType.warning,
                          );
                          return;
                        }
                        setModalState(() => isSubmitting = true);
                        try {
                          await context
                              .read<AdoptionRepository>()
                              .submitAdoptionReport(
                                adoptionId: widget.post.id,
                                reason: selectedReason!,
                              );
                          if (!mounted) {
                            return;
                          }
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          AppToast.show(
                            this.context,
                            message:
                                'Report submitted. Thanks for helping keep the community safe.',
                            type: AppToastType.success,
                          );
                        } on AdoptionRepositoryException catch (e) {
                          if (!mounted) {
                            return;
                          }
                          AppToast.show(
                            this.context,
                            message: e.message,
                            type: AppToastType.error,
                          );
                        } catch (_) {
                          if (!mounted) {
                            return;
                          }
                          AppToast.show(
                            this.context,
                            message: 'Failed to submit report.',
                            type: AppToastType.error,
                          );
                        } finally {
                          if (sheetContext.mounted) {
                            setModalState(() => isSubmitting = false);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchPhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!mounted) {
      return;
    }
    AppToast.show(
      context,
      message: 'Calling is not supported on this device.',
      type: AppToastType.error,
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Invalid phone number for WhatsApp.',
        type: AppToastType.warning,
      );
      return;
    }

    final appUri = Uri.parse('whatsapp://send?phone=$normalized');
    final webUri = Uri.parse('https://wa.me/$normalized');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) {
      return;
    }
    AppToast.show(
      context,
      message: 'WhatsApp is not available on this device.',
      type: AppToastType.error,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, size: 24, color: AppColors.secondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppFonts.nunitoSemiBold(
                fontSize: 13,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportReasonTile extends StatelessWidget {
  const _ReportReasonTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGrey : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.black,
          ),
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
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? AppColors.secondary : AppColors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: AppFonts.nunitoRegular(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.post});

  final AdoptionPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FactTile(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: post.age,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FactTile(
            icon: Icons.pets_rounded,
            label: 'Breed',
            value: post.breed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FactTile(
            icon: Icons.health_and_safety_outlined,
            label: 'Vaccinated',
            value: post.vaccinated,
          ),
        ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
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
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.black),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.secondary),
          const Spacer(),
          Text(
            value.trim().isEmpty ? '-' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.nunitoBold(fontSize: 12, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppFonts.nunitoRegular(
              fontSize: 10,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.black),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.nunitoBold(fontSize: 14)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.fallback,
  });

  final IconData icon;
  final String label;
  final String value;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final text = value.trim().isNotEmpty ? value : fallback;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: AppFonts.nunitoSemiBold(
                fontSize: 11,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.nunitoRegular(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 5),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: AppFonts.nunitoSemiBold(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String value) {
    switch (value) {
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
}
