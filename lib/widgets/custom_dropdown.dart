import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';

class CustomDropdownField extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.options,
    this.value,
    this.hintText,
    this.sheetTitle,
    this.onChanged,
    this.validator,
  });

  final List<String> options;
  final String? value;
  final String? hintText;
  final String? sheetTitle;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  bool _isPressed = false;

  Future<String?> _openSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DropdownOptionsSheet(
          options: widget.options,
          selectedValue: widget.value,
          title: widget.sheetTitle ?? 'Select an option',
        );
      },
    );

    if (selected != null) {
      widget.onChanged?.call(selected);
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _darken(AppColors.black, 0.25);
    final isEnabled = widget.onChanged != null;
    final displayText = widget.value ?? widget.hintText ?? 'Select';
    final isHint = widget.value == null;

    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (field) {
        final hasError = field.hasError;
        final activeBorderColor = hasError ? AppColors.error : borderColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
              onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
              onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
              onTap: isEnabled ? () async {
                final selected = await _openSheet();
                if (selected != null) {
                  field.didChange(selected);
                }
                if (field.hasError) {
                  field.validate();
                }
              } : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(
                  _isPressed && isEnabled ? 2 : 0,
                  _isPressed && isEnabled ? 2 : 0,
                  0,
                ),
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isEnabled ? AppColors.white : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeBorderColor),
                  boxShadow: _isPressed && isEnabled
                      ? []
                      : [
                          BoxShadow(
                            color: activeBorderColor,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText,
                        style: AppFonts.nunitoRegular(
                          fontSize: 12,
                          color: isEnabled
                              ? (isHint ? AppColors.grey : AppColors.black)
                              : AppColors.darkGrey,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.darkGrey,
                    ),
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  field.errorText!,
                  style: AppFonts.nunitoRegular().copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

class _DropdownOptionsSheet extends StatelessWidget {
  const _DropdownOptionsSheet({
    required this.options,
    required this.selectedValue,
    required this.title,
  });

  final List<String> options;
  final String? selectedValue;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 14),
            Text(title, style: AppFonts.nunitoBold(fontSize: 18)),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == selectedValue;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.of(context).pop(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.secondary.withValues(alpha: 0.08)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: AppFonts.nunitoMedium(
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.black,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
