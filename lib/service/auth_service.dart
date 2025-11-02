import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';
import 'api_client.dart'; // THÊM

class AuthService {
  final Dio _dio = ApiClient().dio;

  // Helper: Lưu access token (refresh cookie tự lưu)
  Future<void> _saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }

  Future<UserModel> register(String name, String email, String password, String confirmPassword) async {
    final response = await _dio.post(
      AppConstants.registerEndpoint,
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Đăng ký thất bại');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      AppConstants.loginEndpoint,
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      final accessToken = data['access_token'];
      await _saveAccessToken(accessToken);
      return {
        'user': UserModel.fromJson(data['user']),
        'access_token': accessToken,
      };
    } else {
      throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
    }
  }

  Future<void> requestVerify() async {
    final response = await _dio.post(AppConstants.requestVerifyEndpoint);
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Gửi OTP thất bại');
    }
  }

  Future<UserModel> verifyAccount(String otp) async {
    final response = await _dio.post(
      AppConstants.verifyAccountEndpoint,
      data: {'otp': otp.trim()},
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'OTP không đúng');
    }
  }

  Future<String> forgotPassword(String email) async {
    final response = await _dio.post(
      AppConstants.forgotPasswordEndpoint,
      data: {'email': email.trim().toLowerCase()},
    );
    if (response.statusCode == 200) {
      return 'Mã OTP đã được gửi đến ${response.data['data']['email']}!';
    } else {
      throw Exception(response.data['message'] ?? 'Không tìm thấy email');
    }
  }

  Future<String> resetPassword(String email, String otp, String newPassword, String confirmPassword) async {
    final response = await _dio.post(
      AppConstants.resetPasswordEndpoint,
      data: {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
        'password': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    if (response.statusCode == 200) {
      return 'Đặt lại mật khẩu thành công!';
    } else {
      throw Exception(response.data['message'] ?? 'OTP không hợp lệ');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(AppConstants.logoutEndpoint);
    } catch (e) {
      print('DEBUG: Logout API error: $e'); // Optional: Log error nếu backend fail
    } finally {
      await ApiClient().logoutAndRedirect(); // Gọi public method
    }
  }
}