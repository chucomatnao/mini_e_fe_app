// Màn hình xác minh OTP
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class VerifyAccountScreen extends StatefulWidget {
  @override
  _VerifyAccountScreenState createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController(); // Lấy email từ đăng ký/login

  @override
  void initState() {
    super.initState();
    // Lấy email từ AuthProvider (giả định từ đăng ký/login)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _emailController.text = authProvider.user?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Xác minh tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Nhập mã OTP đã được gửi đến ${_emailController.text}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Mã OTP'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập mã OTP' : null,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Xác minh',
                isLoading: authProvider.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authProvider.verifyAccount(
                      _emailController.text,
                      _otpController.text,
                    ).then((_) {
                      if (authProvider.isVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đăng ký thành công!')),
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (authProvider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.errorMessage!)),
                        );
                      }
                    });
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  authProvider.requestVerify(_emailController.text).then((_) {
                    if (authProvider.errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yêu cầu OTP lại thành công!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(authProvider.errorMessage!)),
                      );
                    }
                  });
                },
                child: const Text('Gửi lại OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}