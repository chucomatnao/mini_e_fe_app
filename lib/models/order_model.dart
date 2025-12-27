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
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      shippingFee: double.tryParse(json['shippingFee'].toString()) ?? 0.0,
      total: double.tryParse(json['total'].toString()) ?? 0.0,
    );
  }
}

class OrderModel {
  final String id;
  final String code;
  final String status;        // PENDING, PAID, PROCESSING, SHIPPED, COMPLETED, CANCELLED
  final String paymentStatus; // UNPAID, PAID, REFUNDED
  final String paymentMethod; // COD, VNPAY
  final String shippingStatus; // PENDING, PICKED, IN_TRANSIT, DELIVERED, RETURNED, CANCELED
  final double total;
  final DateTime createdAt;

  final dynamic paymentMeta; // json object (có thể chứa { sessionCode: ... })
  final List<dynamic>? items;

  OrderModel({
    required this.id,
    required this.code,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingStatus,
    required this.total,
    required this.createdAt,
    this.paymentMeta,
    this.items,
  });

  String? get sessionCode {
    final meta = paymentMeta;
    if (meta is Map && meta['sessionCode'] != null) return meta['sessionCode'].toString();
    return null;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] ?? json['createdAt'];

    return OrderModel(
      id: json['id'].toString(),
      code: json['code'].toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? 'UNPAID').toString(),
      paymentMethod: (json['payment_method'] ?? json['paymentMethod'] ?? 'COD').toString(),
      shippingStatus: (json['shipping_status'] ?? json['shippingStatus'] ?? 'PENDING').toString(),
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      createdAt: createdRaw != null ? DateTime.parse(createdRaw.toString()) : DateTime.now(),
      paymentMeta: json['payment_meta'] ?? json['paymentMeta'],
      items: json['items'],
    );
  }
}
