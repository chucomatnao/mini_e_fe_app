// lib/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: Colors.deepPurple),
          SizedBox(height: 16),
          Text('Chào mừng ADMIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Quản lý hệ thống'),
        ],
      ),
    );
  }
}