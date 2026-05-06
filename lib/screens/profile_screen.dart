import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../widgets/cloud_ops_app_bar.dart';
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
  bool _securityBriefing = true;
  final List<_SessionEntry> _sessions = [
    _SessionEntry(
      id: 'current-web',
      deviceLabel: 'Chrome • Windows',
      lastSeen: 'Active now',
      isCurrentDevice: true,
    ),
    _SessionEntry(
      id: 'mobile-01',
      deviceLabel: 'Android • Pixel',
      lastSeen: 'Last seen 2d ago',
    ),
    _SessionEntry(
      id: 'tablet-01',
      deviceLabel: 'iPad • Safari',
      lastSeen: 'Last seen 5d ago',
    ),
  ];
  static const _gitBlue = Color(0xFF58A6FF);
  static const _coral = Color(0xFFF78166);

  int get _activeSessionCount => _sessions.length;

  Future<void> _openChangePasswordScreen() async {
    final controller = TextEditingController();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Scaffold(
            appBar: AppBar(title: const Text('Change password')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'New password'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password change (mock) submitted'),
                        ),
                      );
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
  }

  void _signOutSession(String sessionId) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    if (_sessions[idx].isCurrentDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current device stays signed in')),
      );
      return;
    }
    setState(() => _sessions.removeAt(idx));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed out session • $_activeSessionCount active')),
    );
  }

  Future<void> _showDeviceManagementSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Device management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_activeSessionCount active sessions. Your current device always remains signed in.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._sessions.map((session) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          session.isCurrentDevice
                              ? Icons.laptop_mac
                              : Icons.devices_other,
                        ),
                        title: Text(session.deviceLabel),
                        subtitle: Text(session.lastSeen),
                        trailing: session.isCurrentDevice
                            ? const Text(
                                'THIS DEVICE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _gitBlue,
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  _signOutSession(session.id);
                                },
                                child: const Text('SIGN OUT'),
                              ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
    final scaffoldBg =
        isDark ? const Color(0xFF0D1117) : GlassColors.lightBg;
    final displayName = _user?.name ?? 'Alex Rivera';
    final displayRole = _user?.role ?? 'DEVOPS';
    final displayEmail =
        _user?.email ?? 'alex.rivera@cloudops.internal';

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: CloudOpsAppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _gitBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF30363D)
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color:
                                  isDark ? Colors.white38 : Colors.black38,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            displayRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.6,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayEmail,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileMetaChip(
                              isDark: isDark,
                              icon: Icons.location_on_outlined,
                              text: 'Austin, TX (UTC-6)',
                            ),
                            const SizedBox(width: 8),
                            _ProfileMetaChip(
                              isDark: isDark,
                              icon: Icons.calendar_today_outlined,
                              text: 'Joined Jan 2022',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFA0C4FF),
                            foregroundColor: const Color(0xFF0D1117),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final updated = await Navigator.push<User?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProfileScreen(user: _user),
                              ),
                            );
                            if (updated != null) {
                              setState(() => _user = updated);
                            }
                          },
                          child: const Text(
                            'EDIT PROFILE',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SectionHeader(
                    title: 'Notification Settings',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB45309).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SettingCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
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
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Weekly Performance Report'),
                          subtitle: const Text(
                            'Email summary of system uptime',
                          ),
                          trailing: Switch(
                            value: _weeklyReport,
                            onChanged: (v) =>
                                setState(() => _weeklyReport = v),
                          ),
                        ),
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Security Briefing'),
                          subtitle: const Text(
                            'Monthly security compliance updates',
                          ),
                          trailing: Switch(
                            value: _securityBriefing,
                            onChanged: (v) =>
                                setState(() => _securityBriefing = v),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  SectionHeader(
                    title: 'Theme (Dark/Light)',
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _gitBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  SectionHeader(
                    title: 'Security',
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: _coral.withValues(alpha: 0.22),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: _coral,
                        size: 22,
                      ),
                    ),
                  ),
                  SettingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.vpn_key_outlined,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          title: const Text('Change password'),
                          onTap: _openChangePasswordScreen,
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.devices_other,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          title: const Text('Device Management'),
                          subtitle: Text('$_activeSessionCount active sessions'),
                          onTap: _showDeviceManagementSheet,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _coral,
                      side: const BorderSide(color: _coral, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                    icon: const Icon(Icons.logout, color: _coral),
                    label: const Text(
                      'LOG OUT OF CLOUDOPS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
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

class _ProfileMetaChip extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String text;

  const _ProfileMetaChip({
    required this.isDark,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionEntry {
  final String id;
  final String deviceLabel;
  final String lastSeen;
  final bool isCurrentDevice;

  const _SessionEntry({
    required this.id,
    required this.deviceLabel,
    required this.lastSeen,
    this.isCurrentDevice = false,
  });
}
