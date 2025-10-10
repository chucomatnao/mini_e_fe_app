import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Column(
        children: [
          TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
          if (authProvider.isLoading) CircularProgressIndicator(),
          CustomButton(text: 'Đăng nhập', onPressed: () {
            authProvider.login(_emailController.text, _passwordController.text);
            // Navigate nếu thành công
          }),
        ],
      ),
    );
  }
}