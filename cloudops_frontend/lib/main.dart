import 'package:flutter/material.dart';
import 'dart:ui';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
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

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Dashboard')),
    Center(child: Text('Incidents')),
    Center(child: Text('Alerts')),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: _pages[_selectedIndex]),
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
                          {'icon': Icons.dashboard, 'label': 'DASHBOARD'},
                          {'icon': Icons.report, 'label': 'INCIDENTS'},
                          {
                            'icon': Icons.notification_important,
                            'label': 'ALERTS',
                          },
                          {'icon': Icons.person, 'label': 'PROFILE'},
                        ];
                        final item = items[index];
                        final selected = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => _onItemTapped(index),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 80,
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
