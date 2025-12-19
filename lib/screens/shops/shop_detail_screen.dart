// lib/screens/shops/shop_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/shop_model.dart';

class ShopDetailScreen extends StatelessWidget {
  final ShopModel shop;

  const ShopDetailScreen({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Header Effect with Cover Image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0D6EFD),
            flexibleSpace: FlexibleSpaceBar(
              background: shop.coverUrl != null
                  ? Image.network(shop.coverUrl!, fit: BoxFit.cover)
                  : Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.store, size: 60, color: Colors.white70)),
              ),
            ),
          ),

          // 2. Info Section
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0), // Đẩy lên đè ảnh bìa xíu
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar & Name & Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                            ],
                            image: DecorationImage(
                              image: shop.logoUrl != null
                                  ? NetworkImage(shop.logoUrl!)
                                  : const NetworkImage('https://via.placeholder.com/150') as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                shop.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.verified, size: 16, color: Colors.blue[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    shop.status == 'ACTIVE' ? 'Đang hoạt động' : 'Tạm dừng',
                                    style: TextStyle(
                                      color: shop.status == 'ACTIVE' ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Sản phẩm', '${shop.stats.productCount}'),
                        _buildDivider(),
                        _buildStatItem('Đánh giá', shop.stats.ratingAvg.toStringAsFixed(1), icon: Icons.star, iconColor: Colors.amber),
                        _buildDivider(),
                        _buildStatItem('Phản hồi', '98%'), // Mock data or from backend later
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Description
                    const Text('Giới thiệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      shop.description ?? 'Chưa có mô tả.',
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Contact Info (Backend Fields)
                    const Text('Thông tin liên hệ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildContactRow(Icons.email_outlined, 'Email', shop.email ?? 'Ẩn'),
                    _buildContactRow(Icons.phone_outlined, 'Hotline', shop.phone ?? 'Chưa cập nhật'),
                    _buildContactRow(Icons.location_on_outlined, 'Địa chỉ', 'Chưa cập nhật địa chỉ'), // Backend: shopAddress
                    // Note: ShopModel frontend của bạn chưa map shopAddress, hãy thêm vào model sau.
                  ],
                ),
              ),
            ),
          ),

          // Placeholder for Product List Tab (SliverGrid/SliverList would go here)
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat ngay'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Xem sản phẩm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(height: 30, width: 1, color: Colors.grey[300]);

  Widget _buildStatItem(String label, String value, {IconData? icon, Color? iconColor}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: iconColor),
            ]
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}