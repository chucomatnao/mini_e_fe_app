// lib/models/product_model.dart

class ProductModel {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String imageUrl;           // Ảnh chính (thumbnail) - giữ nguyên để tương thích cũ
  final List<ProductImage> images; // ← MỚI: Mảng ảnh đầy đủ từ backend
  final int? stock;
  final String? status;
  final int shopId;
  final String? slug;
  final List<OptionSchema>? optionSchema;
  final List<VariantItem>? variants;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],        // Default empty
    this.stock,
    this.status,
    required this.shopId,
    this.slug,
    this.optionSchema,
    this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse mảng ảnh đầy đủ
    List<ProductImage> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((imgJson) => ProductImage.fromJson(imgJson))
          .toList();
    }

    // Parse ảnh chính (thumbnail) - ưu tiên isMain, fallback ảnh đầu
    String mainImageUrl = '';
    if (parsedImages.isNotEmpty) {
      final mainImg = parsedImages.firstWhere(
            (img) => img.isMain,
        orElse: () => parsedImages[0],
      );
      mainImageUrl = mainImg.url;
    }

    // Parse variants và optionSchema (giữ nguyên)
    List<OptionSchema>? parsedSchema;
    if (json['optionSchema'] != null && json['optionSchema'] is List) {
      parsedSchema = (json['optionSchema'] as List)
          .map((e) => OptionSchema.fromJson(e))
          .toList();
    }

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
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: mainImageUrl.isNotEmpty ? mainImageUrl : (json['imageUrl']?.toString() ?? ''),
      images: parsedImages, // ← Lưu mảng đầy đủ
      stock: int.tryParse(json['stock']?.toString() ?? '0'),
      status: json['status']?.toString(),
      shopId: json['shopId'] ?? 0,
      slug: json['slug']?.toString(),
      optionSchema: parsedSchema,
      variants: parsedVariants,
    );
  }
}

// Class cho từng ảnh
class ProductImage {
  final int id;
  final String url;
  final bool isMain;
  final int position;

  ProductImage({
    required this.id,
    required this.url,
    this.isMain = false,
    this.position = 0,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      url: json['url']?.toString() ?? '',
      isMain: json['isMain'] == true || json['is_main'] == true || json['is_main'] == 1,
      position: json['position'] ?? 0,
    );
  }
}

// Giữ nguyên OptionSchema và VariantItem như cũ
class OptionSchema {
  final String name;
  final List<String> values;

  OptionSchema({required this.name, required this.values});

  factory OptionSchema.fromJson(Map<String, dynamic> json) {
    return OptionSchema(
      name: json['name']?.toString() ?? '',
      values: (json['values'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class VariantItem {
  final int id;
  final String name;
  final String sku;
  final double price;
  final int stock;
  final int? imageId;
  final List<Map<String, String>> options;

  VariantItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.imageId,
    this.options = const [],
  });

  factory VariantItem.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> parsedOptions = [];
    if (json['options'] != null && json['options'] is List) {
      parsedOptions = (json['options'] as List).map((opt) {
        return {
          'option': opt['option']?.toString() ?? '',
          'value': opt['value']?.toString() ?? '',
        };
      }).toList();
    }

    return VariantItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageId: json['imageId'] ?? json['image_id'],
      options: parsedOptions,
    );
  }
}