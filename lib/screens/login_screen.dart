// Màn hình đăng nhập
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
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email không được để trống' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Mật khẩu không được để trống' : null,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Đăng nhập',
                isLoading: authProvider.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authProvider.login(
                      _emailController.text,
                      _passwordController.text,
                    ).then((_) {
                      if (authProvider.user != null) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? 'Lỗi không xác định')));
                      }
                    });
                  }
                },
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Chưa có tài khoản? Đăng ký'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                child: const Text('Quên mật khẩu?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}