// File chứa các dịch vụ gọi API liên quan đến auth
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthService {
  // Hàm đăng ký người dùng
  Future<UserModel> register(String name, String email, String password, String confirmPassword) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}');
    print('DEBUG: Sending POST to $url');  // Log URL

    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    print('DEBUG: Body: $body');  // Log body

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');  // Log status
    print('DEBUG: Response: ${response.body}');  // Log response

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Chuyển JSON thành model (ví dụ)
      return UserModel.fromJson(data['user']);
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Đăng ký thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }


  // Hàm đăng nhập
  Future<UserModel> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['data']['access_token']);
      await prefs.setString('refresh_token', data['data']['refresh_token']);
      return UserModel.fromJson(data);
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Đăng nhập thất bại';
      throw Exception(error);
    }
  }

  // Hàm quên mật khẩu
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.forgotPasswordEndpoint}');
    final body = jsonEncode({'email': email});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['message'] ?? 'Yêu cầu quên mật khẩu đã được gửi!';
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Yêu cầu thất bại';
      throw Exception(error);
    }
  }
  // Hàm đăng xuất
  Future<bool> logout() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.logoutEndpoint}');
    print('DEBUG: Sending POST to $url');  // Log URL

    // Lấy headers với token (nếu có) để xác thực
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      // Không cần body, theo auth.controller.ts
    );

    print('DEBUG: Status: ${response.statusCode}');  // Log status
    print('DEBUG: Response: ${response.body}');  // Log response

    // Luôn xóa token local, dù API thành công hay không
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa tất cả token (access, refresh)

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['loggedOut'] ?? true; // Trả về true nếu loggedOut: true
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Đăng xuất thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }
  // Hàm lấy headers với token
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}