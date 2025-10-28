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

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVerified => _isVerified;
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

  /// Chuyển lỗi API thành thông báo người dùng dễ hiểu
  String _parseErrorMessage(dynamic error) {
    String errorStr = error.toString();

    // Bỏ "Exception: "
    errorStr = errorStr.replaceFirst('Exception: ', '');

    // Bỏ "Status: XXX - "
    if (errorStr.contains('Status: ')) {
      errorStr = errorStr.split('Status: ')[1].split(' - ')[1];
    }

    // Bỏ " - " thừa
    errorStr = errorStr.replaceAll(' - ', ' ');

    // Custom messages
    if (errorStr.contains('401')) return 'Email hoặc mật khẩu không đúng';
    if (errorStr.contains('400')) return errorStr.contains('Email') ? 'Email không hợp lệ' : 'Dữ liệu không hợp lệ';
    if (errorStr.contains('404')) return 'Không tìm thấy tài khoản';
    if (errorStr.contains('429')) return 'Thử lại quá nhiều lần. Vui lòng đợi.';
    if (errorStr.contains('OTP')) return 'Mã OTP không đúng hoặc đã hết hạn';

    return errorStr.isEmpty ? 'Có lỗi xảy ra' : errorStr;
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          1. REGISTER FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> register(
      String name,
      String email,
      String password,
      String confirmPassword,
      ) async {
    _startLoading();
    try {
      _user = await _authService.register(name, email, password, confirmPassword);
      _isVerified = _user?.isVerified ?? false;

      print('DEBUG: Register - user: $_user, isVerified: $_isVerified');

      // Tự động đăng nhập sau đăng ký
      await login(email, password);
    } catch (e) {
      _setError(e);
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          2. LOGIN FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> login(String email, String password) async {
    _startLoading();
    try {
      _user = await _authService.login(email, password);
      _isVerified = _user?.isVerified ?? false;

      print('DEBUG: Login success - user: $_user, isVerified: $_isVerified');

      if (!_isVerified) {
        await requestVerify(); // SỬA: Không cần email, lấy từ token
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
  //                          3. VERIFY OTP FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> verifyAccount(String otp) async { // SỬA: Bỏ email param
    _startLoading();
    try {
      _user = await _authService.verifyAccount(otp); // SỬA: Chỉ gửi otp
      _isVerified = true;

      print('DEBUG: Verify success - user verified!');

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
  Future<void> resetPassword(
      String otp,
      String newPassword,
      String confirmPassword,
      ) async {
    _startLoading();
    try {
      if (newPassword != confirmPassword) {
        throw Exception('Mật khẩu xác nhận không khớp');
      }

      final message = await _authService.resetPassword(
        _resetEmail!,
        otp.trim(),
        newPassword,
        confirmPassword,
      );

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
  //                          6. LOGOUT FUNCTION
  // ════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    _startLoading();
    try {
      await _authService.logout();
      _clearUserData();
      _navigateTo('/login');
    } catch (e) {
      _setError(e);
      _clearUserData(); // Vẫn xóa dù API lỗi
      _navigateTo('/login');
    } finally {
      _stopLoading();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          7. REQUEST VERIFY OTP
  // ════════════════════════════════════════════════════════════════════════
  Future<void> requestVerify() async { // SỬA: Bỏ email param
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
  //                          8. UPDATE PROFILE FUNCTION
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

      print('DEBUG: Profile updated successfully: $updatedUser');
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
  //                          9. PRIVATE HELPERS
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
      _showWelcomeSnackBar(_user!.name ?? 'Người dùng');
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

  void _showWelcomeSnackBar(String userName) {
    _showSnackBar('Xin chào $userName!', Colors.green);
  }
}