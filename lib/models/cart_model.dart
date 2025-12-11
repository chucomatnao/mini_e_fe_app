// lib/models/cart_model.dart
import 'package:flutter/foundation.dart';

/// ---------------------------------------------------------------------------
/// CART STATUS ENUM
/// ---------------------------------------------------------------------------
enum CartStatus {
  OPEN,
  CHECKING_OUT,
  LOCKED,
}

/// ---------------------------------------------------------------------------
/// CART ITEM MODEL – ĐÃ ĐƯỢC BỔ SUNG SIÊU MẠNH
/// ---------------------------------------------------------------------------
class CartItemModel {
  final int id;
  final int cartId;
  final int shopId;
  final int productId;
  final int? variantId;
  final int quantity;
  final double unitPrice;
  final String currency;
  final String productTitle;
  final String? variantLabel;
  final String? imageUrl;
  final bool isSelected;
  final DateTime createdAt;
  final DateTime updatedAt;

  // MỚI: Kiểm tra sản phẩm còn tồn tại không (hết hàng, bị xóa, bị ẩn)
  final bool isAvailable;        // Backend trả về hoặc frontend tự kiểm tra
  final String? unavailableReason; // "Hết hàng", "Đã bị xóa", "Tạm ẩn"...

  CartItemModel({
    required this.id,
    required this.cartId,
    required this.shopId,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
    required this.productTitle,
    this.variantLabel,
    this.imageUrl,
    required this.isSelected,
    required this.createdAt,
    required this.updatedAt,
    this.isAvailable = true,
    this.unavailableReason,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Backend có thể trả về isAvailable + reason
    final bool available = json['isAvailable'] ?? true;
    final String? reason = json['unavailableReason']?.toString();

    return CartItemModel(
      id: json['id'] ?? 0,
      cartId: json['cartId'] ?? 0,
      shopId: json['shopId'] ?? 0,
      productId: json['productId'] ?? 0,
      variantId: json['variantId'],
      quantity: json['quantity'] ?? 1,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'VND',
      productTitle: json['productTitle']?.toString() ?? 'Sản phẩm không tên',
      variantLabel: json['variantLabel']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      isSelected: json['isSelected'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      isAvailable: available,
      unavailableReason: reason,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cartId': cartId,
    'shopId': shopId,
    'productId': productId,
    'variantId': variantId,
    'quantity': quantity,
    'unitPrice': unitPrice.toStringAsFixed(2),
    'currency': currency,
    'productTitle': productTitle,
    'variantLabel': variantLabel,
    'imageUrl': imageUrl,
    'isSelected': isSelected,
    'isAvailable': isAvailable,
    'unavailableReason': unavailableReason,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Clone khi cần update local
  CartItemModel copyWith({
    int? quantity,
    bool? isSelected,
    bool? isAvailable,
    String? unavailableReason,
  }) {
    return CartItemModel(
      id: id,
      cartId: cartId,
      shopId: shopId,
      productId: productId,
      variantId: variantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      currency: currency,
      productTitle: productTitle,
      variantLabel: variantLabel,
      imageUrl: imageUrl,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableReason: unavailableReason ?? this.unavailableReason,
    );
  }

  // Tính thành tiền của item này
  double get totalPrice => unitPrice * quantity;
}

/// ---------------------------------------------------------------------------
/// CART MODEL – ĐÃ ĐƯỢC NÂNG CẤP ĐỈNH CAO
/// ---------------------------------------------------------------------------
class CartModel {
  final int id;
  final int userId;
  final int itemsCount;
  final double subtotal;
  final String currency;
  final CartStatus status;
  final List<CartItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.itemsCount,
    required this.subtotal,
    required this.currency,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    final items = itemsJson.map((e) => CartItemModel.fromJson(e)).toList();

    return CartModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      itemsCount: json['itemsCount'] ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'VND',
      status: CartStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? 'OPEN'),
        orElse: () => CartStatus.OPEN,
      ),
      items: items,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'itemsCount': itemsCount,
    'subtotal': subtotal.toStringAsFixed(2),
    'currency': currency,
    'status': status.name,
    'items': items.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // LẤY DANH SÁCH SẢN PHẨM HỢP LỆ (còn hàng, còn tồn tại)
  List<CartItemModel> get validItems => items.where((item) => item.isAvailable).toList();

  // LẤY DANH SÁCH SẢN PHẨM KHÔNG HỢP LỆ
  List<CartItemModel> get invalidItems => items.where((item) => !item.isAvailable).toList();

  // TỔNG TIỀN CHỈ TÍNH SẢN PHẨM HỢP LỆ
  double get validSubtotal {
    return validItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // TỔNG SỐ LƯỢNG SẢN PHẨM HỢP LỆ
  int get validItemsCount {
    return validItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // TỔNG TIỀN CÁC ITEM ĐƯỢC CHỌN (nếu có chọn)
  double get selectedSubtotal {
    return items
        .where((item) => item.isSelected && item.isAvailable)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get selectedItemsCount {
    return items
        .where((item) => item.isSelected && item.isAvailable)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Clone giỏ hàng
  CartModel copyWith({
    List<CartItemModel>? items,
    int? itemsCount,
    double? subtotal,
    CartStatus? status,
  }) {
    return CartModel(
      id: id,
      userId: userId,
      itemsCount: itemsCount ?? this.itemsCount,
      subtotal: subtotal ?? this.subtotal,
      currency: currency,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}