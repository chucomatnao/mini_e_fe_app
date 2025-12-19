// lib/screens/shops/shop_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';
import 'shop_detail_screen.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({Key? key}) : super(key: key);

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().fetchShops();
    });
  }

  void _search() {
    context.read<ShopProvider>().fetchShops(
      q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA), // Màu nền xám nhẹ hiện đại
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Khám phá Cửa hàng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm shop...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      hint: const Icon(Icons.filter_list, color: Colors.black54),
                      icon: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Hoạt động')),
                        DropdownMenuItem(value: 'PENDING', child: Text('Chờ duyệt')),
                        DropdownMenuItem(value: 'SUSPENDED', child: Text('Bị khóa')),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedStatus = val);
                        _search();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.shops.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Chưa tìm thấy shop nào', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.shops.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (ctx, index) => _buildShopCard(context, provider.shops[index]),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, ShopModel shop) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ShopDetailScreen(shop: shop)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: shop.coverUrl != null
                        ? Image.network(shop.coverUrl!, fit: BoxFit.cover)
                        : Image.network('https://via.placeholder.com/400x120?text=No+Cover', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildStatusBadge(shop.status),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      image: DecorationImage(
                        image: shop.logoUrl != null
                            ? NetworkImage(shop.logoUrl!)
                            : const NetworkImage('https://via.placeholder.com/100') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${shop.stats.ratingAvg.toStringAsFixed(1)} | ${shop.stats.reviewCount} đánh giá',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (shop.phone != null) // Hiển thị số điện thoại nếu có
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(shop.phone!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'ACTIVE':
        bg = Colors.green;
        text = Colors.white;
        label = 'Yêu thích';
        break;
      case 'PENDING':
        bg = Colors.orange;
        text = Colors.white;
        label = 'Chờ duyệt';
        break;
      default:
        bg = Colors.red;
        text = Colors.white;
        label = 'Đã khóa';
    }

    if (status == 'ACTIVE') return const SizedBox.shrink(); // Ẩn badge nếu active cho sạch, hoặc hiện "Mall"

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}