// lib/screens/shop_management_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'shop_register_screen.dart';
import 'products/add_product_screen.dart';
import 'product_detail_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.accessToken != null) {
        context.read<ShopProvider>().loadMyShop();
        context.read<ProductProvider>().fetchProducts();
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
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
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
          const Text('Bạn chưa có shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopRegisterScreen()));
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

  Widget _buildShopInfo(BuildContext context, ShopProvider shopProvider) {
    final shop = shopProvider.shop!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD: AVATAR + TÊN + TRẠNG THÁI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: shop.logoUrl != null
                        ? NetworkImage(shop.logoUrl!) as ImageProvider
                        : null,
                    child: shop.logoUrl == null
                        ? const Icon(Icons.store, size: 40, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            shop.status == 'ACTIVE'
                                ? 'Hoạt động'
                                : shop.status == 'PENDING'
                                ? 'Chờ duyệt'
                                : 'Bị khóa',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: shop.status == 'ACTIVE'
                              ? Colors.green
                              : shop.status == 'PENDING'
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3 NÚT LỚN
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Thêm sản phẩm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, shopProvider),
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context, shopProvider),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Xóa Shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DANH SÁCH SẢN PHẨM
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              final shopProducts = productProvider.products
                  .where((product) => product.shopId == shop.id)
                  .toList();

              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (shopProducts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Chưa có sản phẩm nào.'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddProductScreen()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm sản phẩm'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sản phẩm của shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Tổng: ${shopProducts.length}'),
                        ],
                      ),
                      const SizedBox(height: 12),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: shopProducts.length,
                        itemBuilder: (context, index) {
                          final product = shopProducts[index];

                          return GestureDetector(
                            onTap: () {
                              // ĐÃ SỬA: TRUYỀN isFromShopManagement: true
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: product,
                                    isFromShopManagement: true,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ẢNH
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: product.imageUrl.isNotEmpty
                                          ? Image.network(
                                        product.imageUrl,
                                        height: 140,
                                        width: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 140,
                                          width: 140,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image, size: 40),
                                        ),
                                      )
                                          : Container(
                                        height: 140,
                                        width: 140,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image, size: 40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // TÊN
                                  Text(
                                    product.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // GIÁ + TRẠNG THÁI
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${product.price.toStringAsFixed(0)}₫',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          product.status == 'ACTIVE' ? 'Hoạt động' : 'Ẩn',
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // KHO
                                  if (product.stock != null)
                                    Text(
                                      'Kho: ${product.stock}',
                                      style: TextStyle(fontSize: 11, color: product.stock! > 0 ? Colors.black54 : Colors.red),
                                    ),

                                  // BIẾN THỂ
                                  if (product.variants != null && product.variants!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        spacing: 4,
                                        children: product.variants!.take(2).map((v) {
                                          final opt = v.options.isNotEmpty ? v.options.first : '';
                                          return Chip(
                                            label: Text(opt, style: const TextStyle(fontSize: 9)),
                                            backgroundColor: Colors.grey.shade200,
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                  const Spacer(),

                                  // 2 NÚT: SỬA + XÓA
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 32,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => AddProductScreen(editProduct: product),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.edit, size: 14),
                                            label: const Text('Sửa', style: TextStyle(fontSize: 11)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              side: const BorderSide(color: Colors.blue),
                                              foregroundColor: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: SizedBox(
                                          height: 32,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _confirmDeleteProduct(context, product.id, productProvider),
                                            icon: const Icon(Icons.delete, size: 14),
                                            label: const Text('Xóa', style: TextStyle(fontSize: 11)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, int productId, ProductProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.deleteProduct(productId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, ShopProvider shopProvider) async {
    final shop = shopProvider.shop!;
    final nameCtrl = TextEditingController(text: shop.name);
    final emailCtrl = TextEditingController(text: shop.email ?? '');
    final descCtrl = TextEditingController(text: shop.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          File? _selectedImage;

          Future<void> pickImage() async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setStateDialog(() {
                _selectedImage = File(pickedFile.path);
              });
            }
          }

          return AlertDialog(
            title: const Text('Chỉnh sửa Shop'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : shop.logoUrl != null
                          ? NetworkImage(shop.logoUrl!)
                          : null,
                      child: _selectedImage == null && shop.logoUrl == null
                          ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Bấm vào ảnh để chọn', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên Shop', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()), maxLines: 3),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: shopProvider.isLoading
                    ? null
                    : () async {
                  final data = <String, dynamic>{};
                  if (nameCtrl.text.trim() != shop.name) data['name'] = nameCtrl.text.trim();
                  if (emailCtrl.text.trim() != (shop.email ?? '')) data['email'] = emailCtrl.text.trim();
                  if (descCtrl.text.trim() != (shop.description ?? '')) data['description'] = descCtrl.text.trim();

                  if (_selectedImage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng upload ảnh đang phát triển...')),
                    );
                  }

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
          );
        },
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
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ??
        false;

    if (confirm) {
      await shopProvider.delete(shopProvider.shop!.id);
      _showResult(context, shopProvider);
    }
  }

  void _showResult(BuildContext context, ShopProvider shopProvider) {
    final message = shopProvider.error ?? 'Thành công!';
    final isError = shopProvider.error != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );

    if (!isError && shopProvider.shop == null) {
      Navigator.pop(context);
    }
  }
}