import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Active / acknowledged alerts list with the same glass card language as [IncidentsScreen].

const _kChipMuted = Color(0xFF21262D);
const _kAccentBlue = Color(0xFF58A6FF);

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String? _filter;
  late List<_AlertItem> _alerts;

  static const _navClearance = 88.0;

  @override
  void initState() {
    super.initState();
    _alerts = _AlertItem.samples();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == null
        ? List<_AlertItem>.from(_alerts)
        : _alerts.where((e) => e.state == _filter).toList();

    final titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : GlassColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, _navClearance),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alerts', style: titleStyle),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _AlertsFilterChip(
                      isDark: isDark,
                      label: 'All alerts',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    _AlertsFilterChip(
                      isDark: isDark,
                      label: 'Firing',
                      selected: _filter == 'FIRING',
                      onTap: () => setState(
                        () =>
                            _filter = _filter == 'FIRING' ? null : 'FIRING',
                      ),
                    ),
                    _AlertsFilterChip(
                      isDark: isDark,
                      label: 'Acknowledged',
                      selected: _filter == 'ACK',
                      onTap: () => setState(
                        () => _filter = _filter == 'ACK' ? null : 'ACK',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No alerts in this view',
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white54
                                : Colors.black45,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _AlertCard(
                            alert: filtered[index],
                            onAcknowledge: () {
                              setState(() {
                                filtered[index].state = 'ACK';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Acknowledged ${filtered[index].id}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsFilterChip extends StatelessWidget {
  final bool isDark;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AlertsFilterChip({
    required this.isDark,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? _kAccentBlue
        : (isDark ? _kChipMuted : Colors.grey.shade200);
    final fg = selected
        ? Colors.white
        : (isDark ? Colors.white70 : Colors.black54);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : (isDark
                        ? const Color(0xFF30363D)
                        : Colors.black26),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertItem {
  final String id;
  final String title;
  final String service;
  final String severity;
  final String age;
  String state;

  _AlertItem({
    required this.id,
    required this.title,
    required this.service,
    required this.severity,
    required this.age,
    required this.state,
  });

  static List<_AlertItem> samples() {
    return [
      _AlertItem(
        id: 'ALT-9012',
        title: 'CPU > 85% sustained (prod-api)',
        service: 'Auth-Service-V2',
        severity: 'CRITICAL',
        age: '8m ago',
        state: 'FIRING',
      ),
      _AlertItem(
        id: 'ALT-9011',
        title: '5xx rate above SLO',
        service: 'Payment-Gateway',
        severity: 'HIGH',
        age: '22m ago',
        state: 'FIRING',
      ),
      _AlertItem(
        id: 'ALT-9004',
        title: 'Queue depth warning',
        service: 'Event-Bus',
        severity: 'LOW',
        age: '1h ago',
        state: 'ACK',
      ),
      _AlertItem(
        id: 'ALT-8998',
        title: 'Certificate expires in 14d',
        service: 'Edge-TLS',
        severity: 'LOW',
        age: '3h ago',
        state: 'ACK',
      ),
      _AlertItem(
        id: 'ALT-8991',
        title: 'Memory pressure (k8s node)',
        service: 'Cluster-Prod',
        severity: 'HIGH',
        age: '4h ago',
        state: 'FIRING',
      ),
    ];
  }
}

class _AlertCard extends StatelessWidget {
  final _AlertItem alert;
  final VoidCallback onAcknowledge;

  const _AlertCard({required this.alert, required this.onAcknowledge});

  Color _severityColor(String s) {
    switch (s) {
      case 'CRITICAL':
        return Colors.redAccent;
      case 'HIGH':
        return Colors.orangeAccent;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(alert.severity);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firing = alert.state == 'FIRING';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white10
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alert.severity,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (firing ? Colors.redAccent : Colors.blueGrey)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      firing ? 'Firing' : 'Acknowledged',
                      style: TextStyle(
                        color: firing ? Colors.redAccent : Colors.blueGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    alert.age,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                alert.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.storage,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alert.service,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  if (firing)
                    TextButton(
                      onPressed: onAcknowledge,
                      child: const Text('ACKNOWLEDGE'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
