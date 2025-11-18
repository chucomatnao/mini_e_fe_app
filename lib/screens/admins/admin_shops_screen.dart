// lib/screens/admin/admin_shops_screen.dart
import 'package:flutter/material.dart';
import '../../models/shop_model.dart';
import '../../service/shop_service.dart';

class AdminShopsScreen extends StatefulWidget {
  @override
  _AdminShopsScreenState createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends State<AdminShopsScreen> {
  String _filterStatus = 'ALL'; // ALL, PENDING, ACTIVE, REJECTED, BANNED
  late Future<List<ShopModel>> _shopsFuture;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() {
    if (_filterStatus == 'ALL') {
      _shopsFuture = ShopService().getShops(); // lấy tất cả
    } else {
      _shopsFuture = ShopService().getShops(status: _filterStatus);
    }
  }

  Future<void> _updateStatus(int shopId, String newStatus) async {
    try {
      await ShopService().update(shopId, {'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái shop!')),
      );
      setState(() => _loadShops());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Shop'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _filterStatus,
              decoration: InputDecoration(
                labelText: 'Lọc theo trạng thái',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                'ALL',
                'PENDING',
                'ACTIVE',
                'REJECTED',
                'BANNED',
              ]
                  .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s == 'ALL' ? 'Tất cả' : s),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _filterStatus = val!;
                  _loadShops();
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ShopModel>>(
              future: _shopsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                final shops = snapshot.data ?? [];
                if (shops.isEmpty) {
                  return Center(
                    child: Text(
                      _filterStatus == 'ALL'
                          ? 'Chưa có shop nào'
                          : 'Không có shop nào ở trạng thái này',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: shops.length,
                  itemBuilder: (_, i) {
                    final shop = shops[i];
                    final isPending = shop.status == 'PENDING';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(shop.name.isNotEmpty ? shop.name[0] : '?'),
                        ),
                        title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${shop.email ?? 'Chưa có'}'),
                            Text('Trạng thái: ${shop.status}',
                                style: TextStyle(color: _statusColor(shop.status))),
                          ],
                        ),
                        trailing: isPending
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _updateStatus(shop.id, 'ACTIVE'),
                              child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _updateStatus(shop.id, 'REJECTED'),
                              child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                            : PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (val) => _updateStatus(shop.id, val),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'ACTIVE', child: Text('Mở hoạt động')),
                            const PopupMenuItem(value: 'BANNED', child: Text('Khóa shop')),
                            const PopupMenuItem(value: 'PENDING', child: Text('Đưa về chờ duyệt')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'BANNED':
        return Colors.black54;
      default:
        return Colors.grey;
    }
  }
}