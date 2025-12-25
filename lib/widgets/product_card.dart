// lib/widgets/product_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String id; // Lưu ý: Backend ID là int, nhưng FE có thể ép sang String để hiển thị
  final String name;
  final double price;
  final String imageUrl;
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
              // === PHẦN HIỂN THỊ ẢNH (DEBUG VERSION) ===
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: _buildProductImage(),
                ),
              ),
              // ==========================================

              const SizedBox(width: 12),

              // Phần thông tin Text (Giữ nguyên)
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

  // === HÀM XỬ LÝ ẢNH ĐỂ DEBUG ===
  Widget _buildProductImage() {
    // 1. IN RA CONSOLE ĐỂ KIỂM TRA URL
    // Hãy mở tab "Run" hoặc "Debug Console" trong IDE để xem dòng này
    if (imageUrl.isNotEmpty) {
      print('>>> DEBUG IMG [Product ID: $id]: $imageUrl');
    } else {
      print('>>> DEBUG IMG [Product ID: $id]: URL RỖNG !!!');
    }

    // TRƯỜNG HỢP 1: Không có link ảnh
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
              SizedBox(height: 4),
              Text("No URL", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    // TRƯỜNG HỢP 2: Có link -> Tải ảnh
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,

      // Loading
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),

      // Error Widget (Quan trọng để bắt lỗi)
      errorWidget: (context, url, error) {
        // In lỗi chi tiết ra console
        print('!!! LỖI TẢI ẢNH [ID: $id]: $error');
        print('!!! URL GÂY LỖI: $url');

        return Container(
          color: Colors.red[50], // Nền đỏ nhạt để dễ nhận biết lỗi
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, color: Colors.red),
              const SizedBox(height: 2),
              Text(
                "Error Load",
                style: TextStyle(color: Colors.red[800], fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}