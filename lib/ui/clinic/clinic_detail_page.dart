import 'package:flutter/material.dart';
import 'package:spogpaws/models/clinic.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_back_button.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicDetailPage extends StatelessWidget {
  const ClinicDetailPage({super.key, required this.clinic});

  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    final displayServices = clinic.services.isNotEmpty
        ? clinic.services
        : const <String>['General Care'];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(alignment: .centerLeft, child: CustomBackButton()),
            ),
            SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                        border: Border.all(color: AppStyle.clinicDetailBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: AppStyle.clinicDetailShadow,
                            blurRadius: 0,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.black),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: AppColors.secondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic.name,
                                  style: AppFonts.nunitoBold(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  clinic.hoursLabel,
                                  style: AppFonts.nunitoSemiBold(
                                    fontSize: 12,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  clinic.fullLocation,
                                  style: AppFonts.nunitoRegular(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SurfaceCard(
                      title: 'Contact',
                      child: Column(
                        children: [
                          _Line(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: clinic.contactPhone.trim().isEmpty
                                ? 'Not available'
                                : clinic.contactPhone,
                          ),
                          const SizedBox(height: 8),
                          _Line(
                            icon: Icons.emergency_outlined,
                            label: 'Emergency',
                            value: clinic.emergencyPhone.trim().isEmpty
                                ? 'Not available'
                                : clinic.emergencyPhone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SurfaceCard(
                      title: 'Services',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: displayServices
                            .map((item) => _ServiceChip(text: item))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SurfaceCard(
                      title: 'About',
                      child: Text(
                        clinic.about.trim().isEmpty
                            ? 'No additional details were provided.'
                            : clinic.about,
                        style: AppFonts.nunitoRegular(
                          fontSize: 13,
                          color: AppColors.darkGrey,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Call',
                            icon: Icons.call_outlined,
                            backgroundColor: AppColors.secondary,
                            onTap: () => _call(context, clinic.contactPhone),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Emergency',
                            icon: Icons.emergency_outlined,
                            backgroundColor: AppColors.secondary,
                            onTap: () => _call(context, clinic.emergencyPhone),
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
      ),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      AppToast.show(
        context,
        message: 'Phone number is not available.',
        type: AppToastType.warning,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: trimmed);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!context.mounted) {
      return;
    }
    AppToast.show(
      context,
      message: 'Calling is not supported on this device.',
      type: AppToastType.error,
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
        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
        border: Border.all(color: AppStyle.clinicDetailBorder),
        boxShadow: const [
          BoxShadow(
            color: AppStyle.clinicDetailShadow,
            offset: Offset(2, 2),
            blurRadius: 0,
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

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppFonts.nunitoSemiBold(
              fontSize: 11,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: AppFonts.nunitoRegular(fontSize: 12)),
        ),
      ],
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppFonts.nunitoSemiBold(fontSize: 10),
      ),
    );
  }
}
