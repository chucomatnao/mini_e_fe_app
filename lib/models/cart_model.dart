import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------------
/// 1. CART RESPONSE (Wrapper trả về từ Backend)
/// Class này bắt buộc phải có để CartService không bị lỗi
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
  final double subtotal;
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
      id: json['id'],
      currency: json['currency'] ?? 'VND',
      itemsCount: json['itemsCount'] ?? 0,
      itemsQuantity: json['itemsQuantity'] ?? 0,
      // Backend trả về string 'Decimal', parse sang double
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

/// ---------------------------------------------------------------------------
/// 3. CART ITEM MODEL (Chi tiết sản phẩm)
/// ---------------------------------------------------------------------------
class CartItemModel {
  final int id;         // ID dòng trong giỏ (dùng để xóa/sửa)
  final int productId;
  final int? variantId;
  final String title;
  final String? variantName;
  final String? sku;
  final int? imageId;
  final double price;
  final int quantity;

  // Constructor
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
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['productId'],
      variantId: json['variantId'],
      title: json['title'] ?? 'Sản phẩm',
      variantName: json['variantName'],
      sku: json['sku'],
      imageId: json['imageId'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }
}