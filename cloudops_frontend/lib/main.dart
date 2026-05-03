import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const CloudOpsApp());
}

class CloudOpsApp extends StatelessWidget {
  const CloudOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudOps',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1E293B),
          secondary: const Color(0xFF94A3B8),
        ),
      ),
      home: const MainShell(),
    );
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
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: _pages[_selectedIndex]),
          // Custom translucent bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(40),
                border: Border(top: BorderSide(color: Colors.white10)),
                // subtle blur can be added with BackdropFilter if desired
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (index) {
                    final items = [
                      {'icon': Icons.dashboard, 'label': 'DASHBOARD'},
                      {'icon': Icons.report, 'label': 'INCIDENTS'},
                      {'icon': Icons.notification_important, 'label': 'ALERTS'},
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
                                  : Colors.white38,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                color: selected
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.white30,
                                fontSize: 10,
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
        ],
      ),
    );
  }
}
