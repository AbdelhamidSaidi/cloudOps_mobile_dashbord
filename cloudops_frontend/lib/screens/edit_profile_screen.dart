import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/user.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();
  final ApiService _api = ApiService();
  bool _saving = false;
  String? _selectedCountry;
  String? _selectedCity;

  final Map<String, List<String>> _countryCities = {
    'United States': ['Austin', 'San Francisco', 'New York'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    'United Kingdom': ['London', 'Manchester', 'Bristol'],
  };

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    if (u != null) {
      _nameCtrl.text = u.name;
      _roleCtrl.text = u.role ?? '';
      final loc = u.location ?? '';
      if (loc.contains(',')) {
        final parts = loc.split(',').map((s) => s.trim()).toList();
        if (parts.isNotEmpty) _selectedCity = parts[0];
        if (parts.length > 1) _selectedCountry = parts[1];
      } else if (loc.isNotEmpty) {
        _selectedCity = loc;
      }
      _avatarCtrl.text = u.avatarUrl ?? '';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updates = <String, dynamic>{};
    updates['name'] = _nameCtrl.text.trim();
    updates['role'] = _roleCtrl.text.trim();
    if (_selectedCountry != null && _selectedCity != null) {
      updates['location'] = '$_selectedCity, $_selectedCountry';
    } else if (_selectedCity != null) {
      updates['location'] = _selectedCity!.trim();
    }
    final avatar = _avatarCtrl.text.trim();
    if (avatar.isNotEmpty) updates['avatar_url'] = avatar;

    final user = await _api.updateProfile(updates);
    setState(() => _saving = false);
    if (user != null) {
      if (!mounted) return;
      Navigator.pop(context, user);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: isDark
            ? const Color(0x1AF5F5F5)
            : const Color(0x26FFFFFF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x1AF5F5F5)
                    : const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0x4DF5F5F5)
                      : const Color(0x80E0E5FF),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _roleCtrl,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 12),
                  // Country selector
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Country'),
                    value: _selectedCountry,
                    items: _countryCities.keys
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCountry = v;
                        // reset city to first option when country changes
                        final cities = _countryCities[v];
                        _selectedCity = (cities != null && cities.isNotEmpty)
                            ? cities.first
                            : null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // City selector
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'City'),
                    value: _selectedCity,
                    items: _selectedCountry == null
                        ? <DropdownMenuItem<String>>[]
                        : _countryCities[_selectedCountry]!
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                    onChanged: _selectedCountry == null
                        ? null
                        : (v) => setState(() => _selectedCity = v),
                    hint: const Text('Select city'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _avatarCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Avatar URL',
                      helperText: 'Paste a public image URL or leave empty',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SAVE CHANGES'),
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
