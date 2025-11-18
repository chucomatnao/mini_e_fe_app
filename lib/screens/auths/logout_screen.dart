// Màn hình xác nhận đăng xuất (tùy chọn)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đăng xuất')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bạn có chắc chắn muốn đăng xuất?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                await authProvider.logout();
                if (authProvider.user == null) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.errorMessage ?? 'Đăng xuất thất bại')),
                  );
                }
              },
              child: authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}