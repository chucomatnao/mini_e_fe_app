// lib/models/order_model.dart

class OrderPreview {
  final double subtotal;
  final double shippingFee;
  final double total;

  OrderPreview({
    required this.subtotal,
    required this.shippingFee,
    required this.total,
  });

  factory OrderPreview.fromJson(Map<String, dynamic> json) {
    return OrderPreview(
      // Parse an toàn: chuyển sang String rồi parse Double để tránh lỗi int/double
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      shippingFee: double.tryParse(json['shippingFee'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
    );
  }
}

// ĐỔI TÊN: OrderItemModel -> OrderModel (Vì đây là object Đơn hàng)
class OrderModel {
  final String id;
  final String code;
  final String status;        // PENDING, PAID, SHIPPED...
  final String paymentStatus; // UNPAID, PAID...
  final String paymentMethod; // COD, VNPAY
  final double total;
  final DateTime createdAt;
  // Bổ sung list items chi tiết nếu cần hiển thị
  final List<dynamic>? items;

  OrderModel({
    required this.id,
    required this.code,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.total,
    required this.createdAt,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      code: json['code'],
      status: json['status'],
      // Backend có thể trả về camelCase hoặc snake_case tuỳ config, check cả 2 cho chắc
      paymentStatus: json['payment_status'] ?? json['paymentStatus'] ?? 'UNPAID',
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? 'COD',
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // Fallback
      items: json['items'],
    );
  }
}