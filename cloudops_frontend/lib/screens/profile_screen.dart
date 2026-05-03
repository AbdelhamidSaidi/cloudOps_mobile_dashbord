import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _api.getProfile();
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _loading
+          ? const Center(child: CircularProgressIndicator())
+          : _user == null
+              ? const Center(child: Text('Failed to load profile'))
+              : SingleChildScrollView(
+                  padding: const EdgeInsets.all(16),
+                  child: Column(
+                    crossAxisAlignment: CrossAxisAlignment.center,
+                    children: [
+                      const SizedBox(height: 12),
+                      CircleAvatar(
+                        radius: 48,
+                        backgroundImage: _user!.avatarUrl != null
+                            ? NetworkImage(_user!.avatarUrl!)
+                            : null,
+                        child: _user!.avatarUrl == null
+                            ? const Icon(Icons.person, size: 48)
+                            : null,
+                      ),
+                      const SizedBox(height: 12),
+                      Text(_user!.name, style: Theme.of(context).textTheme.headlineSmall),
+                      const SizedBox(height: 6),
+                      Chip(label: Text(_user!.role ?? '')),
+                      const SizedBox(height: 12),
+                      Card(
+                        child: Padding(
+                          padding: const EdgeInsets.all(12.0),
+                          child: Column(
+                            crossAxisAlignment: CrossAxisAlignment.start,
+                            children: [
+                              Text('Email', style: Theme.of(context).textTheme.labelLarge),
+                              const SizedBox(height: 4),
+                              Text(_user!.email),
+                              const SizedBox(height: 12),
+                              Text('Location', style: Theme.of(context).textTheme.labelLarge),
+                              const SizedBox(height: 4),
+                              Text(_user!.location ?? ''),
+                              const SizedBox(height: 12),
+                              Text('Joined', style: Theme.of(context).textTheme.labelLarge),
+                              const SizedBox(height: 4),
+                              Text(_user!.joinedAt ?? ''),
+                            ],
+                          ),
+                        ),
+                      ),
+                    ],
+                  ),
+                ),
+    );
  }
}
