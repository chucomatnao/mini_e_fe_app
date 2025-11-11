// lib/models/product_model.dart
import 'variant_model.dart'; // THÊM

class ProductModel {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String imageUrl;
  final int? stock;
  final String? status;
  final int shopId;
  final List<VariantModel>? variants; // THÊM

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.imageUrl,
    this.stock,
    this.status,
    required this.shopId,
    this.variants, // THÊM
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse variants từ optionSchema
    List<VariantModel>? variants;
    final optionSchema = json['optionSchema'];
    if (optionSchema is List && optionSchema.isNotEmpty) {
      variants = optionSchema.map((e) => VariantModel.fromJson(e)).toList();
    }

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Không có tên',
      description: json['description']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: _parseImageUrl(json['images']),
      stock: int.tryParse(json['stock']?.toString() ?? '0'),
      status: json['status']?.toString(),
      shopId: json['shopId'] ?? 0,
      variants: variants, // THÊM
    );
  }

  // Helper: parse imageUrl (giữ nguyên logic cũ)
  static String _parseImageUrl(dynamic images) {
    if (images == null) return '';
    if (images is List && images.isNotEmpty) {
      try {
        final main = images.firstWhere((img) => img['is_main'] == 1, orElse: () => images[0]);
        return main['url']?.toString() ?? '';
      } catch (_) {
        return images[0]['url']?.toString() ?? '';
      }
    }
    return '';
  }
}