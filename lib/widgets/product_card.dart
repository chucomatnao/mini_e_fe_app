// lib/widgets/product_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String imageUrl; // Biến này giờ đã chứa link đúng từ Model
  final int stock;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.stock = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === PHẦN HIỂN THỊ ẢNH (Đã sửa) ===
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: _buildProductImage(), // Gọi hàm xử lý ảnh
                ),
              ),
              // ===================================

              const SizedBox(width: 12),

              // ... (Phần thông tin Text bên phải giữ nguyên) ...
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${price.toInt()} VNĐ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock > 0 ? 'Còn $stock sản phẩm' : 'Hết hàng',
                      style: TextStyle(
                        fontSize: 12,
                        color: stock > 0 ? Colors.grey.shade700 : Colors.red,
                        fontWeight: stock > 0 ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tách riêng để xử lý logic hiển thị ảnh
  Widget _buildProductImage() {
    // TRƯỜNG HỢP 1: Không có link ảnh (rỗng hoặc null) -> Hiện khung xám
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
              SizedBox(height: 4),
              Text("No Image", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    // TRƯỜNG HỢP 2: Có link ảnh -> Tải ảnh từ mạng
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)
        ),
      ),
      errorWidget: (context, url, error) {
        // Nếu link chết/lỗi mạng -> Hiện khung xám
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}