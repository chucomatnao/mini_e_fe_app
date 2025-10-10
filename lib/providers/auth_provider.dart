import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AuthService().login(email, password);
    } catch (e) {
      // Xử lý lỗi
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Thêm hàm register tương tự
}