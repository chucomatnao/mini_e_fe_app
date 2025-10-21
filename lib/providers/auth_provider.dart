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

  /// User hiện tại (null = chưa đăng nhập)
  UserModel? _user;

  /// Loading state cho tất cả API calls
  bool _isLoading = false;

  /// Error message từ API hoặc validation
  String? _errorMessage;

  /// Trạng thái xác thực email (true = đã verify)
  bool _isVerified = false;

  /// Email tạm lưu cho reset password (từ forgotPassword → resetOtp)
  String? _resetEmail;

  // ════════════════════════════════════════════════════════════════════════
  //                          GETTERS (Public Access)
  // ════════════════════════════════════════════════════════════════════════

  /// Lấy user hiện tại
  UserModel? get user => _user;

  /// Lấy trạng thái loading
  bool get isLoading => _isLoading;

  /// Lấy error message
  String? get errorMessage => _errorMessage;

  /// Lấy trạng thái verified
  bool get isVerified => _isVerified;

  /// Lấy email reset (cho màn hình OTP)
  String? get resetEmail => _resetEmail;

  // ════════════════════════════════════════════════════════════════════════
  //                          PRIVATE SERVICES
  // ════════════════════════════════════════════════════════════════════════

  /// AuthService instance (gọi API)
  final AuthService _authService = AuthService();

  /// Global Navigator key (để navigate từ provider)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // ════════════════════════════════════════════════════════════════════════
  //                          HELPER: PARSE ERROR MESSAGE
  // ════════════════════════════════════════════════════════════════════════

  /// SỬA: Hàm parse error - CHỈ LẤY MESSAGE SẠCH
  String _parseErrorMessage(dynamic error) {
    String errorStr = error.toString();

    // BỎ "Exception: "
    errorStr = errorStr.replaceFirst('Exception: ', '');

    // BỎ "Status: XXX - "
    if (errorStr.contains('Status: ')) {
      errorStr = errorStr.split('Status: ')[1].split(' - ')[1];
    }

    // BỎ " - " thừa
    errorStr = errorStr.replaceAll(' - ', ' ');

    // Custom messages
    if (errorStr.contains('401')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    if (errorStr.contains('400')) {
      return errorStr.contains('Email') ? 'Email không hợp lệ' : errorStr;
    }

    return errorStr.isEmpty ? 'Có lỗi xảy ra' : errorStr;
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          1. REGISTER FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> register(
      String name,
      String email,
      String password,
      String confirmPassword
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(name, email, password, confirmPassword);
      _isVerified = _user?.isVerified ?? false;

      print('DEBUG: Register - user: $_user, isVerified: $_isVerified');

      if (_user != null) {
        await login(email, password);

        if (!_isVerified) {
          await requestVerify(email);
          navigatorKey.currentState?.pushNamed('/verify-account');
        } else {
          navigatorKey.currentState?.pushReplacementNamed('/home');
          _showWelcomeSnackBar(_user!.name ?? 'Người dùng');
        }
      }
    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      print('DEBUG: Register error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          2. LOGIN FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isVerified = _user?.isVerified ?? false;

      print('DEBUG: Login success - user: $_user');
      print('DEBUG: _user.isVerified: ${_user?.isVerified}');
      print('DEBUG: _isVerified: $_isVerified');

      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString('access_token');
        print('DEBUG: Saved access_token: $savedToken');

        if (!_isVerified) {
          print('DEBUG: User chưa verified → Chuyển sang trang verify');
          await requestVerify(email);
          navigatorKey.currentState?.pushNamed('/verify-account');
        } else {
          print('DEBUG: User đã verified → Vào home + SnackBar chào mừng');
          navigatorKey.currentState?.pushReplacementNamed('/home');
          _showWelcomeSnackBar(_user!.name ?? 'Người dùng');
        }
      }
    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      print('DEBUG: Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          3. VERIFY OTP FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> verifyAccount(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.verifyAccount('', otp);
      _isVerified = true;

      print('DEBUG: Verify success - user verified!');

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Xác thực tài khoản thành công! 🎉'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      navigatorKey.currentState?.pushReplacementNamed('/home');

      Future.delayed(const Duration(milliseconds: 500), () {
        _showWelcomeSnackBar(_user!.name ?? 'Người dùng');
      });

    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      print('DEBUG: Verify error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          4. FORGOT PASSWORD
  // ════════════════════════════════════════════════════════════════════════
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print('DEBUG: START forgotPassword - email: $email');

    try {
      _resetEmail = email.trim();
      print('DEBUG: SAVED _resetEmail: $_resetEmail');

      final message = await _authService.forgotPassword(email);
      print('DEBUG: API SUCCESS - message: $message');

      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        print('DEBUG: SHOW SNACKBAR');
      }

      print('DEBUG: NAVIGATE TO /reset-otp');
      await Future.delayed(Duration(milliseconds: 500));

      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamed('/reset-otp');
        print('DEBUG: NAVIGATION SUCCESS');
      }

    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      print('DEBUG: forgotPassword ERROR: $e');

      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Lỗi không xác định'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          5. RESET PASSWORD
  // ════════════════════════════════════════════════════════════════════════
  Future<void> resetPassword(
      String otp,
      String newPassword,
      String confirmPassword
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (newPassword != confirmPassword) {
        // 👈 SỬA: VALIDATION MESSAGE SẠCH
        _errorMessage = 'Mật khẩu xác nhận không khớp';
        throw Exception(_errorMessage!);
      }

      final message = await _authService.resetPassword(
        _resetEmail!,
        otp.trim(),
        newPassword,
        confirmPassword,
      );

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      navigatorKey.currentState?.pushReplacementNamed('/login');

      _resetEmail = null;

    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          6. LOGOUT FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.logout();

      _user = null;
      _isVerified = false;
      _resetEmail = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      navigatorKey.currentState?.pushReplacementNamed('/login');

    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      print('DEBUG: Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          7. REQUEST VERIFY OTP
  // ════════════════════════════════════════════════════════════════════════
  Future<void> requestVerify(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.requestVerify(email);
      print('DEBUG: OTP sent to $email');
    } catch (e) {
      // 👈 SỬA: DÙNG HELPER FUNCTION
      _errorMessage = _parseErrorMessage(e);
      print('DEBUG: Request verify error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          8. PRIVATE HELPER
  // ════════════════════════════════════════════════════════════════════════
  void _showWelcomeSnackBar(String userName) {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Xin chào $userName! 👋'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}