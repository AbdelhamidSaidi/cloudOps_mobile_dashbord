import 'dart:ui';

import 'package:flutter/material.dart';

class AddIncidentPage extends StatefulWidget {
  final Function(
    String title,
    String description,
    String priority,
    String service,
  )
  onAddIncident;

  const AddIncidentPage({super.key, required this.onAddIncident});

  @override
  State<AddIncidentPage> createState() => _AddIncidentPageState();
}

class _AddIncidentPageState extends State<AddIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'P0 - Critical Impact';
  String? _service;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAddIncident(
      _titleCtrl.text.trim(),
      _descCtrl.text.trim(),
      _priority,
      _service ?? '',
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Incident created!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0a0e27)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Declare New Incident'),
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF0a0e27)
            : const Color(0xFFF5F7FA),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12, width: 1.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Initiate a critical response workflow. Ensure the priority reflects the current user impact and service degradation.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Incident Title',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Title required'
                            : null,
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
                      Expanded(
                        child: TextFormField(
                          controller: _descCtrl,
                          maxLines: null,
                          expands: true,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Description required'
                              : null,
                          decoration: const InputDecoration(
                            hintText:
                                'Describe the symptoms, observed behavior...',
                          ),
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
                                  onChanged: (v) => setState(
                                    () => _priority = v ?? _priority,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Impacted Service',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _service,
                                  hint: const Text('Select a service...'),
                                  items:
                                      [
                                            'Auth-Service-V2',
                                            'Payment-Gateway',
                                            'Logging-Stack',
                                            'Static-Assets',
                                          ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  validator: (v) =>
                                      v == null ? 'Select a service' : null,
                                  onChanged: (v) =>
                                      setState(() => _service = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('CANCEL'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _submit,
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
        ),
      ),
    );
  }
}
