import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ResetOtpScreen extends StatefulWidget {
  @override
  _ResetOtpScreenState createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đổi mật khẩu')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final email = auth.resetEmail ?? 'Không xác định';

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // EMAIL INFO
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email, color: Colors.blue),
                    title: Text('Email: $email'),
                    subtitle: Text('Kiểm tra OTP trong Gmail'),
                  ),
                ),

                SizedBox(height: 30),

                // OTP
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: 'Mã OTP (6 số)',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),

                SizedBox(height: 20),

                // NEW PASSWORD
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // CONFIRM PASSWORD
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                SizedBox(height: 30),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: auth.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Đổi mật khẩu', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _resetPassword() {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP phải là 6 số')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.resetPassword(
      _otpController.text,
      _passwordController.text,
      _confirmPasswordController.text,
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}