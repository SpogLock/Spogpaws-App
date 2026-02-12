import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_colors.dart';
import 'package:spogpaws/themes/app_fonts.dart';

enum AppToastType { success, error, info, warning }

class AppToast {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    Color? backgroundColor,
    Color? borderColor,
    Color? titleColor,
    Color? messageColor,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16),
    double borderRadius = 14,
    bool dismissible = true,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);

    _currentEntry?.remove();
    _currentEntry = OverlayEntry(
      builder: (context) => _AppToastOverlay(
        message: message,
        title: title,
        type: type,
        duration: duration,
        icon: icon,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        titleColor: titleColor,
        messageColor: messageColor,
        margin: margin,
        borderRadius: borderRadius,
        dismissible: dismissible,
        onClose: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.margin,
    required this.borderRadius,
    required this.dismissible,
    required this.onClose,
    this.title,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.titleColor,
    this.messageColor,
  });

  final String message;
  final String? title;
  final AppToastType type;
  final Duration duration;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? titleColor;
  final Color? messageColor;
  final EdgeInsets margin;
  final double borderRadius;
  final bool dismissible;
  final VoidCallback onClose;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _timer = Timer(widget.duration, _hide);
  }

  Future<void> _hide() async {
    if (!mounted) {
      return;
    }
    await _controller.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeForType(widget.type);
    final title = widget.title ?? theme.title;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !widget.dismissible,
        child: Stack(
          children: [
            Positioned(
              left: widget.margin.left,
              right: widget.margin.right,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: GestureDetector(
                onTap: widget.dismissible ? _hide : null,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Material(
                        color: Colors.transparent,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: widget.backgroundColor ?? theme.backgroundColor,
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                            border: Border.all(
                              color: widget.borderColor ?? theme.borderColor,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  widget.icon ?? theme.icon,
                                  size: 20,
                                  color: widget.titleColor ?? theme.titleColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        title,
                                        style: AppFonts.nunitoBold(
                                          fontSize: 13,
                                          color:
                                              widget.titleColor ?? theme.titleColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.message,
                                        style: AppFonts.nunitoMedium(
                                          fontSize: 12,
                                          color:
                                              widget.messageColor ??
                                              theme.messageColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _AppToastTheme _themeForType(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const _AppToastTheme(
          title: 'Success',
          icon: Icons.check_circle_rounded,
          backgroundColor: Color(0xFFEAF8F5),
          borderColor: Color(0xFF8BE0CD),
          titleColor: Color(0xFF14695A),
          messageColor: Color(0xFF14695A),
        );
      case AppToastType.error:
        return const _AppToastTheme(
          title: 'Error',
          icon: Icons.error_rounded,
          backgroundColor: Color(0xFFFDEDED),
          borderColor: Color(0xFFF5B5B5),
          titleColor: Color(0xFF8B1A1A),
          messageColor: Color(0xFF8B1A1A),
        );
      case AppToastType.warning:
        return const _AppToastTheme(
          title: 'Warning',
          icon: Icons.warning_rounded,
          backgroundColor: Color(0xFFFFF7E6),
          borderColor: Color(0xFFFFD68A),
          titleColor: Color(0xFF8A5A00),
          messageColor: Color(0xFF8A5A00),
        );
      case AppToastType.info:
        return const _AppToastTheme(
          title: 'Info',
          icon: Icons.info_rounded,
          backgroundColor: Color(0xFFEFEEFB),
          borderColor: Color(0xFFC6BFE5),
          titleColor: AppColors.secondary,
          messageColor: AppColors.secondary,
        );
    }
  }
}

class _AppToastTheme {
  const _AppToastTheme({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.messageColor,
  });

  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color messageColor;
}
