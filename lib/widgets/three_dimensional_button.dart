import 'package:flutter/material.dart';

class Button3D extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color shadowColor;
  final VoidCallback onTap;

  const Button3D({
    super.key,
    required this.child,
    required this.baseColor,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double depth = 4.0;
    const double buttonHeight = 60.0;
    const double buttonWidth = 64.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: SizedBox(
        // Ensure the container is tall enough for the movement
        height: buttonHeight + depth,
        width: buttonWidth,
        child: Stack(
          alignment: Alignment.bottomCenter, // Aligns everything to the bottom
          children: [
            // 1. The Shadow Layer (Background)
            Container(
              height: buttonHeight,
              width: buttonWidth,
              decoration: BoxDecoration(
                color: widget.shadowColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            // 2. The Animated Top Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              curve: Curves.easeInOut,
              // When pressed, it sits at bottom (0).
              // When not pressed, it sits 'depth' pixels above the bottom.
              bottom: _isPressed ? 0 : depth,
              child: Container(
                height: buttonHeight,
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: widget.baseColor,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: const Color.fromARGB(255, 31, 212, 176),
                    width: 2,
                  ),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
