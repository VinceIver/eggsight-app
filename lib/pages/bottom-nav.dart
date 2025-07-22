import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'manual_log_page.dart';
import 'trends_page.dart';
import 'egg_logs_page.dart';
import 'auto_egg_logger_.dart';

class BottomNavApp extends StatefulWidget {
  const BottomNavApp({super.key});

  @override
  State<BottomNavApp> createState() => _BottomNavAppState();
}

class _BottomNavAppState extends State<BottomNavApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EggDashboard(),
    const EggTrendsPage(),
    const EggLogsPage(),
    const ManualLogPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          const AutoEggLogger(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'RobotoBold',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'RobotoBold',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Trends'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logs'),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Manual Log'),
          ],
        ),
      ),
    );
  }
}
