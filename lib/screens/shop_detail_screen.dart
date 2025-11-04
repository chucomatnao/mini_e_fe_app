// lib/screens/shop_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/shop_model.dart';

class ShopDetailScreen extends StatelessWidget {
  final ShopModel shop;

  const ShopDetailScreen({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: shop.coverUrl != null
                    ? DecorationImage(image: NetworkImage(shop.coverUrl!), fit: BoxFit.cover)
                    : null,
                color: Colors.grey[300],
              ),
              child: shop.coverUrl == null
                  ? const Center(child: Icon(Icons.store, size: 60, color: Colors.white70))
                  : null,
            ),
            const SizedBox(height: 16),

            // Logo + Name
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: shop.logoUrl != null
                      ? NetworkImage(shop.logoUrl!)
                      : const AssetImage('assets/placeholder_shop.png') as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name, style: Theme.of(context).textTheme.titleLarge),
                      Text('Slug: /shop/${shop.slug}', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Sản phẩm', shop.stats.productCount.toString(), Icons.inventory),
                _buildStat('Đơn hàng', shop.stats.orderCount.toString(), Icons.receipt),
                _buildStat('Đánh giá', shop.stats.ratingAvg.toStringAsFixed(1), Icons.star),
                _buildStat('Reviews', shop.stats.reviewCount.toString(), Icons.rate_review),
              ],
            ),
            const Divider(height: 40),

            // Thông tin
            _buildInfoRow('Email', shop.email ?? 'Chưa cung cấp'),
            _buildInfoRow('Phone', shop.phone ?? 'Chưa cung cấp'),
            _buildInfoRow('Trạng thái', _getStatusText(shop.status), _getStatusColor(shop.status)),
            _buildInfoRow('Ngày tạo', _formatDate(shop.createdAt)),

            const SizedBox(height: 20),
            const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(shop.description ?? 'Chưa có mô tả', style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to product list of this shop
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xem sản phẩm của shop (chưa triển khai)')),
                  );
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Xem sản phẩm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0D6EFD)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: TextStyle(color: valueColor ?? Colors.black87))),
        ],
      ),
    );
  }

  String _getStatusText(String status) => status == 'ACTIVE'
      ? 'Hoạt động'
      : status == 'PENDING'
      ? 'Chờ duyệt'
      : 'Bị khóa';

  Color _getStatusColor(String status) => status == 'ACTIVE'
      ? Colors.green
      : status == 'PENDING'
      ? Colors.orange
      : Colors.red;

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}