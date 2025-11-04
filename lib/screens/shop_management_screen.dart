import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import 'shop_register_screen.dart';

class ShopManagementScreen extends StatefulWidget {
  const ShopManagementScreen({Key? key}) : super(key: key);

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Gọi 1 lần khi tab được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.accessToken != null) {
        context.read<ShopProvider>().loadMyShop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final shopProvider = Provider.of<ShopProvider>(context);

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
          : _buildShopInfo(context, shopProvider),
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
      BuildContext context, ShopProvider shopProvider) {
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
                  Text('Email', style: Theme.of(context).textTheme.titleMedium),
                  Text(shop.email ?? 'Chưa có email', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
                  Text(shop.description ?? 'Chưa có mô tả', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text('Trạng thái', style: Theme.of(context).textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: shop.status == 'ACTIVE' ? Colors.green :
                      shop.status == 'PENDING' ? Colors.orange : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shop.status == 'PENDING' ? 'Chờ duyệt' :
                      shop.status == 'ACTIVE' ? 'Hoạt động' : 'Bị khóa',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
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
                  onPressed: () => _showEditDialog(context, shopProvider),
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
                  onPressed: () => _confirmDelete(context, shopProvider),
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

  void _showEditDialog(BuildContext context, ShopProvider shopProvider) {
    final shop = shopProvider.shop!;
    final nameCtrl = TextEditingController(text: shop.name);
    final descCtrl = TextEditingController(text: shop.description ?? '');
    final emailCtrl = TextEditingController(text: shop.email ?? '');

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
                  labelText: 'Tên Shop',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
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
              final data = <String, dynamic>{};
              if (nameCtrl.text.trim() != shop.name) data['name'] = nameCtrl.text.trim();
              if (emailCtrl.text.trim() != (shop.email ?? '')) data['email'] = emailCtrl.text.trim();
              if (descCtrl.text.trim() != (shop.description ?? '')) data['description'] = descCtrl.text.trim();

              if (data.isNotEmpty) {
                await shopProvider.update(shop.id, data);
              }
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

  void _confirmDelete(BuildContext context, ShopProvider shopProvider) async {
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
    ) ?? false;

    if (confirm) {
      await shopProvider.delete(shopProvider.shop!.id);
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