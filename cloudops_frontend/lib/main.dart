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
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'DASHBOARD'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'INCIDENTS'),
          BottomNavigationBarItem(icon: Icon(Icons.notification_important), label: 'ALERTS'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}
