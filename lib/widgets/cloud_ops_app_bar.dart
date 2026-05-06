import 'package:flutter/material.dart';
import '../theme.dart';

/// Matches Stitch: blue terminal glyph + CloudOps + optional actions (search / overflow).
class CloudOpsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CloudOpsAppBar({super.key, this.actions});

  static const _accentBlue = Color(0xFF58A6FF);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : GlassColors.lightBg;
    final onBg = Theme.of(context).colorScheme.onSurface;

    return AppBar(
      backgroundColor: bg,
      foregroundColor: onBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _accentBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.terminal, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'CloudOps',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: onBg,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
