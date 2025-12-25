// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../service/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  CartData? _cartData;
  bool _isLoading = false;
  String? _errorMessage;

  CartData? get cartData => _cartData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- GETTERS CHO UI ---
  int get totalItems => _cartData?.itemsQuantity ?? 0;

  double get subtotal => _cartData?.subtotal ?? 0.0;

  List<CartItemModel> get items => _cartData?.items ?? [];

  // [QUAN TRỌNG] Getter trả về danh sách ID các sản phẩm đang được tick chọn
  // Đây là cái mà CheckoutScreen đang báo lỗi thiếu
  List<int> get selectedCartItemIds {
    if (_cartData == null) return [];
    return _cartData!.items
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toList();
  }

  // --- LOGIC GỌI API ---

  // Lấy giỏ hàng
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cartData = await _cartService.getCart();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm vào giỏ
  Future<void> addToCart(int productId, {int? variantId, int quantity = 1}) async {
    try {
      // Gọi API thêm
      // Lưu ý: cartService.addToCart nên trả về CartData mới nhất
      final newData = await _cartService.addToCart(
          productId: productId,
          variantId: variantId,
          quantity: quantity
      );

      // Update data và giữ lại trạng thái chọn cũ nếu cần (hoặc reset chọn hết)
      _cartData = newData;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update số lượng
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 1) return; // Không cho giảm dưới 1 (hoặc logic xóa)

    try {
      // Optimistic Update: Update UI ngay lập tức cho mượt
      final index = _cartData?.items.indexWhere((e) => e.id == itemId);
      if (index != null && index != -1) {
        _cartData!.items[index].quantity = newQuantity;
        notifyListeners();
      }

      // Gọi API sync lại
      final newData = await _cartService.updateItemQuantity(itemId, newQuantity);
      _cartData = newData; // Sync data chuẩn từ server
      notifyListeners();
    } catch (e) {
      // Nếu lỗi thì fetch lại để revert số lượng cũ
      await fetchCart();
      rethrow;
    }
  }

  // Xóa item
  Future<void> removeItem(int itemId) async {
    try {
      await _cartService.removeItem(itemId);
      // Xóa local
      _cartData?.items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      await fetchCart();
      rethrow;
    }
  }

  // --- LOGIC CHECKBOX (LOCAL STATE) ---

  // Hàm toggle chọn/bỏ chọn 1 item
  void toggleSelection(int itemId) {
    final item = _cartData?.items.firstWhere((e) => e.id == itemId, orElse: () => throw Exception('Item not found'));
    if (item != null) {
      item.isSelected = !item.isSelected;
      notifyListeners(); // Để UI cập nhật lại tổng tiền
    }
  }

  // Hàm chọn tất cả / bỏ chọn tất cả
  void toggleSelectAll(bool value) {
    if (_cartData != null) {
      for (var item in _cartData!.items) {
        item.isSelected = value;
      }
      notifyListeners();
    }
  }

  // Hàm xóa các item đã chọn (Dùng sau khi thanh toán thành công)
  void clearSelectedItems() {
    if (_cartData != null) {
      _cartData!.items.removeWhere((item) => item.isSelected);
      notifyListeners();
    }
  }
}