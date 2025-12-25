// lib/screens/shops/shop_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_model.dart';
import '../../widgets/osm_location_picker.dart';

class ShopDetailScreen extends StatelessWidget {
  final ShopModel shop;

  const ShopDetailScreen({Key? key, required this.shop}) : super(key: key);

  // --- LOGIC CŨ GIỮ NGUYÊN ---
  void _openMap(BuildContext context) {
    if (shop.shopLat == null || shop.shopLng == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            Text('Vị trí: ${shop.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(shop.shopAddress ?? 'Chưa cập nhật địa chỉ', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: OsmLocationPicker(
                  initLat: shop.shopLat,
                  initLng: shop.shopLng,
                  onPicked: (lat, lng) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D6EFD);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header Cover Image (Đã thu nhỏ theo yêu cầu)
          SliverAppBar(
            expandedHeight: 200.0, // Đã giảm từ 250 xuống 200 cho nhỏ gọn hơn
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: primaryBlue,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: const BackButton(color: Colors.white),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  shop.coverUrl != null
                      ? Image.network(shop.coverUrl!, fit: BoxFit.cover)
                      : Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.store, size: 60, color: Colors.grey)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main Content Card
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  // Đẩy lên nhẹ hơn (-20 thay vì -24) để tránh lỗi hiển thị
                  transform: Matrix4.translationValues(0, -20, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // --- CARD THÔNG TIN CHÍNH ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                    image: shop.logoUrl != null
                                        ? DecorationImage(image: NetworkImage(shop.logoUrl!), fit: BoxFit.cover)
                                        : null,
                                    color: Colors.grey[100],
                                  ),
                                  child: shop.logoUrl == null
                                      ? Icon(Icons.storefront, color: Colors.grey[400], size: 30)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop.name,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            shop.stats.ratingAvg.toStringAsFixed(1),
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            ' (${shop.stats.reviewCount} đánh giá)',
                                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              shop.status,
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Sản phẩm', '${shop.stats.productCount}'),
                                Container(width: 1, height: 24, color: Colors.grey[300]),
                                _buildStatItem('Đơn hàng', _formatKNumber(shop.stats.orderCount)),
                                Container(width: 1, height: 24, color: Colors.grey[300]),
                                _buildStatItem('Tham gia', '${shop.createdAt.year}'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- SECTION: GIỚI THIỆU & LIÊN HỆ ---
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (shop.description != null && shop.description!.isNotEmpty) ...[
                              const Text('Giới thiệu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                shop.description!,
                                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
                              ),
                              const SizedBox(height: 24),
                            ],
                            const Text('Thông tin liên hệ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            if (shop.phone != null) _buildContactRow(Icons.phone_outlined, 'Hotline', shop.phone!),
                            if (shop.email != null) _buildContactRow(Icons.email_outlined, 'Email', shop.email!),
                            const Divider(height: 32),
                            const Text('Địa chỉ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildAddressWithMapBtn(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatKNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressWithMapBtn(BuildContext context) {
    bool hasMap = shop.shopLat != null && shop.shopLng != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.location_on_outlined, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            shop.shopAddress ?? 'Chưa cập nhật',
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
        ),
        if (hasMap)
          InkWell(
            onTap: () => _openMap(context),
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFF0D6EFD),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0D6EFD).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                  ]
              ),
              child: const Icon(Icons.map, color: Colors.white, size: 22),
            ),
          )
      ],
    );
  }
}