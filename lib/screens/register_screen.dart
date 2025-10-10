// Màn hình đăng ký
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
                validator: (value) => value!.isEmpty ? 'Tên không được để trống' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Email không được để trống' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) => value!.length < 8 ? 'Mật khẩu phải ít nhất 8 ký tự' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu'),
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'Mật khẩu không khớp' : null,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Đăng ký',
                isLoading: authProvider.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authProvider.register(
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _confirmPasswordController.text,
                    ).then((_) {
                      if (authProvider.user != null) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authProvider.errorMessage ?? 'Lỗi không xác định')));
                      }
                    });
                  }
                },
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Đã có tài khoản? Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}