import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(
                  context,
                ).colorScheme.secondary.withAlpha((0.12 * 255).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.nights_stay : Icons.wb_sunny,
              size: 36,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
