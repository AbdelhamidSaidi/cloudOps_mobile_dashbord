import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../widgets/cloud_ops_app_bar.dart';
import '../theme.dart';

/// Stitch-style dashboard: System Overview, KPI cards, incident trends chart,
/// severity breakdown ring, recent alerts — images 1–3.
class DashboardScreen extends StatefulWidget {
  final List<IncidentData> incidents;

  /// Switches shell to Alerts tab (optional).
  final VoidCallback? onViewAllAlerts;

  /// Switches shell to Incidents tab (optional).
  final VoidCallback? onOpenIncidents;

  const DashboardScreen({
    super.key,
    required this.incidents,
    this.onViewAllAlerts,
    this.onOpenIncidents,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _Ds {
  static const canvas = Color(0xFF0D1117);
  static const card = Color(0xFF161B22);
  static const accent = Color(0xFF58A6FF);
  static const coral = Color(0xFFF87171);
  static const amber = Color(0xFFFBBF24);
  static const mute = Color(0xFF8B949E);
  static const segmentHigh = Color(0xFF6E7681);
  static const track = Color(0xFF21262D);
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _trend24h = true;

  static const _navClearance = 88.0;

  int _openIncidentsKpi() {
    if (widget.incidents.isEmpty) return 12;
    return widget.incidents.where((e) => e.status != 'RESOLVED').length;
  }

  int _criticalAlertsKpi() {
    if (widget.incidents.isEmpty) return 3;
    return widget.incidents
        .where(
          (e) =>
              e.status != 'RESOLVED' &&
              (e.severity == 'CRITICAL' || e.severity == 'P0'),
        )
        .length;
  }

  ({int p1, int p2, int p3, int total}) _prioritySplit() {
    final list = widget.incidents;
    if (list.isEmpty) {
      return (p1: 3, p2: 5, p3: 4, total: 12);
    }
    var p1 = 0, p2 = 0, p3 = 0;
    for (final e in list) {
      if (e.status == 'RESOLVED') continue;
      final s = e.severity.toUpperCase();
      if (s.contains('CRITICAL') || s == 'P0') {
        p1++;
      } else if (s == 'HIGH' || s == 'P1') {
        p2++;
      } else {
        p3++;
      }
    }
    final total = p1 + p2 + p3;
    if (total == 0) return (p1: 3, p2: 5, p3: 4, total: 12);
    return (p1: p1, p2: p2, p3: p3, total: total);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _Ds.canvas : GlassColors.lightBg;
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final split = _prioritySplit();

    return Scaffold(
      backgroundColor: bg,
      appBar: CloudOpsAppBar(
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, _navClearance),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: onSurf,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Real-time health and operational metrics across all clusters.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: isDark ? _Ds.mute : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              _UpdatedStrip(isDark: isDark),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: widget.onOpenIncidents,
                child: _AccentMetricCard(
                  isDark: isDark,
                  accent: _Ds.amber,
                  label: 'OPEN INCIDENTS',
                  value: '${_openIncidentsKpi()}',
                  footer: '+2 since last hour',
                  footerColor: _Ds.amber,
                  icon: Icons.emergency_outlined,
                ),
              ),
              const SizedBox(height: 12),
              _AccentMetricCard(
                isDark: isDark,
                accent: _Ds.accent,
                label: 'SLA COMPLIANCE',
                value: '98.5%',
                footer: 'Target: 99.9%',
                footerColor: _Ds.accent,
                icon: Icons.verified_outlined,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: widget.onViewAllAlerts,
                child: _AccentMetricCard(
                  isDark: isDark,
                  accent: const Color(0xFFFF7B72),
                  label: 'CRITICAL ALERTS',
                  value: '${_criticalAlertsKpi()}',
                  footer: 'Active notifications',
                  footerColor: isDark ? _Ds.mute : Colors.black54,
                  icon: Icons.adjust,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? _Ds.card
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? _Ds.segmentHigh.withValues(alpha: 0.35)
                        : GlassColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Incident Trends',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: onSurf,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _trend24h
                                    ? '24-hour frequency distribution'
                                    : '7-day frequency distribution',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? _Ds.mute : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: _Ds.track,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MiniSeg(
                                label: '24H',
                                sel: _trend24h,
                                onTap: () => setState(() => _trend24h = true),
                              ),
                              _MiniSeg(
                                label: '7D',
                                sel: !_trend24h,
                                onTap: () => setState(() => _trend24h = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: _GridLinePainter(
                                isDark: isDark,
                                wide: !_trend24h,
                              ),
                            ),
                            CustomPaint(
                              painter: _TrendFillPainter(
                                accent: _Ds.accent,
                                wide: !_trend24h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _PriorityCard(isDark: isDark, split: split),
              const SizedBox(height: 18),
              _RecentAlertsCard(
                isDark: isDark,
                onSurface: onSurf,
                onViewAll: widget.onViewAllAlerts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdatedStrip extends StatelessWidget {
  final bool isDark;

  const _UpdatedStrip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? _Ds.card : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? _Ds.segmentHigh.withValues(alpha: 0.35)
              : GlassColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _Ds.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Updated 2m ago',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: isDark ? _Ds.mute : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSeg extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;

  const _MiniSeg({required this.label, required this.sel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF384047) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : _Ds.mute,
          ),
        ),
      ),
    );
  }
}

class _AccentMetricCard extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final String label;
  final String value;
  final String footer;
  final Color footerColor;
  final IconData icon;

  const _AccentMetricCard({
    required this.isDark,
    required this.accent,
    required this.label,
    required this.value,
    required this.footer,
    required this.footerColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: isDark ? _Ds.card : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? _Ds.segmentHigh.withValues(alpha: 0.35)
                      : GlassColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: isDark ? _Ds.mute : Colors.black54,
                          ),
                        ),
                      ),
                      Icon(icon, size: 22, color: accent),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: onSurf,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    footer,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: footerColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final bool isDark;
  final ({int p1, int p2, int p3, int total}) split;

  const _PriorityCard({required this.isDark, required this.split});

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;
    final f1 = split.p1 / split.total;
    final f2 = split.p2 / split.total;
    final f3 = split.p3 / split.total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _Ds.card : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? _Ds.segmentHigh.withValues(alpha: 0.35)
              : GlassColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: onSurf,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current open incidents by severity',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? _Ds.mute : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(120),
                    painter: _SquareRingPainter(
                      fractions: [f1, f2, f3],
                      colors: [_Ds.coral, _Ds.amber, _Ds.segmentHigh],
                      strokeWidth: 10,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${split.total}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: onSurf,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _Ds.mute : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LegendRow(
            color: _Ds.coral,
            label: 'P1 - Critical',
            value: '${split.p1}',
          ),
          const SizedBox(height: 8),
          _LegendRow(
            color: _Ds.amber,
            label: 'P2 - High',
            value: '${split.p2}',
          ),
          const SizedBox(height: 8),
          _LegendRow(
            color: _Ds.segmentHigh,
            label: 'P3 - Routine',
            value: '${split.p3}',
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final onSurf = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14, color: onSurf)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: onSurf,
          ),
        ),
      ],
    );
  }
}

class _RecentAlertsCard extends StatelessWidget {
  final bool isDark;
  final Color onSurface;
  final VoidCallback? onViewAll;

  const _RecentAlertsCard({
    required this.isDark,
    required this.onSurface,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _Ds.card : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? _Ds.segmentHigh.withValues(alpha: 0.35)
              : GlassColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Alerts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: _Ds.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          _RichAlertTile(
            isDark: isDark,
            icon: Icons.dns,
            iconBg: Color(0xFF7F1D1D),
            title: 'Database Cluster Latency Spike',
            time: '09:42 AM',
            body:
                'AWS-USEAST-1: Production RDS instance reporting >500ms latency. Auto-scaling triggered.',
            tags: const [('CRITICAL', Color(0xFFF87171)), ('DB-RDS', null)],
          ),
          const Divider(height: 24, color: Color(0xFF30363D)),
          _RichAlertTile(
            isDark: isDark,
            icon: Icons.cloud_outlined,
            iconBg: Color(0xFF1F3D5C),
            title: 'Deployment Completed: Auth-Service',
            time: '08:15 AM',
            body:
                'Version v2.4.1 deployed successfully to 48 nodes. No errors detected post-rollout.',
            tags: const [('CI/CD', null)],
          ),
        ],
      ),
    );
  }
}

class _RichAlertTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String time;
  final String body;
  final List<(String tag, Color? bg)> tags;

  const _RichAlertTile({
    required this.isDark,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.time,
    required this.body,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: _Ds.mute),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark ? _Ds.mute : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags.map((t) {
                      final custom = t.$2;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              custom ??
                              (isDark
                                  ? const Color(0xFF30363D)
                                  : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                          border: t.$1 == 'CRITICAL'
                              ? Border.all(
                                  color: _Ds.coral.withValues(alpha: 0.5),
                                )
                              : null,
                        ),
                        child: Text(
                          t.$1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: custom != null
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Segmented stroke ring for the priority breakdown.
///
/// Uses [Canvas.drawArc] instead of [Path.computeMetrics] because on Flutter
/// Web the latter often yields **no** [PathMetric] for RRect paths, which
/// throws when reading the first metric and leaves the chart blank.
class _SquareRingPainter extends CustomPainter {
  final List<double> fractions;
  final List<Color> colors;
  final double strokeWidth;

  _SquareRingPainter({
    required this.fractions,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fractions.isEmpty || colors.isEmpty) return;
    final sum = fractions.fold<double>(0, (a, b) => a + b);
    if (sum <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2 - 2;
    if (radius <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    for (var i = 0; i < fractions.length; i++) {
      final t = fractions[i] / sum;
      final fullSweep = 2 * math.pi * t;
      // Slightly shorten each arc so rounded caps read as separate segments.
      final sweep = fullSweep * 0.97;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += fullSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SquareRingPainter oldDelegate) {
    return oldDelegate.fractions != fractions ||
        oldDelegate.colors != colors ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _GridLinePainter extends CustomPainter {
  final bool isDark;
  final bool wide;

  _GridLinePainter({required this.isDark, required this.wide});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? _Ds.card : Colors.white.withValues(alpha: 0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      Paint()..color = bg,
    );

    final grid = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), grid);
    }

    final labels = wide
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['00:00', '06:00', '12:00', '18:00', '23:59'];
    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final textStyle = TextStyle(fontSize: 10, color: _Ds.mute);

    for (var i = 0; i < labels.length; i++) {
      final x = 12.0 + (size.width - 24) * i / (labels.length - 1);
      tp.text = TextSpan(text: labels[i], style: textStyle);
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 20));
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.wide != wide;
}

class _TrendFillPainter extends CustomPainter {
  final Color accent;
  final bool wide;

  _TrendFillPainter({required this.accent, required this.wide});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - 32;
    final h = size.height - 36;

    late List<double> ys;
    if (wide) {
      // 7-day trend: intentionally more variation than 24H to feel distinct.
      ys = [0.78, 0.55, 0.66, 0.42, 0.72, 0.36, 0.58];
    } else {
      ys = [0.82, 0.78, 0.74, 0.65, 0.58, 0.72, 0.35];
    }
    final dx = w / (ys.length - 1);
    final path = Path();
    path.moveTo(16, size.height - 24);
    for (var i = 0; i < ys.length; i++) {
      path.lineTo(16 + i * dx, 16 + h * ys[i]);
    }
    path.lineTo(16 + w, size.height - 24);
    path.close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.35),
          accent.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fill);

    final line = Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final linePath = Path();
    for (var i = 0; i < ys.length; i++) {
      final pt = Offset(16 + i * dx, 16 + h * ys[i]);
      if (i == 0) {
        linePath.moveTo(pt.dx, pt.dy);
      } else {
        linePath.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(linePath, line);
  }

  @override
  bool shouldRepaint(covariant _TrendFillPainter oldDelegate) =>
      oldDelegate.wide != wide;
}
