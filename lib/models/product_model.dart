// File chứa model cho dữ liệu sản phẩm từ API
class ProductModel {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String imageUrl;
  final int? stock;
  final String? status;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.imageUrl,
    this.stock,
    this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Nếu backend trả về images: [{url: "...", is_main: 1}, ...]
    String imageUrl = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      // Ưu tiên ảnh có is_main = 1
      final mainImage = (json['images'] as List)
          .firstWhere((img) => img['is_main'] == 1, orElse: () => json['images'][0]);
      imageUrl = mainImage['url'] ?? '';
    }

    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Không có tên',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: imageUrl,
      stock: json['stock'],
      status: json['status'],
    );
  }
}
