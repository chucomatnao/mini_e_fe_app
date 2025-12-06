// lib/providers/cart_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../utils/app_constants.dart';
import 'auth_provider.dart';

class CartProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  CartModel? _cart;
  bool _isLoading = false;
  String? _error;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ──────────────────────────────────────────────────────────────
  // LẤY TOKEN AN TOÀN
  // ──────────────────────────────────────────────────────────────
  Future<String> _getToken() async {
    final context = AuthProvider.navigatorKey.currentContext;
    if (context == null) {
      throw Exception('Ứng dụng chưa khởi tạo Navigator');
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }
    return token;
  }

  // ──────────────────────────────────────────────────────────────
  // 1. LẤY GIỎ HÀNG CỦA USER (GET /cart)
  // ──────────────────────────────────────────────────────────────
  Future<void> fetchCart({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final token = await _getToken();
      final response = await _dio.get(
        CartApi.myCart, // ← /cart (đúng với backend)
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Backend trả dạng { success: true, data: { ...cart } }
      final cartJson = response.data['data'] ?? response.data;
      _cart = CartModel.fromJson(cartJson);
    } on DioException catch (e) {
      _error = _handleDioError(e);
    } catch (e) {
      _error = 'Lỗi không xác định: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 2. THÊM SẢN PHẨM VÀO GIỎ (POST /cart/items)
  // ──────────────────────────────────────────────────────────────
  /// productId: bắt buộc
  /// variantId: có thể null (không chọn biến thể)
  /// quantity: mặc định 1
  Future<bool> addItem({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) async {
    try {
      final token = await _getToken();
      await _dio.post(
        CartApi.items, // ← /cart/items
        data: {
          "productId": productId,
          "variantId": variantId, // backend chấp nhận null
          "quantity": quantity,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await fetchCart(showLoading: false);
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 3. CẬP NHẬT SỐ LƯỢNG (PATCH /cart/items/:itemId)
  //    quantity = 0 → backend sẽ xóa item
  // ──────────────────────────────────────────────────────────────
  Future<bool> updateItemQuantity(int itemId, int newQuantity) async {
    try {
      final token = await _getToken();
      await _dio.patch(
        CartApi.itemById(itemId),
        data: {"quantity": newQuantity},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await fetchCart(showLoading: false);
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 4. XÓA ITEM (DELETE /cart/items/:itemId)
  // ──────────────────────────────────────────────────────────────
  Future<bool> removeItem(int itemId) async {
    try {
      final token = await _getToken();
      await _dio.delete(
        CartApi.itemById(itemId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await fetchCart(showLoading: false);
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // XỬ LÝ LỖI DIO
  // ──────────────────────────────────────────────────────────────
  String _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      final ctx = AuthProvider.navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Provider.of<AuthProvider>(ctx, listen: false).logout();
      }
      return 'Phiên đăng nhập hết hạn';
    }

    final msg = e.response?.data['message']?.toString() ??
        e.response?.data?.toString() ??
        'Lỗi server: ${e.response?.statusCode}';
    return msg;
  }

  // ──────────────────────────────────────────────────────────────
  // XÓA LỖI (khi muốn retry)
  // ──────────────────────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }
}