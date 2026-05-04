import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../widgets/setting_card.dart';
import '../widgets/section_header.dart';
import '../widgets/theme_tile.dart';
import '../theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();
  User? _user;
  bool _loading = true;
  bool _darkActive = true;
  late VoidCallback _themeListener;
  bool _criticalAlerts = true;
  bool _weeklyReport = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _darkActive = ThemeService.darkMode.value;
    _themeListener = () {
      if (mounted) setState(() => _darkActive = ThemeService.darkMode.value);
    };
    ThemeService.darkMode.addListener(_themeListener);
  }

  @override
  void dispose() {
    ThemeService.darkMode.removeListener(_themeListener);
    super.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? GlassColors.darkBg : GlassColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0x1AF5F5F5)
            : const Color(0x26FFFFFF),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(),
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x2DF5F5F5)
                        : const Color(0x4DFFFFFF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x4DF5F5F5)
                          : const Color(0x80E0E5FF),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.cloud, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('CloudOps'),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingCard(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Framed avatar with edit badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF111827)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0x4DF5F5F5)
                                      : const Color(0x80E0E5FF),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _user?.avatarUrl != null
                                    ? Image.network(
                                        _user!.avatarUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: isDark
                                            ? const Color(0x4DF5F5F5)
                                            : const Color(0x80E0E5FF),
                                        child: const Icon(
                                          Icons.person,
                                          size: 48,
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0x4DF5F5F5)
                                          : const Color(0x80E0E5FF),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _user?.name ?? '',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0x4DF5F5F5)
                                : const Color(0x80E0E5FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_user?.role ?? ''),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _user?.email ?? '',
                          style: const TextStyle(fontFamily: 'Courier'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Row(
                                children: const [
                                  Icon(Icons.location_on, size: 14),
                                  SizedBox(width: 6),
                                  Text('Austin, TX (UTC-6)'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Row(
                                children: const [
                                  Icon(Icons.calendar_today, size: 14),
                                  SizedBox(width: 6),
                                  Text('Joined Jan 2022'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final updated = await Navigator.push<User?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(user: _user),
                              ),
                            );
                            if (updated != null) {
                              setState(() => _user = updated);
                            }
                          },
                          child: const Text('EDIT PROFILE'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const SectionHeader(title: 'Notification Settings'),
                  SettingCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.notifications_active),
                          title: const Text('Critical Incident Alerts'),
                          subtitle: const Text(
                            'Push notifications for P0/P1 incidents',
                          ),
                          trailing: Switch(
                            value: _criticalAlerts,
                            onChanged: (v) =>
                                setState(() => _criticalAlerts = v),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_view_week),
                          title: const Text('Weekly Performance Report'),
                          subtitle: const Text(
                            'Email summary of system uptime',
                          ),
                          trailing: Switch(
                            value: _weeklyReport,
                            onChanged: (v) => setState(() => _weeklyReport = v),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const SectionHeader(title: 'Theme (Dark/Light)'),
                  SettingCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ThemeTile(
                                label: 'LIGHT',
                                active: !_darkActive,
                                onTap: () => ThemeService.setDark(false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ThemeTile(
                                label: 'DARK ACTIVE',
                                active: _darkActive,
                                onTap: () => ThemeService.setDark(true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.sync),
                            const SizedBox(width: 8),
                            const Text('Sync with system preferences'),
                            const Spacer(),
                            Switch(value: false, onChanged: (_) {}),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const SectionHeader(title: 'Security'),
                  SettingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.lock_open),
                          title: const Text('Change Password'),
                          subtitle: const Text('Last changed 4 months ago'),
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? const Color(0x4DF5F5F5)
                                : const Color(0x80E0E5FF),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'AUTHENTICATOR',
                            style: TextStyle(letterSpacing: 6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.devices),
                          title: const Text('Device Management'),
                          subtitle: const Text('3 active sessions'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlassColors.danger,
                    ),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final token = await _auth.getSavedAccessToken();
                      final ok = await _auth.logout(token);
                      if (!mounted) return;
                      if (ok) {
                        navigator.pushReplacementNamed('/login');
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Logout failed')),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('LOG OUT OF CLOUDOPS'),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'CloudOps Platform v4.2.0-stable',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'UUID: f47ac10b-58cc-4372-a567-0e02b2c3d479',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
