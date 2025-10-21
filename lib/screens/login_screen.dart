// Màn hình đăng nhập - HIỂN THỊ LỖI 401 BẰNG SNACKBAR
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _getEmailError(authProvider.errorMessage),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      errorText: _getPasswordError(authProvider.errorMessage),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Đăng nhập',
                    isLoading: authProvider.isLoading,
                    onPressed: () => _handleLogin(authProvider),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Chưa có tài khoản? Đăng ký'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('Quên mật khẩu?'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // HELPER: KIỂM TRA EMAIL HỢP LỆ
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email.toLowerCase());
  }

  // HELPER: LỖI EMAIL
  String? _getEmailError(String? errorMessage) {
    if (errorMessage == null) return null;

    final email = _emailController.text.trim();

    if (errorMessage.contains('Email không hợp lệ')) {
      return 'Email không hợp lệ';
    }

    if (email.isEmpty) {
      return 'Email không được để trống';
    }

    if (!_isValidEmail(email)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // HELPER: LỖI PASSWORD
  String? _getPasswordError(String? errorMessage) {
    if (errorMessage == null) return null;

    final email = _emailController.text.trim();

    if (errorMessage.contains('Password không được để trống') || errorMessage.contains('Mật khẩu không được để trống')) {
      return 'Mật khẩu không được để trống';
    }

    if (errorMessage.contains('Email hoặc mật khẩu') && _isValidEmail(email)) {
      return 'Mật khẩu không đúng';
    }

    if (errorMessage.contains('Email không hợp lệ') || errorMessage.contains('Email không đúng')) {
      return null;
    }

    return null;
  }

  // HANDLER: XỬ LÝ LOGIN - THÊM SNACKBAR CHO LỖI 401
  void _handleLogin(AuthProvider authProvider) {
    authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    ).then((_) {
      // 👈 SỬA: HIỂN THỊ LỖI 401 BẰNG SNACKBAR NẾU CÓ ERROR
      if (authProvider.errorMessage != null && authProvider.errorMessage!.contains('Email hoặc mật khẩu')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (authProvider.user != null) {
        if (!authProvider.isVerified) {
          authProvider.requestVerify(_emailController.text.trim());
          Navigator.pushNamed(context, '/verify-account');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}