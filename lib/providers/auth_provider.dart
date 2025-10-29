import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/auth_service.dart';
import '../models/user_model.dart';

/// ════════════════════════════════════════════════════════════════════════
///                           AUTH PROVIDER CLASS
/// ════════════════════════════════════════════════════════════════════════
class AuthProvider with ChangeNotifier {
  // ════════════════════════════════════════════════════════════════════════
  //                          STATE VARIABLES
  // ════════════════════════════════════════════════════════════════════════

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isVerified = false;
  String? _resetEmail;
  String? _accessToken; // Token để gọi API bảo mật

  // ════════════════════════════════════════════════════════════════════════
  //                          GETTERS
  // ════════════════════════════════════════════════════════════════════════

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVerified => _isVerified;
  String? get resetEmail => _resetEmail;
  String? get accessToken => _accessToken;

  // ════════════════════════════════════════════════════════════════════════
  //                          SERVICES
  // ════════════════════════════════════════════════════════════════════════

  final AuthService _authService = AuthService();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // ════════════════════════════════════════════════════════════════════════
  //                          ERROR PARSER
  // ════════════════════════════════════════════════════════════════════════
  String _parseErrorMessage(dynamic error) {
    String errorStr = error.toString();
    errorStr = errorStr.replaceFirst('Exception: ', '');
    if (errorStr.contains('Status: ')) {
      errorStr = errorStr.split('Status: ')[1].split(' - ')[1];
    }
    errorStr = errorStr.replaceAll(' - ', ' ');

    if (errorStr.contains('401')) return 'Email hoặc mật khẩu không đúng';
    if (errorStr.contains('400')) return errorStr.contains('Email') ? 'Email không hợp lệ' : 'Dữ liệu không hợp lệ';
    if (errorStr.contains('404')) return 'Không tìm thấy tài khoản';
    if (errorStr.contains('429')) return 'Thử lại quá nhiều lần. Vui lòng đợi.';
    if (errorStr.contains('OTP')) return 'Mã OTP không đúng hoặc đã hết hạn';

    return errorStr.isEmpty ? 'Có lỗi xảy ra' : errorStr;
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          1. REGISTER
  // ════════════════════════════════════════════════════════════════════════
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    _startLoading();
    try {
      _user = await _authService.register(name, email, password, confirmPassword);
      _isVerified = _user?.isVerified ?? false;
      await login(email, password); // Tự động đăng nhập
    } catch (e) {
      _setError(e);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          2. LOGIN
  // ════════════════════════════════════════════════════════════════════════
  Future<void> login(String email, String password) async {
    _startLoading();
    try {
      final result = await _authService.login(email, password);
      _user = result['user'] as UserModel;
      _accessToken = result['access_token'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _accessToken!);

      _isVerified = _user?.isVerified ?? false;

      print('DEBUG: Login success - User: ${_user?.name}, Token: ${_accessToken?.substring(0, 20)}...');

      if (!_isVerified) {
        await requestVerify();
        _navigateTo('/verify-account');
      } else {
        _navigateToHomeAndWelcome();
      }
    } catch (e) {
      _setError(e);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          3. VERIFY OTP
  // ════════════════════════════════════════════════════════════════════════
  Future<void> verifyAccount(String otp) async {
    _startLoading();
    try {
      _user = await _authService.verifyAccount(otp);
      _isVerified = true;
      _showSnackBar('Xác thực tài khoản thành công!', Colors.blue);
      _navigateToHomeAndWelcome(delay: 500);
    } catch (e) {
      _setError(e);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          4. FORGOT PASSWORD
  // ════════════════════════════════════════════════════════════════════════
  Future<void> forgotPassword(String email) async {
    _startLoading();
    try {
      _resetEmail = email.trim();
      final message = await _authService.forgotPassword(email);
      _showSnackBar(message, Colors.green);
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateTo('/reset-otp');
    } catch (e) {
      _setError(e);
      _showSnackBar(_errorMessage!, Colors.red);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          5. RESET PASSWORD
  // ════════════════════════════════════════════════════════════════════════
  Future<void> resetPassword(String otp, String newPassword, String confirmPassword) async {
    _startLoading();
    try {
      if (newPassword != confirmPassword) {
        throw Exception('Mật khẩu xác nhận không khớp');
      }
      final message = await _authService.resetPassword(_resetEmail!, otp, newPassword, confirmPassword);
      _showSnackBar(message, Colors.green);
      _resetEmail = null;
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      navigatorKey.currentState?.pushReplacementNamed('/login');
    } catch (e) {
      _setError(e);
      _showSnackBar(_errorMessage!, Colors.red);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          6. LOGOUT
  // ════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    _startLoading();
    try {
      await _authService.logout();
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      _clearUserData();
      _accessToken = null;
      _navigateTo('/login');
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          7. REQUEST VERIFY OTP
  // ════════════════════════════════════════════════════════════════════════
  Future<void> requestVerify() async {
    _startLoading();
    try {
      await _authService.requestVerify();
      _showSnackBar('Mã OTP đã được gửi lại!', Colors.blue);
    } catch (e) {
      _setError(e);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          8. UPDATE PROFILE
  // ════════════════════════════════════════════════════════════════════════
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null || _user!.id == null) {
      _setError(Exception('Không tìm thấy thông tin người dùng'));
      return;
    }
    _startLoading();
    try {
      final updatedUser = await _authService.updateProfile(_user!.id!, updates);
      _user = updatedUser;
      _isVerified = updatedUser.isVerified ?? false;
      _showSnackBar('Cập nhật thông tin thành công!', Colors.green);
      notifyListeners();
    } catch (e) {
      _setError(e);
      _showSnackBar(_errorMessage ?? 'Cập nhật thất bại', Colors.red);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          9. INIT - LOAD TOKEN + USER
  // ════════════════════════════════════════════════════════════════════════
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      try {
        _user = await _authService.getCurrentUser(_accessToken!);
        _isVerified = _user?.isVerified ?? false;
        notifyListeners();
        print('DEBUG: Auto-login success - User: ${_user?.name}');
      } catch (e) {
        print('Token invalid or expired: $e');
        await prefs.remove('access_token');
        _accessToken = null;
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          10. PRIVATE HELPERS
  // ════════════════════════════════════════════════════════════════════════
  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(dynamic error) {
    _errorMessage = _parseErrorMessage(error);
    print('DEBUG: Error → $_errorMessage');
  }

  void _clearUserData() {
    _user = null;
    _isVerified = false;
    _resetEmail = null;
    notifyListeners();
  }

  void _navigateTo(String route) {
    navigatorKey.currentState?.pushReplacementNamed(route);
  }

  void _navigateToHomeAndWelcome({int delay = 0}) {
    Future.delayed(Duration(milliseconds: delay), () {
      _navigateTo('/home');
      _showSnackBar('Xin chào ${_user!.name ?? 'Người dùng'}!', Colors.green);
    });
  }

  void _showSnackBar(String message, Color color) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}