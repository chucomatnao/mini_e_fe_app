// lib/models/cart_model.dart
import 'cart_item_model.dart';

enum CartStatus {
  OPEN,
  CHECKING_OUT,
  LOCKED,
}

class CartModel {
  final int id;
  final int userId;
  final int itemsCount;
  final double subtotal;  // Chuyển string thành double cho dễ tính toán
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
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return CartModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      itemsCount: json['itemsCount'] ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'VND',
      status: CartStatus.values.firstWhere(
            (e) => e.toString().split('.').last == (json['status'] ?? 'OPEN'),
        orElse: () => CartStatus.OPEN,
      ),
      items: itemsJson.map((item) => CartItemModel.fromJson(item)).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemsCount': itemsCount,
      'subtotal': subtotal.toStringAsFixed(2),
      'currency': currency,
      'status': status.toString().split('.').last,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}