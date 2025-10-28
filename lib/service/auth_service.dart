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
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'Đăng ký thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          3. ĐĂNG NHẬP (LOGIN) - TRẢ VỀ MAP
  // ────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
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
      final userData = data['data']['user'];

      await _saveTokens(accessToken, refreshToken);

      return {
        'user': UserModel.fromJson(userData),
        'access_token': accessToken,
      };
    } else {
      final error = data['message'] ?? 'Đăng nhập thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          4. YÊU CẦU OTP XÁC THỰC
  // ────────────────────────────────────────────────────────────────────────
  Future<void> requestVerify() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.requestVerifyEndpoint}');
    final headers = await _getHeaders();

    final response = await http.post(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final error = data['message'] ?? 'Gửi OTP thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          5. XÁC MINH OTP
  // ────────────────────────────────────────────────────────────────────────
  Future<UserModel> verifyAccount(String otp) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.verifyAccountEndpoint}');
    final headers = await _getHeaders();
    final body = jsonEncode({'otp': otp.trim()});

    final response = await http.post(url, headers: headers, body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'OTP không đúng';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          6. QUÊN MẬT KHẨU
  // ────────────────────────────────────────────────────────────────────────
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.forgotPasswordEndpoint}');
    final body = jsonEncode({'email': email.trim().toLowerCase()});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return 'Mã OTP đã được gửi đến ${data['data']['email']}!';
    } else {
      final error = data['message'] ?? 'Không tìm thấy email';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          7. ĐẶT LẠI MẬT KHẨU
  // ────────────────────────────────────────────────────────────────────────
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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return 'Đặt lại mật khẩu thành công!';
    } else {
      final error = data['message'] ?? 'OTP không hợp lệ';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          8. CẬP NHẬT HỒ SƠ
  // ────────────────────────────────────────────────────────────────────────
  Future<UserModel> updateProfile(int userId, Map<String, dynamic> updates) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.updateUserEndpoint}/$userId');
    final headers = await _getHeaders();
    final body = jsonEncode(updates);

    final response = await http.patch(url, headers: headers, body: body);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'Cập nhật thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          9. ĐĂNG XUẤT
  // ────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.logoutEndpoint}');
    final headers = await _getHeaders(withToken: false);

    try {
      await http.post(url, headers: headers);
    } catch (e) {
      print('DEBUG: Logout API error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      print('DEBUG: Local tokens cleared');
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          10. LẤY USER HIỆN TẠI (/users/me)
  // ────────────────────────────────────────────────────────────────────────
  Future<UserModel> getCurrentUser(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/me');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

    final response = await http.get(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['data']);
    } else {
      final error = data['message'] ?? 'Không thể tải thông tin';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }
}