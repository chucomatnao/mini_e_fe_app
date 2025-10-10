import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';  // Nếu có

class AuthService {
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', data['accessToken']);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Login failed');
    }
  }

// Thêm register, forgot password
}