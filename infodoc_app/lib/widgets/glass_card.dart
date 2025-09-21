import 'package:flutter/material.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? blur;
  final double? opacity;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isCircular;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.blur,
    this.opacity,
    this.boxShadow,
    this.onTap,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: isCircular
              ? BorderRadius.circular(50)
              : (borderRadius ?? BorderRadius.circular(20)),
          boxShadow:
              boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
        ),
        child: ClipRRect(
          borderRadius: isCircular
              ? BorderRadius.circular(50)
              : (borderRadius ?? BorderRadius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur ?? 15, sigmaY: blur ?? 15),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (backgroundColor ?? Colors.white).withOpacity(
                  opacity ?? 0.2,
                ),
                borderRadius: isCircular
                    ? BorderRadius.circular(50)
                    : (borderRadius ?? BorderRadius.circular(20)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? blur;
  final double? opacity;
  final bool isCircular;

  const GlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.blur,
    this.opacity,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: isCircular
              ? BorderRadius.circular(50)
              : (borderRadius ?? BorderRadius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: isCircular
              ? BorderRadius.circular(50)
              : (borderRadius ?? BorderRadius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
            child: Container(
              decoration: BoxDecoration(
                color: (backgroundColor ?? Colors.white).withOpacity(
                  opacity ?? 0.25,
                ),
                borderRadius: isCircular
                    ? BorderRadius.circular(50)
                    : (borderRadius ?? BorderRadius.circular(25)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
