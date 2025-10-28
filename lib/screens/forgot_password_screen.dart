import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Lấy AuthProvider
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
                // FORM CONTAINER
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TITLE "Forgot password"
                          const Text(
                            'Forgot password',
                            style: TextStyle(
                              color: Color(0xFF181821),
                              fontSize: 32,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // EMAIL FIELD
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
                                  return 'Vui lòng nhập email';
                                }
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // BUTTON "Lấy mã"
                          GestureDetector(
                            onTap: () {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng nhập email')),
                                );
                                return;
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(email)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email không hợp lệ')),
                                );
                                return;
                              }
                              authProvider.forgotPassword(email);
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
                                  'Lấy mã',
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

                          // LOGIN LINK
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
                        ],
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
    _emailController.dispose();
    super.dispose();
  }
}