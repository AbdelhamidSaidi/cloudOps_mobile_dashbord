import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  /// When null, defaults to shield icon (generic section).
  final Widget? leading;

  const SectionHeader({super.key, required this.title, this.leading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ??
              Icon(
                Icons.shield,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
