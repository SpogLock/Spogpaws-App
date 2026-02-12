import 'package:flutter/material.dart';
import 'package:spogpaws/themes/app_style.dart';

class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = AppStyle.surface,
    this.borderColor,
    this.radius = AppStyle.radiusMd,
    this.depth = 2,
    this.padding,
    this.height,
    this.width,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color? borderColor;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final bool enabled;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onTap != null;
    final borderColor =
        widget.borderColor ?? AppStyle.pressDepthColor(widget.backgroundColor);
    final depthShadowColor = AppStyle.pressDepthColor(
      borderColor,
      amount: 0.10,
    );

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(
          _isPressed && isEnabled ? widget.depth : 0,
          _isPressed && isEnabled ? widget.depth : 0,
          0,
        ),
        padding: widget.padding,
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: borderColor),
          boxShadow: _isPressed && isEnabled
              ? const []
              : [
                  BoxShadow(
                    color: depthShadowColor,
                    offset: Offset(widget.depth, widget.depth),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
