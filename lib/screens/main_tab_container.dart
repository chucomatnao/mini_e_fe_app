// screens/main_tab_container.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'mall_screen.dart';
import 'live_video_screen.dart';
import 'notification_screen.dart';

class MainTabContainer extends StatefulWidget {
  @override
  _MainTabContainerState createState() => _MainTabContainerState();
}

class _MainTabContainerState extends State<MainTabContainer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    MallScreen(),           // Placeholder
    LiveVideoScreen(),      // Placeholder
    NotificationScreen(),   // Placeholder
    ProfileScreen(),        // Profile ở tab cuối
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Mall'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.tv),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text(
                      'Mới!',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Live & Video',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Text(
                      '16',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tôi'),
        ],
      ),
    );
  }
}