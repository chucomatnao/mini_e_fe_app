import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

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

  // ✅ REGEX 1: Email validation (khớp với @IsEmail từ backend)
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // ✅ REGEX 2: Password validation (khớp với @Matches từ backend)
  final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:\\|,.<>/?]).{8,}$',
  );

  @override
  Widget build(BuildContext context) {
    // ✅ Lấy AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    // Kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.85; // 85% chiều rộng màn hình
    final fieldWidth = cardWidth * 0.9; // 90% chiều rộng card

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                // BACKGROUND GRADIENT FIGMA (TÍM BÊN TRÁI - giống LoginScreen)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: screenWidth * 0.5,
                    height: screenHeight,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF7050EF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(100),
                          bottomRight: Radius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ),
                // FORM CONTAINER (giống LoginScreen)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.1),
                    child: Container(
                      width: cardWidth,
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        color: const Color(0x4CD9D9D9),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TITLE "Registration" (giống style LoginScreen)
                            const Text(
                              'Registration',
                              style: TextStyle(
                                color: Color(0xFF181821),
                                fontSize: 32,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // NAME FIELD (style giống LoginScreen)
                            Container(
                              width: fieldWidth,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: const Color(0x7FFFF7F7),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'User name',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name không được để trống';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name phải có ít nhất 2 ký tự';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            // EMAIL FIELD (giống LoginScreen)
                            Container(
                              width: fieldWidth,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: const Color(0x7FFFF7F7),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email không được để trống';
                                  }
                                  if (!_emailRegex.hasMatch(value.trim())) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            // PASSWORD FIELD (giống LoginScreen)
                            Container(
                              width: fieldWidth,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: const Color(0x7FFFF7F7),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password không được để trống';
                                  }
                                  if (value.length < 8) {
                                    return 'Password phải có ít nhất 8 ký tự';
                                  }
                                  if (!_passwordRegex.hasMatch(value)) {
                                    return 'Password phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            // CONFIRM PASSWORD FIELD (style giống Password)
                            Container(
                              width: fieldWidth,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: const Color(0x7FFFF7F7),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'ConfirmPassword',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm Password không được để trống';
                                  }
                                  if (value.length < 8) {
                                    return 'Confirm Password phải có ít nhất 8 ký tự';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Mật khẩu không khớp';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // REGISTER BUTTON (giống LoginScreen)
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  authProvider.register(
                                    _nameController.text.trim(),
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                    _confirmPasswordController.text,
                                  ).then((_) {
                                    if (authProvider.user != null) {
                                      Navigator.pushNamed(context, '/verify-account');
                                    } else if (authProvider.errorMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(authProvider.errorMessage!),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: fieldWidth,
                                height: 48,
                                decoration: ShapeDecoration(
                                  color: const Color(0x960004FF),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Center(
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // LOGIN LINK (giống LoginScreen)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: const Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // FORGET PASSWORD LINK (giống LoginScreen)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                              child: const Text(
                                'Forget password!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}