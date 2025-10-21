import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthService {
  // Hàm đăng ký người dùng
  Future<UserModel> register(String name, String email, String password, String confirmPassword) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}');
    print('DEBUG: Sending POST to $url');  // Log URL để debug

    final body = jsonEncode({
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    print('DEBUG: Body: $body');  // Log body để debug

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');  // Log status để debug
    print('DEBUG: Response: ${response.body}');  // Log response để debug

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Sửa cách parse: data['data'] chứa thông tin user trực tiếp
      return UserModel.fromJson(data['data']); // Thay vì data['user']
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Đăng ký thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // Hàm gửi yêu cầu OTP (request-verify)
  Future<void> requestVerify(String email) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.requestVerifyEndpoint}');
    final headers = await getHeaders(); // Lấy headers với token
    print('DEBUG: requestVerify - Headers: $headers'); // Log headers
    final body = jsonEncode({'email': email});

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['message'] ?? 'Yêu cầu OTP thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // Hàm xác minh OTP (verify-account)
  Future<UserModel> verifyAccount(String email, String otp) async {  // Giữ param email để tương thích, nhưng không dùng trong body
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.verifyAccountEndpoint}');
    print('DEBUG: Sending POST to $url'); // Log URL

    // SỬA: Lấy headers với token (tương tự requestVerify), vì endpoint private cần Authorization
    final headers = await getHeaders();
    print('DEBUG: verifyAccount - Headers: $headers'); // Log headers để debug token

    // SỬA: Chỉ gửi 'otp' trong body, vì backend DTO chỉ cần otp (userId lấy từ token). Bỏ email để tránh validate error
    final body = jsonEncode({'otp': otp});
    print('DEBUG: Body: $body'); // Log body

    final response = await http.post(
      url,
      headers: headers,  // SỬA: Thêm headers với token
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}'); // Log status
    print('DEBUG: Response: ${response.body}'); // Log response

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['data']); // Cập nhật user với isVerified: true
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Xác minh OTP thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // Hàm đăng nhập (giữ nguyên, vì đã lưu token đúng)
  Future<UserModel> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}');
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: Status: ${response.statusCode}');
    print('DEBUG: Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('DEBUG: Parsed data: $data');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['data']['access_token'] ?? '');
      await prefs.setString('refresh_token', data['data']['refresh_token'] ?? '');

      // SỬA: PARSE USER TỪ data['data']['user'] (KHÔNG PHẢI data['data'])
      final userData = data['data']['user'];  // Lấy từ nested 'user'
      print('DEBUG: User data: $userData');   // Log để kiểm tra

      return UserModel.fromJson(userData);    // Truyền đúng object
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Đăng nhập thất bại';
      throw Exception('Status: ${response.statusCode} - $error');
    }
  }

  // Hàm quên mật khẩu
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.forgotPasswordEndpoint}');
    final body = jsonEncode({'email': email.trim()});

    print('DEBUG: ForgotPassword - URL: $url');
    print('DEBUG: ForgotPassword - Body: $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: ForgotPassword - Status: ${response.statusCode}');
    print('DEBUG: ForgotPassword - Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('DEBUG: Parsed data: $data');

      // SỬA: BACKEND TRẢ {data: {email, otp, expiresAt}} → LẤY MESSAGE TỪ data['data']
      final responseData = data['data'] as Map<String, dynamic>;
      print('DEBUG: responseData: $responseData');

      // TRẢ VỀ STRING MESSAGE (KHÔNG PHẢI Map)
      return 'Mã OTP đã được gửi đến ${responseData['email']}!';

    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Yêu cầu thất bại';
      throw Exception(error);
    }
  }

  //Hàm reset password với OTP
  Future<String> resetPassword(String email, String otp, String newPassword, String confirmPassword) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.resetPasswordEndpoint}');

    final body = jsonEncode({
      'email': email,
      'otp': otp,
      'password': newPassword,
      'confirmPassword': confirmPassword,
    });

    print('DEBUG: ResetPassword - URL: $url');
    print('DEBUG: ResetPassword - Body: $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('DEBUG: ResetPassword - Status: ${response.statusCode}');
    print('DEBUG: ResetPassword - Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('DEBUG: ResetPassword Parsed: $data');

      // SỬA: PARSE ĐÚNG - BACKEND TRẢ {data: {reset: true}}
      final responseData = data['data'] as Map<String, dynamic>;
      print('DEBUG: responseData: $responseData');

      // TRẢ VỀ STRING MESSAGE
      return 'Đổi mật khẩu thành công!';

    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đổi mật khẩu thất bại');
    }
  }

  // Hàm đăng xuất (giữ nguyên)
  Future<bool> logout() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.logoutEndpoint}');
    print('DEBUG: Sending POST to $url');  // Log URL để debug

    // Lấy headers với token (nếu có) để xác thực
    final headers = await getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      // Không cần body, theo auth.controller.ts
    );

    print('DEBUG: Status: ${response.statusCode}');  // Log status để debug
    print('DEBUG: Response: ${response.body}');  // Log response để debug

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

  // Hàm lấy headers với token (giữ nguyên)
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    print('DEBUG: getHeaders - Token: $token'); // Log token
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token', // Gửi token
    };
  }
}