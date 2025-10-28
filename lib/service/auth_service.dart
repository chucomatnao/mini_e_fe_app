import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

/// AuthService - Lớp trung gian gọi API xác thực và quản lý người dùng
/// Tương tác với backend NestJS tại các endpoint: /auth/* và /users/*
/// Quản lý token (access/refresh), xử lý lỗi, và trả về UserModel
class AuthService {
  // ────────────────────────────────────────────────────────────────────────
  //                          1. HELPER METHODS (PRIVATE)
  // ────────────────────────────────────────────────────────────────────────

  /// Lấy access token từ SharedPreferences
  /// Dùng cho các request cần xác thực (protected routes)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('DEBUG: _getToken() → $token');
    return token;
  }

  /// Lưu access token và refresh token vào SharedPreferences
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    print('DEBUG: Tokens saved: access_token=${accessToken.substring(0, 20)}...');
  }

  /// Xây dựng headers với token (nếu có)
  Future<Map<String, String>> _getHeaders({bool withToken = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withToken) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    print('DEBUG: Headers → $headers');
    return headers;
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          2. ĐĂNG KÝ (REGISTER)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/register
  /// Backend trả: { success: true, data: { id, name, email, ... } }
  Future<UserModel> register(
      String name,
      String email,
      String password,
      String confirmPassword,
      ) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}');
    final body = jsonEncode({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'confirmPassword': confirmPassword,
    });

    print('DEBUG: [REGISTER] POST → $url');
    print('DEBUG: Body → $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Backend trả: { data: { id, name, email, role, isVerified } }
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'Đăng ký thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          3. ĐĂNG NHẬP (LOGIN)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/login
  /// Backend trả: { data: { access_token, refresh_token, user: { ... } } }
  Future<UserModel> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}');
    final body = jsonEncode({
      'email': email.trim().toLowerCase(),
      'password': password,
    });

    print('DEBUG: [LOGIN] POST → $url');
    print('DEBUG: Body → $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final accessToken = data['data']['access_token'];
      final refreshToken = data['data']['refresh_token'];
      final userData = data['data']['user']; // Nested user object

      await _saveTokens(accessToken, refreshToken);
      print('DEBUG: User parsed → $userData');

      return UserModel.fromJson(userData);
    } else {
      final error = data['message'] ?? 'Đăng nhập thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          4. YÊU CẦU OTP XÁC THỰC (REQUEST VERIFY)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/request-verify
  /// Cần token → userId được lấy từ JWT
  Future<void> requestVerify() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.requestVerifyEndpoint}');
    final headers = await _getHeaders();

    print('DEBUG: [REQUEST VERIFY] POST → $url');
    print('DEBUG: Headers → $headers');

    final response = await http.post(url, headers: headers);

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final error = data['message'] ?? 'Gửi OTP thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          5. XÁC MINH OTP (VERIFY ACCOUNT)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/verify-account
  /// Body: { otp: "123456" }
  Future<UserModel> verifyAccount(String otp) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.verifyAccountEndpoint}');
    final headers = await _getHeaders();
    final body = jsonEncode({'otp': otp.trim()});

    print('DEBUG: [VERIFY ACCOUNT] POST → $url');
    print('DEBUG: Body → $body');

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'OTP không đúng';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          6. QUÊN MẬT KHẨU (FORGOT PASSWORD)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/forgot-password
  /// Trả về message + email (DEV mode có otp)
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.forgotPasswordEndpoint}');
    final body = jsonEncode({'email': email.trim().toLowerCase()});

    print('DEBUG: [FORGOT PASSWORD] POST → $url');
    print('DEBUG: Body → $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final responseData = data['data'] as Map<String, dynamic>;
      return 'Mã OTP đã được gửi đến ${responseData['email']}!';
    } else {
      final error = data['message'] ?? 'Không tìm thấy email';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          7. ĐẶT LẠI MẬT KHẨU (RESET PASSWORD)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/reset-password
  Future<String> resetPassword(
      String email,
      String otp,
      String newPassword,
      String confirmPassword,
      ) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.resetPasswordEndpoint}');
    final body = jsonEncode({
      'email': email.trim().toLowerCase(),
      'otp': otp.trim(),
      'password': newPassword,
      'confirmPassword': confirmPassword,
    });

    print('DEBUG: [RESET PASSWORD] POST → $url');
    print('DEBUG: Body → $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return 'Đặt lại mật khẩu thành công!';
    } else {
      final error = data['message'] ?? 'OTP không hợp lệ';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          8. CẬP NHẬT HỒ SƠ (UPDATE PROFILE)
  // ────────────────────────────────────────────────────────────────────────
  Future<UserModel> updateProfile(int userId, Map<String, dynamic> updates) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.updateUserEndpoint}/$userId');
    final headers = await _getHeaders();
    final body = jsonEncode(updates);

    print('DEBUG: [UPDATE PROFILE] PATCH → $url');
    print('DEBUG: Body → $body');

    final response = await http.patch(url, headers: headers, body: body);
    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'Cập nhật thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          9. ĐĂNG XUẤT (LOGOUT)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi POST /auth/logout
  /// Xóa token local dù API có lỗi
  Future<void> logout() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.logoutEndpoint}');
    final headers = await _getHeaders(withToken: false); // Không cần token

    print('DEBUG: [LOGOUT] POST → $url');

    try {
      final response = await http.post(url, headers: headers);
      print('DEBUG: Status: ${response.statusCode}');
    } catch (e) {
      print('DEBUG: Logout API error: $e');
    } finally {
      // Luôn xóa token dù API lỗi
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('DEBUG: Local tokens cleared');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          10. LẤY THÔNG TIN USER HIỆN TẠI (GET /users/me)
  // ────────────────────────────────────────────────────────────────────────
  /// Gọi GET /users/me (cần thêm route ở backend)
  Future<UserModel> getCurrentUser() async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/me');
    final headers = await _getHeaders();

    print('DEBUG: [GET CURRENT USER] GET → $url');

    final response = await http.get(url, headers: headers);

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'Không thể tải thông tin';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }
}