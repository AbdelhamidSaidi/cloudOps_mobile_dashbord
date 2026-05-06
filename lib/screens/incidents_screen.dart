import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../widgets/cloud_ops_app_bar.dart';
import '../theme.dart';
import 'incident_detail_screen.dart';

const _kChipMuted = Color(0xFF21262D);
const _kAccentBlue = Color(0xFF58A6FF);
const _kMute = Color(0xFF8B949E);

class IncidentsScreen extends StatefulWidget {
  final List<IncidentData> incidents;
  final ValueChanged<IncidentData>? onIncidentUpdated;

  const IncidentsScreen({
    super.key,
    required this.incidents,
    this.onIncidentUpdated,
  });

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  /// null = all statuses.
  String? _statusBucket;

  /// null = filter off; otherwise CRITICAL or HIGH exclusively.
  String? _severityFilter;

  static const _navClearance = 100.0;
  static const _mute = Color(0xFF8B949E);

  late List<_IncidentView> _localIncidents;

  @override
  void initState() {
    super.initState();
    _localIncidents = _defaultIncidentsFromDesign();
  }

  List<_IncidentView> _source() {
    if (widget.incidents.isEmpty) {
      return _localIncidents;
    }
    return widget.incidents.map((e) {
      final sev = _normalizeSeverityDisplay(e.severity);
      return _IncidentView(
        id: e.id,
        title: e.title,
        service: e.service,
        severity: sev,
        age: e.age,
        status: e.status.toUpperCase(),
      );
    }).toList();
  }

  void _applyUpdatedIncident(IncidentData updated) {
    if (widget.incidents.isNotEmpty) {
      widget.onIncidentUpdated?.call(updated);
      return;
    }
    setState(() {
      final i = _localIncidents.indexWhere((e) => e.id == updated.id);
      if (i == -1) return;
      _localIncidents[i] = _IncidentView(
        id: updated.id,
        title: updated.title,
        service: updated.service,
        severity: _normalizeSeverityDisplay(updated.severity),
        age: updated.age,
        status: updated.status.toUpperCase(),
      );
    });
  }

  String _normalizeSeverityDisplay(String raw) {
    final u = raw.toUpperCase();
    if (u == 'P0' || u.contains('CRITICAL')) return 'CRITICAL';
    if (u == 'P1' || u == 'HIGH') return 'HIGH';
    return 'LOW';
  }

  List<_IncidentView> _defaultIncidentsFromDesign() {
    return [
      _IncidentView(
        id: 'INC-8842',
        title:
            'Database connection pool exhausted in us-east-1',
        service: 'Auth-Service-V2',
        severity: 'CRITICAL',
        age: '14m ago',
        status: 'OPEN',
      ),
      _IncidentView(
        id: 'INC-8840',
        title: 'Latency spikes on /api/v1/payments endpoint',
        service: 'Payment-Gateway',
        severity: 'HIGH',
        age: '1h 22m ago',
        status: 'IN_PROGRESS',
      ),
      _IncidentView(
        id: 'INC-8835',
        title: 'Misconfigured cache header on CDN assets',
        service: 'Static-Assets',
        severity: 'LOW',
        age: '4h ago',
        status: 'RESOLVED',
      ),
      _IncidentView(
        id: 'INC-8831',
        title:
            'S3 Bucket Permission error preventing log ingestion',
        service: 'Logging-Stack',
        severity: 'CRITICAL',
        age: '6h 15m ago',
        status: 'OPEN',
      ),
      _IncidentView(
        id: 'INC-8828',
        title: 'Edge cache TTL mismatch detected',
        service: 'Static-Assets',
        severity: 'HIGH',
        age: '5h ago',
        status: 'IN_PROGRESS',
      ),
    ];
  }

  Iterable<_IncidentView> _filtered(Iterable<_IncidentView> rows) sync* {
    for (final r in rows) {
      // Status gates
      if (_statusBucket == 'OPEN') {
        if (r.status != 'OPEN') continue;
      } else if (_statusBucket == 'IP') {
        if (r.status != 'IN_PROGRESS') continue;
      }

      // Severity chip (narrow to critical / high)
      if (_severityFilter != null &&
          _severityFilter != _mapSeverityChip(r.severity)) {
        continue;
      }

      yield r;
    }
  }

  String? _mapSeverityChip(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return 'CRITICAL';
      case 'HIGH':
        return 'HIGH';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : GlassColors.lightBg;
    final all = _source();
    final list = _filtered(all).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: CloudOpsAppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FiltersRow(isDark: isDark, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filters (coming soon)')),
                );
              }),
              const SizedBox(height: 12),
              _StatusChipsRow(
                isDark: isDark,
                statusBucket: _statusBucket,
                onPick: (c) => setState(() {
                  if (c == null) {
                    _statusBucket = null;
                  } else {
                    _statusBucket = _statusBucket == c ? null : c;
                  }
                }),
              ),
              const SizedBox(height: 10),
              _SeverityChipsRow(
                isDark: isDark,
                selected: _severityFilter,
                onPick: (c) =>
                    setState(() => _severityFilter = c == _severityFilter ? null : c),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          'No incidents match the current filters.',
                          style: TextStyle(color: _mute.withValues(alpha: 0.8)),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: _navClearance),
                        itemCount: list.length + 1,
                        itemBuilder: (ctx, index) {
                          if (index == list.length) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 72),
                              child: Column(
                                children: [
                                  Divider(
                                    height: 1,
                                    color: _mute.withValues(alpha: 0.35),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'END OF INCIDENT STREAM',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1.6,
                                      fontWeight: FontWeight.w600,
                                      color: _mute.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StitchIncidentCard(
                              view: list[index],
                              onUpdated: _applyUpdatedIncident,
                            ),
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

class _IncidentView {
  final String id;
  final String title;
  final String service;
  final String severity;
  final String age;
  final String status;

  _IncidentView({
    required this.id,
    required this.title,
    required this.service,
    required this.severity,
    required this.age,
    required this.status,
  });
}

class _FiltersRow extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _FiltersRow({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        Icons.filter_list,
        size: 18,
        color: isDark ? _kMute : Colors.black54,
      ),
      label: Text(
        'FILTERS',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        side: BorderSide(
          color: isDark ? const Color(0xFF30363D) : Colors.black26,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatusChipsRow extends StatelessWidget {
  final bool isDark;
  final String? statusBucket;

  /// 'ALL' bucket null semantics; OPEN; IN_PROGRESS keyed as IP
  final ValueChanged<String?> onPick;

  const _StatusChipsRow({
    required this.isDark,
    required this.statusBucket,
    required this.onPick,
  });

  Widget _chip(String label, {bool all = false, String? bucket}) {
    final selected = all
        ? statusBucket == null
        : statusBucket == bucket;
    final bg =
        selected ? _kAccentBlue : (isDark ? _kChipMuted : Colors.grey.shade200);
    final fg = selected ? Colors.white : (isDark ? Colors.white70 : Colors.black54);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => all ? onPick(null) : onPick(bucket),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? Colors.transparent : const Color(0xFF30363D),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('STATUS: ALL', all: true),
          _chip('OPEN', bucket: 'OPEN'),
          _chip('IN_PROGRESS', bucket: 'IP'),
        ],
      ),
    );
  }
}

class _SeverityChipsRow extends StatelessWidget {
  final bool isDark;
  final String? selected;
  final ValueChanged<String?> onPick;

  const _SeverityChipsRow({
    required this.isDark,
    required this.selected,
    required this.onPick,
  });

  Widget _tier(String label) {
    final isSel = selected == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPick(isSel ? null : label),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? _kChipMuted : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSel ? _kAccentBlue : const Color(0xFF30363D),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSel
                    ? _kAccentBlue
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tier('CRITICAL'),
        _tier('HIGH'),
      ],
    );
  }
}

/// Glass-ish card matching Stitch: accent rail, badges, avatars in footer.
class _StitchIncidentCard extends StatelessWidget {
  final _IncidentView view;
  final ValueChanged<IncidentData> onUpdated;

  const _StitchIncidentCard({
    required this.view,
    required this.onUpdated,
  });

  Color _railColor(String s) {
    switch (s) {
      case 'CRITICAL':
        return Colors.redAccent.shade200;
      case 'HIGH':
        return Colors.orangeAccent.shade200;
      default:
        return const Color(0xFF79C0FF);
    }
  }

  Color _statusOutline(String status) =>
      status == 'RESOLVED'
          ? const Color(0xFF79C0FF)
          : _railColor(view.severity);

  IconData _serviceIcon(String service) {
    final s = service.toLowerCase();
    if (s.contains('payment')) return Icons.payment;
    if (s.contains('static') || s.contains('cdn')) return Icons.cloud;
    if (s.contains('logging') || s.contains('bucket')) return Icons.dns;
    if (s.contains('auth')) return Icons.security;
    return Icons.storage;
  }

  @override
  Widget build(BuildContext context) {
    final incidentData = IncidentData(
      id: view.id,
      title: view.title,
      service: view.service,
      severity: view.severity,
      age: view.age,
      status: view.status,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rail = _railColor(view.severity);
    final badgeBorder = _statusOutline(view.status);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.of(context).push<IncidentData?>(
          MaterialPageRoute(
            builder: (_) =>
                IncidentDetailScreen(incident: incidentData),
          ),
        );
        if (updated == null) return;
        onUpdated(updated);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                updated.status.toUpperCase() == 'RESOLVED'
                    ? 'Marked ${updated.id} as resolved'
                    : 'Escalated ${updated.id} to ${updated.severity}',
              ),
            ),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF161B22)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    const Color(0xFF30363D).withValues(alpha: isDark ? 1 : 0.2),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: rail,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${view.id} • ',
                                        style: TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 12,
                                          color:
                                              rail.withValues(alpha: 0.95),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: view.severity,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: rail,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: badgeBorder.withValues(alpha: 0.9),
                                  ),
                                  color: badgeBorder.withValues(alpha: 0.12),
                                ),
                                child: Text(
                                  view.status.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 0.6,
                                    fontWeight: FontWeight.w700,
                                    color: badgeBorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            view.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                _serviceIcon(view.service),
                                size: 16,
                                color: _kMute,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  view.service,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        isDark ? _kMute : Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: _kMute,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                view.age,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _kMute,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewIncidentModal extends StatefulWidget {
  const NewIncidentModal({super.key});

  @override
  State<NewIncidentModal> createState() => _NewIncidentModalState();
}

class _NewIncidentModalState extends State<NewIncidentModal> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _priority = 'P0 - Critical Impact';
  String? _pickedService;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12, width: 1.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Declare New Incident',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Initiate a critical response workflow. Ensure priority reflects impact.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Incident Title',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      hintText:
                          'e.g., Auth-Service API Latency Spike',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Full Description',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Describe the symptoms, observed behavior...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Priority Level',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _priority,
                              items: [
                                'P0 - Critical Impact',
                                'P1 - High',
                                'P2 - Medium',
                                'P3 - Low',
                              ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _priority = v ?? _priority),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Impacted Service',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _pickedService,
                    decoration: const InputDecoration(
                      hintText: 'Select a service...',
                    ),
                    items: [
                      'Auth-Service-V2',
                      'Payment-Gateway',
                      'Logging-Stack',
                      'Static-Assets',
                    ]
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _pickedService = v),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Incident created (mock)'),
                            ),
                          );
                        },
                        child: const Text('CREATE INCIDENT'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}