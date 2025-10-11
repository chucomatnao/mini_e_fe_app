// File quản lý state liên quan đến auth
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  // Hàm đăng ký
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = null; // Xóa lỗi cũ trước khi thử
    notifyListeners();
    try {
      _user = await _authService.register(name, email, password, confirmPassword);
      // Nếu thành công, xóa lỗi và navigate (nếu cần)
    } catch (e) {
      _errorMessage = e.toString(); // Lưu lỗi từ exception
    } finally {
      _isLoading = false;
      notifyListeners(); // Cập nhật UI với lỗi hoặc trạng thái mới
    }
  }

  // Hàm đăng nhập
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null; // Xóa lỗi cũ trước khi thử
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
      // Nếu thành công, xóa lỗi và navigate (nếu cần)
    } catch (e) {
      _errorMessage = e.toString(); // Lưu lỗi từ exception
    } finally {
      _isLoading = false;
      notifyListeners(); // Cập nhật UI với lỗi hoặc trạng thái mới
    }
  }

  // Hàm quên mật khẩu
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final message = await _authService.forgotPassword(email);
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Hàm đăng xuất
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.logout(); // Gọi API và xóa token
      _user = null; // Xóa user state
    } catch (e) {
      _errorMessage = e.toString(); // Lưu lỗi nếu API thất bại
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Key để truy cập context toàn cục
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}