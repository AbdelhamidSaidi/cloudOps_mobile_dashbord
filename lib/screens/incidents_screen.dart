import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentsScreen extends StatefulWidget {
  final List<IncidentData> incidents;
  
  const IncidentsScreen({super.key, required this.incidents});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    final items = widget.incidents.isEmpty 
        ? List.generate(6, (i) => _Incident.mock(i + 1))
        : widget.incidents.map((e) => _Incident(e.id, e.title, e.service, e.severity, e.age)).toList();
    
    final filtered = _selectedPriority == null
        ? items
        : items.where((e) => e.severity == _selectedPriority).toList();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Incidents',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              // Priority filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['CRITICAL', 'HIGH', 'LOW'].map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(priority),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPriority = selected ? priority : null;
                          });
                        },
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white30,
                          width: isSelected ? 2 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No incidents with priority "$_selectedPriority"',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final it = filtered[index];
                          return _IncidentCard(incident: it);
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

class _Incident {
  final String id;
  final String title;
  final String service;
  final String severity;
  final String age;

  _Incident(this.id, this.title, this.service, this.severity, this.age);

  factory _Incident.mock(int i) {
    final sev = i % 3 == 0 ? 'CRITICAL' : (i % 3 == 1 ? 'HIGH' : 'LOW');
    return _Incident(
      'INC-88${i + 10}',
      'Sample incident title #$i',
      ['Auth-Service-V2', 'Payment-Gateway', 'Static-Assets'][i % 3],
      sev,
      '${i * 2}h ago',
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final _Incident incident;

  const _IncidentCard({required this.incident});

  Color _severityColor(String s, BuildContext context) {
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
    final color = _severityColor(incident.severity, context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
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
                      incident.severity,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      incident.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    incident.age,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.storage, size: 16, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(
                    incident.service,
                    style: const TextStyle(color: Colors.white70),
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

class NewIncidentModal extends StatefulWidget {
  const NewIncidentModal({super.key});

  @override
  State<NewIncidentModal> createState() => _NewIncidentModalState();
}

class _NewIncidentModalState extends State<NewIncidentModal> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _priority = 'P0 - Critical Impact';
  String _service = 'Select a service...';

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
                  : Colors.white.withValues(alpha: 0.06),
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
                      hintText: 'e.g., Auth-Service API Latency Spike',
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
                      hintText: 'Describe the symptoms, observed behavior...',
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
                              items:
                                  [
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
                    initialValue: null,
                    hint: const Text('Select a service...'),
                    items:
                        [
                              'Auth-Service-V2',
                              'Payment-Gateway',
                              'Logging-Stack',
                              'Static-Assets',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _service = v ?? _service),
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
                          // placeholder - in real app we'd send to backend
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Incident created (mock)'),
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
