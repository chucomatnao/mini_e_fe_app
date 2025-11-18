// lib/screens/shop_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
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
      appBar: AppBar(
        title: const Text('Danh sách Shop'),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search + Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm shop...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Trạng thái'),
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả')),
                    const DropdownMenuItem(value: 'ACTIVE', child: Text('Hoạt động')),
                    const DropdownMenuItem(value: 'PENDING', child: Text('Chờ duyệt')),
                    const DropdownMenuItem(value: 'SUSPENDED', child: Text('Bị khóa')),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedStatus = val);
                    _search();
                  },
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.filter_list)),
              ],
            ),
          ),

          // Danh sách
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                ? Center(child: Text('Lỗi: ${provider.error}'))
                : provider.shops.isEmpty
                ? const Center(child: Text('Không có shop nào'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: provider.shops.length,
              itemBuilder: (ctx, i) {
                final shop = provider.shops[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: shop.logoUrl != null
                          ? NetworkImage(shop.logoUrl!)
                          : const AssetImage('assets/placeholder_shop.png') as ImageProvider,
                    ),
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${shop.stats.productCount} sản phẩm'),
                        Text.rich(TextSpan(
                          children: [
                            const WidgetSpan(child: Icon(Icons.star, size: 16, color: Colors.amber)),
                            TextSpan(text: ' ${shop.stats.ratingAvg.toStringAsFixed(1)} (${shop.stats.reviewCount})'),
                          ],
                        )),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        shop.status == 'ACTIVE'
                            ? 'Hoạt động'
                            : shop.status == 'PENDING'
                            ? 'Chờ duyệt'
                            : 'Bị khóa',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: shop.status == 'ACTIVE'
                          ? Colors.green[100]
                          : shop.status == 'PENDING'
                          ? Colors.orange[100]
                          : Colors.red[100],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopDetailScreen(shop: shop),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}