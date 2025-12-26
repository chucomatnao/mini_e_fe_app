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

  // ===== GETTERS CHO UI =====
  int get totalItems => _cartData?.itemsQuantity ?? 0;
  double get subtotal => _cartData?.subtotal ?? 0.0;

  List<CartItemModel> get items => _cartData?.items ?? [];

  int get selectedCount {
    if (_cartData == null) return 0;
    return _cartData!.items.where((e) => e.isSelected).length;
  }

  bool get isAllSelected {
    if (_cartData == null || _cartData!.items.isEmpty) return false;
    return _cartData!.items.every((e) => e.isSelected);
  }

  double get selectedSubtotal => _cartData?.selectedSubtotal ?? 0.0;

  List<int> get selectedCartItemIds {
    if (_cartData == null) return [];
    return _cartData!.items.where((e) => e.isSelected).map((e) => e.id).toList();
  }

  // Giữ lại trạng thái tick khi server trả data mới
  CartData _mergeSelection(CartData newData) {
    final oldSelected = <int, bool>{};
    if (_cartData != null) {
      for (final it in _cartData!.items) {
        oldSelected[it.id] = it.isSelected;
      }
    }
    for (final it in newData.items) {
      it.isSelected = oldSelected[it.id] ?? true; // default true
    }
    return newData;
  }

  // ===== API =====
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _cartService.getCart();
      if (data != null) {
        _cartData = _mergeSelection(data);
      } else {
        _cartData = CartData(
          id: 0,
          currency: 'VND',
          itemsCount: 0,
          itemsQuantity: 0,
          subtotal: 0.0,
          items: [],
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, {required int? variantId, int quantity = 1}) async {
    // ✅ backend của bạn bắt buộc variantId
    if (variantId == null) {
      throw Exception('Vui lòng chọn biến thể trước khi thêm vào giỏ');
    }

    final newData = await _cartService.addToCart(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );

    if (newData != null) {
      _cartData = _mergeSelection(newData);
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      // Optimistic update
      final idx = _cartData?.items.indexWhere((e) => e.id == itemId);
      if (idx != null && idx >= 0) {
        _cartData!.items[idx].quantity = newQuantity;
        notifyListeners();
      }

      final newData = await _cartService.updateItemQuantity(itemId, newQuantity);
      if (newData != null) {
        _cartData = _mergeSelection(newData);
        notifyListeners();
      }
    } catch (e) {
      await fetchCart();
      rethrow;
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      final newData = await _cartService.removeItem(itemId);
      if (newData != null) {
        _cartData = _mergeSelection(newData);
      } else {
        _cartData?.items.removeWhere((it) => it.id == itemId);
      }
      notifyListeners();
    } catch (e) {
      await fetchCart();
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final newData = await _cartService.clearCart();
      if (newData != null) {
        _cartData = _mergeSelection(newData);
      } else {
        _cartData = CartData(
          id: 0,
          currency: 'VND',
          itemsCount: 0,
          itemsQuantity: 0,
          subtotal: 0.0,
          items: [],
        );
      }
      notifyListeners();
    } catch (e) {
      await fetchCart();
      rethrow;
    }
  }

  // ===== CHECKBOX (LOCAL) =====
  void toggleSelection(int itemId) {
    final it = _cartData?.items.firstWhere((e) => e.id == itemId, orElse: () => throw Exception('Item not found'));
    if (it != null) {
      it.isSelected = !it.isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool value) {
    if (_cartData == null) return;
    for (final it in _cartData!.items) {
      it.isSelected = value;
    }
    notifyListeners();
  }
}
