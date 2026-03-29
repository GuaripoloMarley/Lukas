import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width, height;
  final EdgeInsetsGeometry? padding, margin;
  final double blur, opacity;
  final BorderRadius? borderRadius;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.blur = 10,
    this.opacity = 0.05,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withAlpha((opacity * 255).round()),
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withAlpha(64)
                  : Colors.black.withAlpha(38),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
