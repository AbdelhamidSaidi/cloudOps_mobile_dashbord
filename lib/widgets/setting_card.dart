import 'package:flutter/material.dart';
import 'dart:ui';

class SettingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const SettingCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1AF5F5F5) : const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0x4DF5F5F5) : const Color(0x80E0E5FF),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
