// lib/models/product_model.dart

class ProductModel {
  final int id;
  final String title;
  final String? description;
  final double price;

  /// Đây là trường UI dùng để hiển thị ảnh thumbnail (fix lỗi không hiện ảnh)
  final String imageUrl;

  /// Danh sách đầy đủ các ảnh từ server
  final List<ProductImage> images;

  final int? stock;
  final String? status;
  final int shopId;
  final String? slug;

  /// Cấu trúc thuộc tính (cho màn hình tạo biến thể)
  final List<OptionSchema>? optionSchema;

  /// Danh sách biến thể (cho màn hình chi tiết/edit)
  final List<VariantItem>? variants;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    this.stock,
    this.status,
    required this.shopId,
    this.slug,
    this.optionSchema,
    this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse danh sách images trả về từ Backend
    List<ProductImage> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((item) => ProductImage.fromJson(item))
          .toList();
    }

    // 2. LOGIC QUYẾT ĐỊNH ẢNH ĐẠI DIỆN
    String finalUrl = '';

    if (parsedImages.isNotEmpty) {
      // Ưu tiên 1: Lấy ảnh được đánh dấu là main
      final mainImg = parsedImages.firstWhere(
            (img) => img.isMain,
        orElse: () => parsedImages.first, // Nếu không có main thì lấy ảnh đầu tiên
      );
      finalUrl = mainImg.url;
    } else if (json['imageUrl'] != null) {
      // Ưu tiên 2: Nếu mảng images rỗng, mới xét đến trường imageUrl gốc
      finalUrl = json['imageUrl'];
    }

    // 3. XỬ LÝ ẢNH RÁC / ẢNH MẠNG LỖI
    // Nếu url chứa placeholder hoặc bị lỗi, gán về rỗng để UI hiện màu xám
    if (finalUrl.contains('via.placeholder.com')) {
      finalUrl = '';
    }

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Name',
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,

      // Gán URL đã xử lý ở trên
      imageUrl: finalUrl,

      images: parsedImages,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      status: json['status'],
      shopId: json['shopId'] ?? 0,
      slug: json['slug'],
      optionSchema: json['optionSchema'] != null
          ? (json['optionSchema'] as List).map((e) => OptionSchema.fromJson(e)).toList()
          : [],
      variants: json['variants'] != null
          ? (json['variants'] as List).map((v) => VariantItem.fromJson(v)).toList()
          : [],
    );
  }
}

// Class cho từng ảnh
class ProductImage {
  final int id;
  final String url;
  final bool isMain;

  ProductImage({
    required this.id,
    required this.url,
    required this.isMain,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      // Backend có thể trả về 'isMain' hoặc 'is_main' tùy cấu hình
      isMain: json['isMain'] == true || json['is_main'] == true,
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

/// Class đại diện cho biến thể sản phẩm (Variant)
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
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageId: json['imageId'], // có thể null
      options: parsedOptions,
    );
  }
}