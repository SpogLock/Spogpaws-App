import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spogpaws/navigation/navigation_helper.dart';
import 'package:spogpaws/repositories/adoption_repository.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_images.dart';
import 'package:spogpaws/widgets/app_toast.dart';
import 'package:spogpaws/widgets/custom_back_button.dart';
import 'package:spogpaws/widgets/custom_button.dart';
import 'package:spogpaws/widgets/custom_dropdown.dart';
import 'package:spogpaws/widgets/custom_textfield.dart';

class AdoptionFlowPage extends StatefulWidget {
  const AdoptionFlowPage({super.key});

  @override
  State<AdoptionFlowPage> createState() => _AdoptionFlowPageState();
}

class _AdoptionFlowPageState extends State<AdoptionFlowPage> {
  final _petInfoFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();

  int _step = 0;
  String? _petType;
  String? _pressedPetType;
  bool _isSubmitting = false;

  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _aboutController = TextEditingController();
  final _nearbyAreaController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  final List<_PickedAdoptionPhoto> _selectedPhotos = [];

  String? _selectedAge;
  String? _selectedVaccinated;
  String? _selectedCity;

  final _ageOptions = const [
    'Less than 1 year',
    '1 year old',
    '2 years old',
    '3+ years old',
  ];

  final _vaccinationOptions = const ['Yes', 'No'];

  final _cityOptions = const [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'San Diego',
  ];

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _aboutController.dispose();
    _nearbyAreaController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (!_isCurrentStepValid()) {
      return;
    }

    if (_step < 4) {
      setState(() => _step += 1);
      return;
    }

    if (_step == 4) {
      await _submitPostAndGoToReview();
      return;
    }

    NavigatorHelper.pop(context);
  }

  bool _isCurrentStepValid() {
    if (_step == 0 && _petType == null) {
      AppToast.show(
        context,
        message: 'Please select a pet type to continue.',
        type: AppToastType.warning,
      );
      return false;
    }

    if (_step == 1 && _selectedPhotos.isEmpty) {
      AppToast.show(
        context,
        message: 'Please upload at least one photo.',
        type: AppToastType.warning,
      );
      return false;
    }

    if (_step == 2) {
      final valid = _petInfoFormKey.currentState?.validate() ?? false;
      if (!valid) {
        return false;
      }
    }

    if (_step == 3) {
      final valid = _locationFormKey.currentState?.validate() ?? false;
      if (!valid) {
        return false;
      }
    }

    if (_step == 4) {
      final valid = _contactFormKey.currentState?.validate() ?? false;
      if (!valid) {
        return false;
      }
    }

    return true;
  }

  Future<void> _pickPhotos() async {
    try {
      final picker = ImagePicker();
      const maxPhotos = 3;
      final allowed = maxPhotos - _selectedPhotos.length;
      if (allowed <= 0) {
        AppToast.show(
          context,
          message: 'You can upload up to $maxPhotos photos.',
          type: AppToastType.warning,
        );
        return;
      }

      List<XFile> picked;
      try {
        picked = await picker.pickMultiImage(
          imageQuality: 55,
          maxWidth: 1280,
          maxHeight: 1280,
        );
      } on PlatformException catch (_) {
        final single = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 55,
          maxWidth: 1280,
          maxHeight: 1280,
        );
        picked = single == null ? const [] : [single];
      }

      if (picked.isEmpty || !mounted) {
        return;
      }

      final filesToUse = picked.take(allowed).toList();
      final loaded = <_PickedAdoptionPhoto>[];

      for (final file in filesToUse) {
        final originalBytes = await file.readAsBytes();
        final extension = _extensionFrom(file.name);
        final bytes = await _compressImage(
          originalBytes,
          extension: extension,
        );
        loaded.add(
          _PickedAdoptionPhoto(
            id: '${DateTime.now().microsecondsSinceEpoch}-${loaded.length}',
            bytes: bytes,
            extension: 'jpg',
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() => _selectedPhotos.addAll(loaded));

      if (picked.length > filesToUse.length) {
        AppToast.show(
          context,
          message: 'Only first $allowed photos were added (max $maxPhotos).',
          type: AppToastType.info,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Failed to pick photos. Please try again.',
        type: AppToastType.error,
      );
    }
  }

  Future<void> _submitPostAndGoToReview() async {
    if (_isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repository = context.read<AdoptionRepository>();

      final uploadedUrls = await repository.uploadAdoptionPhotos(
        files: _selectedPhotos.map((item) => item.bytes).toList(),
        extensions: _selectedPhotos.map((item) => item.extension).toList(),
      );

      await repository.createAdoptionPost(
        petType: _petType!,
        petName: _petNameController.text.trim(),
        breed: _breedController.text.trim(),
        age: _selectedAge!,
        vaccinated: _selectedVaccinated!,
        aboutPet: _aboutController.text.trim(),
        city: _selectedCity!,
        nearbyArea: _nearbyAreaController.text.trim(),
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        photoUrls: uploadedUrls,
      );

      if (!mounted) {
        return;
      }

      setState(() => _step = 5);
    } on AdoptionRepositoryException catch (e) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        message: e.message,
        type: AppToastType.error,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Failed to create adoption post.',
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildPetTypeStep();
      case 1:
        return _buildPhotoStep();
      case 2:
        return _buildPetInfoStep();
      case 3:
        return _buildLocationStep();
      case 4:
        return _buildContactStep();
      case 5:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPetTypeStep() {
    return Column(
      children: [
        Text('Select pet type', style: AppFonts.nunitoBold(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          "Let's start with the basics",
          style: AppFonts.nunitoRegular(fontSize: 12, color: AppColors.grey),
        ),
        const SizedBox(height: 26),
        _petTypeCard('cat', AppIcons.cat),
        const SizedBox(height: 10),
        _petTypeCard('dog', AppIcons.dog),
        const SizedBox(height: 10),
        _petTypeCard('bird', AppIcons.bird),
      ],
    );
  }

  Widget _petTypeCard(String value, String iconAsset) {
    final isSelected = _petType == value;
    final isPressed = _pressedPetType == value;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedPetType = value),
      onTapUp: (_) => setState(() {
        _pressedPetType = null;
        _petType = value;
      }),
      onTapCancel: () => setState(() => _pressedPetType = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          isPressed ? 2 : 0,
          isPressed ? 2 : 0,
          0,
        ),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.black),
          boxShadow: isPressed
              ? []
              : const [
                  BoxShadow(
                    color: AppColors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Image.asset(
            iconAsset,
            width: 65,
            height: 65,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStep() {
    final canAddMore = _selectedPhotos.length < 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('Add photos', style: AppFonts.nunitoBold(fontSize: 24)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'The first photo is the main image. You can add up to 3 photos.',
            textAlign: TextAlign.center,
            style: AppFonts.nunitoRegular(fontSize: 12, color: AppColors.grey),
          ),
        ),
        const SizedBox(height: 18),
        if (_selectedPhotos.isNotEmpty) ...[
          Container(
            width: double.infinity,
            height: 220,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.memory(
                _selectedPhotos.first.bytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Main image (shown first)',
            style: AppFonts.nunitoSemiBold(fontSize: 11, color: AppColors.darkGrey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    itemExtent: 88,
                    itemCount: _selectedPhotos.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _selectedPhotos.removeAt(oldIndex);
                        _selectedPhotos.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final photo = _selectedPhotos[index];
                      return ReorderableDragStartListener(
                        key: ValueKey(photo.id),
                        index: index,
                        child: _PhotoThumb(
                          photo: photo,
                          onRemove: () => setState(
                            () => _selectedPhotos.removeAt(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (canAddMore) ...[
                const SizedBox(width: 8),
                _AddPhotoTile(onTap: _pickPhotos),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Press and drag a photo to reorder',
            style: AppFonts.nunitoRegular(fontSize: 11, color: AppColors.grey),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Align(
            alignment: Alignment.center,
            child: _AddPhotoTile(onTap: _pickPhotos),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap to add photos',
              style: AppFonts.nunitoRegular(fontSize: 11, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildPetInfoStep() {
    return Form(
      key: _petInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Pet Information',
              style: AppFonts.nunitoBold(fontSize: 24),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Tell us more about your pet.',
              style: AppFonts.nunitoRegular(fontSize: 12, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 24),
          _label('Pet Name'),
          _textField(
            controller: _petNameController,
            hint: 'e.g. Stormy',
            validator: _requiredValidator('Pet name'),
          ),
          const SizedBox(height: 16),
          _label('Breed'),
          _textField(
            controller: _breedController,
            hint: 'e.g. Golden Retriever',
            validator: _requiredValidator('Breed'),
          ),
          const SizedBox(height: 16),
          _label('Age'),
          CustomDropdownField(
            value: _selectedAge,
            hintText: 'Select age',
            sheetTitle: 'Select Age',
            options: _ageOptions,
            validator: (value) =>
                value == null ? 'Please select age' : null,
            onChanged: (value) => setState(() => _selectedAge = value),
          ),
          const SizedBox(height: 16),
          _label('Vaccinated'),
          CustomDropdownField(
            value: _selectedVaccinated,
            hintText: 'Is your pet vaccinated?',
            sheetTitle: 'Vaccination Status',
            options: _vaccinationOptions,
            validator: (value) =>
                value == null ? 'Please select vaccination status' : null,
            onChanged: (value) => setState(() => _selectedVaccinated = value),
          ),
          const SizedBox(height: 16),
          _label('About the Pet'),
          _textField(
            controller: _aboutController,
            hint: 'Tell us a bit about your pet...',
            maxLines: 3,
            validator: _requiredValidator('About the pet'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return Form(
      key: _locationFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Location', style: AppFonts.nunitoBold(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Where is the pet located?',
              style: AppFonts.nunitoRegular(fontSize: 12, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 24),
          _label('City'),
          CustomDropdownField(
            value: _selectedCity,
            hintText: 'Select your city',
            sheetTitle: 'Select City',
            options: _cityOptions,
            validator: (value) =>
                value == null ? 'Please select a city' : null,
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
          const SizedBox(height: 16),
          _label('Nearby Area'),
          _textField(
            controller: _nearbyAreaController,
            hint: 'e.g. The Educators, G-8 Markaz',
            validator: _requiredValidator('Nearby area'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    return Form(
      key: _contactFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Contact Details', style: AppFonts.nunitoBold(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'How can adopters reach you?',
              style: AppFonts.nunitoRegular(fontSize: 12, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 24),
          _label('Contact Name'),
          _textField(
            controller: _contactNameController,
            hint: 'e.g. Sarah Stone',
            validator: _requiredValidator('Contact name'),
          ),
          const SizedBox(height: 16),
          _label('Phone Number'),
          _textField(
            controller: _contactPhoneController,
            hint: 'e.g. +1 555 123 4567',
            keyboardType: TextInputType.phone,
            validator: _requiredValidator('Phone number'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.52,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.postUnderReview,
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'Your post is under review.',
              textAlign: TextAlign.center,
              style: AppFonts.nunitoBold(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Our team is making sure your post follows community guidelines. You will be notified once approved.',
              textAlign: TextAlign.center,
              style: AppFonts.nunitoRegular(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: AppFonts.nunitoMedium(fontSize: 12));
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hint,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  String _extensionFrom(String filename) {
    final parts = filename.split('.');
    if (parts.length < 2) {
      return 'jpg';
    }
    return parts.last.toLowerCase();
  }

  Future<Uint8List> _compressImage(
    Uint8List bytes, {
    required String extension,
  }) async {
    try {
      if (kIsWeb) {
        // Web support varies; the picker quality/size options already reduce size.
        return bytes;
      }
      final format = extension == 'png'
          ? CompressFormat.jpeg
          : CompressFormat.jpeg;
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 45,
        minWidth: 1080,
        minHeight: 1080,
        format: format,
      );
      if (compressed.isEmpty) {
        return bytes;
      }
      return Uint8List.fromList(compressed);
    } catch (_) {
      return bytes;
    }
  }

  String? Function(String?) _requiredValidator(String label) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / 6;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  CustomBackButton(
                    onTap: () {
                      if (_step == 0) {
                        NavigatorHelper.pop(context);
                        return;
                      }
                      setState(() => _step -= 1);
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 4,
              width: double.infinity,
              color: AppColors.divider,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  width: MediaQuery.of(context).size.width * progress,
                  color: AppColors.secondary,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 26, 12, 20),
                child: _buildStepContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
              child: CustomButton(
                text: _step == 5
                    ? 'Finish'
                    : _step == 4
                        ? 'Submit'
                        : 'Next',
                isLoading: _isSubmitting,
                onTap: _isSubmitting ? null : _goNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({
    required this.photo,
    required this.onRemove,
  });

  final _PickedAdoptionPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.black),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.memory(photo.bytes, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 4,
            bottom: 4,
            child: Icon(
              Icons.drag_indicator_rounded,
              size: 16,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        height: 84,
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined, size: 24),
              const SizedBox(height: 2),
              Text('ADD', style: AppFonts.nunitoSemiBold(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickedAdoptionPhoto {
  const _PickedAdoptionPhoto({
    required this.id,
    required this.bytes,
    required this.extension,
  });

  final String id;
  final Uint8List bytes;
  final String extension;
}
