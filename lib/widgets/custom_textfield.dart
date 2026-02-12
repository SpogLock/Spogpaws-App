import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';
import 'package:spogpaws/themes/app_style.dart';

class FieldFocusedCubit extends Cubit<bool> {
  FieldFocusedCubit() : super(false);

  void focus() => emit(true);
  void unfocus() => emit(false);
}

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.backgroundColor,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? hintText;
  final Color? backgroundColor;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  late final FieldFocusedCubit _focusCubit;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusCubit = FieldFocusedCubit();
    _isObscured = widget.obscureText;

    _focusNode.addListener(() {
      if (!mounted) return;
      _focusNode.hasFocus ? _focusCubit.focus() : _focusCubit.unfocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.white;
    const baseBorderColor = AppColors.black;
    final bool isMultiline = widget.maxLines > 1;
    final double fieldHeight = isMultiline ? (24.0 * widget.maxLines) + 18 : 45;

    return FormField<String>(
      validator: widget.validator,
      builder: (field) {
        final hasError = field.hasError;
        final borderColor = hasError ? AppColors.error : baseBorderColor;
        final shadowColor = hasError ? AppColors.error : AppColors.black;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<FieldFocusedCubit, bool>(
              bloc: _focusCubit,
              builder: (context, isFocused) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.translationValues(
                    isFocused ? 2 : 0,
                    isFocused ? 2 : 0,
                    0,
                  ),
                  height: fieldHeight,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                    border: Border.all(color: borderColor),
                    boxShadow: isFocused
                        ? []
                        : [
                            BoxShadow(
                              color: shadowColor,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  alignment: isMultiline ? Alignment.topLeft : Alignment.center,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: _isObscured,
                    maxLines: widget.maxLines,
                    keyboardType: widget.keyboardType,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (value) {
                      field.didChange(value);
                      if (field.hasError) {
                        field.validate();
                      }
                      widget.onChanged?.call(value);
                    },
                    textAlignVertical: isMultiline
                        ? TextAlignVertical.top
                        : TextAlignVertical.center,
                    style: AppFonts.nunitoRegular().copyWith(
                      color: AppColors.black,
                      fontSize: 12,
                    ),
                    cursorColor: AppColors.secondary,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AppFonts.nunitoRegular().copyWith(
                        color: AppColors.grey,
                        fontSize: 12,
                        fontFeatures: [FontFeature.enable('smcp')],
                      ),
                      border: InputBorder.none,
                      isDense: !isMultiline,
                      contentPadding: isMultiline
                          ? const EdgeInsets.only(top: 10)
                          : const EdgeInsets.all(0),
                      errorText: null,
                      suffixIconConstraints: const BoxConstraints(
                        minHeight: 24,
                        minWidth: 24,
                      ),
                      suffixIcon: widget.obscureText && !isMultiline
                          ? IconButton(
                              icon: Icon(
                                _isObscured
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.grey,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _isObscured = !_isObscured),
                            )
                          : null,
                    ),
                  ),
                );
              },
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
}
