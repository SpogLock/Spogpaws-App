import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/widgets/custom_back_button.dart';

class AdoptionImagePreviewPage extends StatefulWidget {
  const AdoptionImagePreviewPage({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.petType,
  });

  final List<String> images;
  final int initialIndex;
  final String petType;

  @override
  State<AdoptionImagePreviewPage> createState() =>
      _AdoptionImagePreviewPageState();
}

class _AdoptionImagePreviewPageState extends State<AdoptionImagePreviewPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (value) {
                setState(() => _currentIndex = value);
              },
              itemBuilder: (context, index) {
                final imageUrl = widget.images[index];
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: imageUrl.isEmpty
                        ? _fallbackImage(widget.petType)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _fallbackImage(widget.petType),
                          ),
                  ),
                );
              },
            ),
            Positioned(top: 10, left: 12, child: const CustomBackButton()),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: AppFonts.nunitoSemiBold(
                    fontSize: 11,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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

    return SizedBox(width: 180, height: 180, child: Image.asset(iconAsset));
  }
}
