import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gửi OTP ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().requestVerify();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? 'email của bạn';

    return Scaffold(
      appBar: AppBar(title: const Text('Xác minh tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Nhập mã OTP đã được gửi đến $email',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // OTP FIELD
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mã OTP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập mã OTP' : null,
              ),
              const SizedBox(height: 20),

              // XÁC MINH BUTTON
              CustomButton(
                text: 'Xác minh',
                isLoading: authProvider.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    authProvider.verifyAccount(_otpController.text.trim()).then((_) {
                      if (authProvider.isVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xác thực thành công!')),
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

              // GỬI LẠI OTP
              TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () {
                  authProvider.requestVerify().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.errorMessage ?? 'OTP đã được gửi lại!'),
                        backgroundColor: authProvider.errorMessage == null ? Colors.green : Colors.red,
                      ),
                    );
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

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}