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
    // Lấy AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    // Kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.85; // 85% chiều rộng màn hình
    final fieldWidth = cardWidth * 0.9; // 90% chiều rộng card

    final email = authProvider.resetEmail ?? 'Không xác định';

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
                          // TITLE "Đổi mật khẩu"
                          const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(
                              color: Color(0xFF181821),
                              fontSize: 32,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // EMAIL INFO
                          Container(
                            width: fieldWidth,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.email, color: Colors.blue),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email: $email',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                      const Text(
                                        'Kiểm tra OTP trong Gmail',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // OTP FIELD
                          Container(
                            width: fieldWidth,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFF7F7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: TextFormField(
                              controller: _otpController,
                              decoration: const InputDecoration(
                                labelText: 'OTP',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                                contentPadding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              validator: (value) {
                                if (value == null || value.length != 6) {
                                  return 'OTP phải là 6 số';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),

                          // NEW PASSWORD FIELD
                          Container(
                            width: fieldWidth,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFF7F7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                                contentPadding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password không được để trống';
                                }
                                if (value.length < 8) {
                                  return 'Password phải có ít nhất 8 ký tự';
                                }
                                final passwordRegex = RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:\\|,.<>/?]).{8,}$',
                                );
                                if (!passwordRegex.hasMatch(value)) {
                                  return 'Password phải có chữ hoa, chữ thường, số và ký tự đặc biệt';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),

                          // CONFIRM PASSWORD FIELD
                          Container(
                            width: fieldWidth,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFF7F7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
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

                          // BUTTON "Đổi mật khẩu"
                          GestureDetector(
                            onTap: () {
                              if (_otpController.text.length != 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('OTP phải là 6 số')),
                                );
                                return;
                              }
                              final passwordRegex = RegExp(
                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:\\|,.<>/?]).{8,}$',
                              );
                              final password = _passwordController.text;
                              final confirmPassword = _confirmPasswordController.text;
                              if (password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password không được để trống')),
                                );
                                return;
                              }
                              if (password.length < 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password phải có ít nhất 8 ký tự')),
                                );
                                return;
                              }
                              if (!passwordRegex.hasMatch(password)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Password phải có chữ hoa, chữ thường, số và ký tự đặc biệt')),
                                );
                                return;
                              }
                              if (confirmPassword.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Confirm Password không được để trống')),
                                );
                                return;
                              }
                              if (confirmPassword != password) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mật khẩu không khớp')),
                                );
                                return;
                              }
                              authProvider.resetPassword(
                                _otpController.text,
                                password,
                                confirmPassword,
                              );
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
                                  'Đổi mật khẩu',
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
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}