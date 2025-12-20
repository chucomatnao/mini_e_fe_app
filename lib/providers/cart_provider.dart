import 'package:flutter/material.dart';
import 'package:mini_e_fe_app/models/cart_model.dart';
import '../service/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  CartData? _cartData;
  bool _isLoading = false;
  String? _errorMessage;

  CartData? get cartData => _cartData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter tiện ích
  int get totalItems => _cartData?.itemsQuantity ?? 0;
  double get subtotal => _cartData?.subtotal ?? 0.0;
  List<CartItemModel> get items => _cartData?.items ?? [];

  // Lấy giỏ hàng lúc khởi động
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
      // Có thể bật loading nếu muốn chặn UI
      _cartData = await _cartService.addToCart(
          productId: productId,
          variantId: variantId,
          quantity: quantity
      );
      notifyListeners();
    } catch (e) {
      // Ném lỗi ra để UI hiển thị Toast/SnackBar (ví dụ: Hết hàng)
      rethrow;
    }
  }

  // Tăng/Giảm số lượng
  Future<void> updateQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 0) return;

    // Optimistic Update (Cập nhật giao diện trước cho mượt - tuỳ chọn)
    // Nhưng để an toàn và đồng bộ subtotal chính xác từ server, ta gọi API luôn
    try {
      _cartData = await _cartService.updateItemQuantity(itemId, newQuantity);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Xóa item
  Future<void> removeItem(int itemId) async {
    try {
      _cartData = await _cartService.removeItem(itemId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}