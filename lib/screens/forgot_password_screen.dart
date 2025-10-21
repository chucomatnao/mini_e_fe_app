import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quên mật khẩu')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => _forgotPassword(context),
                    child: auth.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Gửi yêu cầu'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 👈 SỬA: GỌI PROVIDER ĐÚNG CÁCH
  void _forgotPassword(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    // GỌI PROVIDER - TỰ ĐỘNG NAVIGATE
    auth.forgotPassword(_emailController.text);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}