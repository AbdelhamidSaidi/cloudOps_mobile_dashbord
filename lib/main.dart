import 'package:flutter/material.dart';
import 'dart:ui';
import 'screens/profile_screen.dart';
import 'screens/incidents_screen.dart';
import 'screens/add_incident_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'models/incident.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.initTheme();
  runApp(const CloudOpsApp());
}

class CloudOpsApp extends StatelessWidget {
  const CloudOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'CloudOps',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeDecider(),
            '/login': (context) => const LoginScreen(),
            '/app': (context) => const MainShell(),
          },
        );
      },
    );
  }
}

class HomeDecider extends StatefulWidget {
  const HomeDecider({super.key});

  @override
  State<HomeDecider> createState() => _HomeDeciderState();
}

class _HomeDeciderState extends State<HomeDecider> {
  final AuthService _auth = AuthService();
  bool _loading = true;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final token = await _auth.getSavedAccessToken();
    setState(() {
      _logged = token != null && token.isNotEmpty;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _logged ? const MainShell() : const LoginScreen();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final List<IncidentData> _incidents = [];

  void _addIncident(
    String title,
    String description,
    String priority,
    String service,
  ) {
    setState(() {
      _incidents.insert(
        0,
        IncidentData(
          id: 'INC-${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          service: service,
          severity: priority.split(' - ').first,
          age: 'now',
          status: 'OPEN',
        ),
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateIncident(IncidentData updated) {
    setState(() {
      final i = _incidents.indexWhere((e) => e.id == updated.id);
      if (i == -1) return;
      _incidents[i] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = <Widget>[
      DashboardScreen(
        incidents: _incidents,
        onViewAllAlerts: () => _onItemTapped(2),
      ),
      IncidentsScreen(
        incidents: _incidents,
        onIncidentUpdated: _updateIncident,
      ),
      const AlertsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: pages[_selectedIndex],
            ),
          ),
          if (_selectedIndex == 1)
            Positioned(
              right: 18,
              bottom: 82,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF58A6FF),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddIncidentPage(onAddIncident: _addIncident),
                    ),
                  );
                },
                child: const Icon(Icons.add, color: Color(0xFF0D1117)),
              ),
            ),
          // Glassmorphic bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x1AF5F5F5)
                        : const Color(0x26FFFFFF),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0x4DF5F5F5)
                            : const Color(0x80E0E5FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(4, (index) {
                        final items = [
                          {'icon': Icons.grid_view_rounded, 'label': 'DASHBOARD'},
                          {'icon': Icons.gps_fixed, 'label': 'INCIDENTS'},
                          {
                            'icon': Icons.notifications_none_rounded,
                            'label': 'ALERTS',
                          },
                          {'icon': Icons.person_outline_rounded, 'label': 'PROFILE'},
                        ];
                        final item = items[index];
                        final selected = _selectedIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onItemTapped(index),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: selected
                                      ? Theme.of(context).colorScheme.secondary
                                      : (isDark
                                            ? Colors.white.withAlpha(112)
                                            : Colors.black38),
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['label'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selected
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                        : (isDark
                                              ? Colors.white54
                                              : Colors.black54),
                                    fontSize: 10,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
