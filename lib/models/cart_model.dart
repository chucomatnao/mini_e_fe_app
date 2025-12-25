// lib/models/cart_model.dart

import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------------
/// 1. CART RESPONSE (Wrapper trả về từ Backend)
/// ---------------------------------------------------------------------------
class CartResponse {
  final bool success;
  final CartData? data;

  CartResponse({required this.success, this.data});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? CartData.fromJson(json['data']) : null,
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. CART DATA (Thông tin chung của giỏ hàng)
/// ---------------------------------------------------------------------------
class CartData {
  final int id;
  final String currency;
  final int itemsCount;
  final int itemsQuantity;
  final double subtotal; // Tổng tiền server trả về (của tất cả item)
  final List<CartItemModel> items;

  CartData({
    required this.id,
    required this.currency,
    required this.itemsCount,
    required this.itemsQuantity,
    required this.subtotal,
    required this.items,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      id: json['id'] ?? 0,
      currency: json['currency'] ?? 'VND',
      itemsCount: json['itemsCount'] ?? 0,
      itemsQuantity: json['itemsQuantity'] ?? 0,
      // Parse an toàn cho Decimal/Double
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  // [MỚI] Getter tính tổng tiền chỉ cho các sản phẩm ĐƯỢC CHỌN (isSelected = true)
  // Dùng để hiển thị ở nút "Thanh toán" hoặc màn hình Checkout
  double get selectedSubtotal {
    return items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

/// ---------------------------------------------------------------------------
/// 3. CART ITEM MODEL (Chi tiết sản phẩm)
/// ---------------------------------------------------------------------------
class CartItemModel {
  final int id;         // ID dòng trong giỏ
  final int productId;
  final int? variantId;
  final String title;
  final String? variantName;
  final String? sku;
  final int? imageId;   // BE trả về ID ảnh, FE cần map sang URL nếu cần
  final double price;

  // [SỬA LỖI 1] Bỏ 'final' để có thể cập nhật số lượng trên UI
  int quantity;

  // [SỬA LỖI 2] Thêm biến trạng thái chọn (Chỉ dùng ở Frontend, không lưu DB)
  bool isSelected;

  CartItemModel({
    required this.id,
    required this.productId,
    this.variantId,
    required this.title,
    this.variantName,
    this.sku,
    this.imageId,
    required this.price,
    required this.quantity,
    this.isSelected = true, // Mặc định là chọn khi load xong
  });

  // [SỬA LỖI 3] Getter alias: 'name' trỏ về 'title'
  // Giúp code CheckoutScreen (dùng .name) không bị lỗi
  String get name => title;

  // Getter alias: 'image' (tạm thời trả về string rỗng nếu chưa có logic ảnh)
  String get image => '';

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      variantId: json['variantId'],
      title: json['productName'] ?? json['title'] ?? 'Sản phẩm', // Map linh hoạt
      variantName: json['variantName'],
      sku: json['sku'],
      imageId: json['imageId'], // Hoặc json['image'] tuỳ response BE

      // Parse giá an toàn
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,

      // Mặc định load về là chọn
      isSelected: true,
    );
  }
}