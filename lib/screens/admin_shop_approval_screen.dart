// lib/screens/admin_shop_approval_screen.dart
import 'package:flutter/material.dart';
import '../service/shop_service.dart';
import '../models/shop_model.dart';

class AdminShopApprovalScreen extends StatefulWidget {
  @override
  _AdminShopApprovalScreenState createState() => _AdminShopApprovalScreenState();
}

class _AdminShopApprovalScreenState extends State<AdminShopApprovalScreen> {
  late Future<List<ShopModel>> _pendingShops;

  @override
  void initState() {
    super.initState();
    _loadPendingShops();
  }

  void _loadPendingShops() {
    _pendingShops = ShopService().getShops(status: 'PENDING');
  }

  Future<void> _approveShop(int shopId) async {
    try {
      await ShopService().update(shopId, {'status': 'ACTIVE'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã duyệt shop!')),
      );
      setState(() => _loadPendingShops());
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
        title: const Text('Duyệt Shop'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ShopModel>>(
        future: _pendingShops,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final shops = snapshot.data ?? [];
          if (shops.isEmpty) {
            return const Center(child: Text('Không có shop nào chờ duyệt'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shops.length,
            itemBuilder: (ctx, i) {
              final shop = shops[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(shop.name[0])),
                  title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(shop.email ?? 'Chưa có email'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
                    onPressed: () => _approveShop(shop.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}