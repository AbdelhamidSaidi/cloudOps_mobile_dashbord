import 'package:flutter/material.dart';
import 'dart:ui';

class ThemeTile extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const ThemeTile({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: active
                  ? (isDark ? const Color(0x3DF5F5F5) : const Color(0x4DFFFFFF))
                  : (isDark
                        ? const Color(0x1AF5F5F5)
                        : const Color(0x26FFFFFF)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? Theme.of(context).colorScheme.secondary
                    : (isDark
                          ? const Color(0x4DF5F5F5)
                          : const Color(0x80E0E5FF)),
                width: active ? 2 : 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? Icons.nights_stay : Icons.wb_sunny,
                  size: 40,
                  color: active
                      ? Theme.of(context).colorScheme.secondary
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
