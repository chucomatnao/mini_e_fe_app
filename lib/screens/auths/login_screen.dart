import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              // NỀN GRADIENT
              Positioned(
                left: -size.width * 0.4,
                top: 0,
                child: Container(
                  width: size.width * 0.9,
                  height: size.height,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7050EF),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(250),
                      bottomRight: Radius.circular(250),
                    ),
                  ),
                ),
              ),

              // FORM LOGIN
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Container(
                    width: size.width * 0.9,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 10)),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Login", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, fontFamily: 'Quicksand')),
                        const SizedBox(height: 40),

                        // EMAIL FIELD
                        TextFormField(
                          controller: _emailController,
                          onChanged: (_) => setState(() => _emailTouched = true),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            errorText: _getEmailError(authProvider.errorMessage),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            filled: true,
                            fillColor: const Color(0x7FFFF7F7),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFF7050EF), width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // PASSWORD FIELD
                        TextFormField(
                          controller: _passwordController,
                          onChanged: (_) => setState(() => _passwordTouched = true),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            errorText: _getPasswordError(authProvider.errorMessage),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            filled: true,
                            fillColor: const Color(0x7FFFF7F7),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFF7050EF), width: 2),
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 30),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0x960004FF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: authProvider.isLoading ? null : () => _handleLogin(authProvider),
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // LINKS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/register'),
                              child: const Text("Create an account", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                              child: const Text("Forget password?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // SỬA: DÙNG _emailController.text TRONG _getEmailError SAU KHI ĐÃ CÓ GIÁ TRỊ
  String? _getEmailError(String? backendError) {
    if (!_emailTouched) return null;
    final email = _emailController.text.trim();
    if (email.isEmpty) return 'Email không được để trống';
    if (!_isValidEmail(email)) return 'Email không hợp lệ';
    if (backendError?.contains('Email') == true) return 'Email không hợp lệ';
    return null;
  }

  String? _getPasswordError(String? backendError) {
    if (!_passwordTouched) return null;
    final password = _passwordController.text;
    if (password.isEmpty) return 'Mật khẩu không được để trống';
    if (password.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (backendError?.contains('mật khẩu') == true) return 'Mật khẩu không đúng';
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleLogin(AuthProvider authProvider) {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_isValidEmail(email) || password.isEmpty || password.length < 8) return;

    authProvider.login(email, password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}