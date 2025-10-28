import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import 'shop_register_screen.dart';

class ShopManagementScreen extends StatelessWidget {
  const ShopManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context);

    // Tự động load shop khi vào màn hình
    Future.microtask(() {
      if (authProvider.accessToken != null) {
        shopProvider.loadMyShop(authProvider.accessToken!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Shop'),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: shopProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopProvider.error != null
          ? _buildError(context, shopProvider.error!)
          : shopProvider.shop == null
          ? _buildNoShop(context)
          : _buildShopInfo(context, shopProvider, authProvider),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Lỗi: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoShop(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có shop',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopRegisterScreen()),
              );
            },
            icon: const Icon(Icons.add_business),
            label: const Text('Đăng ký Shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo(
      BuildContext context, ShopProvider shopProvider, AuthProvider authProvider) {
    final shop = shopProvider.shop!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin shop
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên Shop', style: Theme.of(context).textTheme.titleMedium),
                  Text(shop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
                  Text(shop.description ?? 'Chưa có mô tả', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text('Địa chỉ', style: Theme.of(context).textTheme.titleMedium),
                  Text(shop.address ?? 'Chưa có địa chỉ', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nút hành động
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, shopProvider, authProvider),
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context, shopProvider, authProvider),
                  icon: const Icon(Icons.delete),
                  label: const Text('Xóa Shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ShopProvider shopProvider, AuthProvider authProvider) {
    final shop = shopProvider.shop!;
    final nameCtrl = TextEditingController(text: shop.name);
    final descCtrl = TextEditingController(text: shop.description ?? '');
    final addrCtrl = TextEditingController(text: shop.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên Shop *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ *',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: shopProvider.isLoading
                ? null
                : () async {
              final data = {
                'name': nameCtrl.text.trim(),
                if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
                'address': addrCtrl.text.trim(),
              };
              await shopProvider.update(data, authProvider.accessToken!);
              Navigator.pop(ctx);
              _showResult(context, shopProvider);
            },
            child: shopProvider.isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ShopProvider shopProvider, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa Shop'),
        content: const Text('Bạn có chắc chắn muốn xóa shop này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;

    if (confirm) {
      await shopProvider.delete(authProvider.accessToken!);
      _showResult(context, shopProvider);
    }
  }

  void _showResult(BuildContext context, ShopProvider shopProvider) {
    final message = shopProvider.error ?? 'Thành công!';
    final isError = shopProvider.error != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );

    if (!isError && shopProvider.shop == null) {
      Navigator.pop(context); // Quay lại profile nếu xóa shop
    }
  }
}