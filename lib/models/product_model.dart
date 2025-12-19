// lib/models/product_model.dart

class ProductModel {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String imageUrl;
  final int? stock;
  final String? status;
  final int shopId;
  final String? slug;

  // Cấu trúc Option (VD: Màu [Đỏ, Xanh])
  final List<OptionSchema>? optionSchema;

  // Danh sách biến thể (nếu backend trả về kèm)
  final List<VariantItem>? variants;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.imageUrl,
    this.stock,
    this.status,
    required this.shopId,
    this.slug,
    this.optionSchema,
    this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse Option Schema
    List<OptionSchema>? parsedSchema;
    if (json['optionSchema'] != null && json['optionSchema'] is List) {
      parsedSchema = (json['optionSchema'] as List)
          .map((e) => OptionSchema.fromJson(e))
          .toList();
    }

    // 2. Parse Variants (nếu có trả về trong Product)
    List<VariantItem>? parsedVariants;
    if (json['variants'] != null && json['variants'] is List) {
      parsedVariants = (json['variants'] as List)
          .map((e) => VariantItem.fromJson(e))
          .toList();
    }

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? 'Không có tên',
      description: json['description']?.toString(),
      // Chuyển đổi an toàn từ String/Number sang double
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: _parseImageUrl(json['images']),
      stock: int.tryParse(json['stock']?.toString() ?? '0'),
      status: json['status']?.toString(),
      shopId: json['shopId'] ?? 0,
      slug: json['slug']?.toString(),
      optionSchema: parsedSchema,
      variants: parsedVariants,
    );
  }

  // Helper: Lấy ảnh main hoặc ảnh đầu tiên
  static String _parseImageUrl(dynamic images) {
    if (images == null) return '';
    if (images is List && images.isNotEmpty) {
      try {
        // Tìm ảnh có isMain = true hoặc 1
        final main = images.firstWhere(
              (img) => img['isMain'] == true || img['is_main'] == true || img['is_main'] == 1,
          orElse: () => images[0],
        );
        return main['url']?.toString() ?? '';
      } catch (_) {
        return images[0]['url']?.toString() ?? '';
      }
    }
    return '';
  }
}

// ==========================================================
// Class OptionSchema (Mô tả cấu trúc: Màu sắc, Size...)
// ==========================================================
class OptionSchema {
  final String name;       // VD: "Màu sắc"
  final List<String> values; // VD: ["Đỏ", "Xanh"]

  OptionSchema({required this.name, required this.values});

  factory OptionSchema.fromJson(Map<String, dynamic> json) {
    return OptionSchema(
      name: json['name']?.toString() ?? '',
      values: (json['values'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

// ==========================================================
// Class VariantItem (Biến thể cụ thể: Đỏ-S, Xanh-M...)
// ==========================================================
class VariantItem {
  final int id;
  final String name; // VD: "Đỏ - S"
  final String sku;
  final double price;
  final int stock;
  final int? imageId;

  VariantItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.imageId,
  });

  factory VariantItem.fromJson(Map<String, dynamic> json) {
    return VariantItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageId: json['imageId'] ?? json['image_id'],
    );
  }
}