// lib/screens/shops/seller_product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers & Models
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';

// Screens
import '../products/add_product_screen.dart';
import '../products/edit_product_screen.dart';

class SellerProductListScreen extends StatefulWidget {
  const SellerProductListScreen({Key? key}) : super(key: key);

  @override
  State<SellerProductListScreen> createState() => _SellerProductListScreenState();
}

class _SellerProductListScreenState extends State<SellerProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProductsForSeller();
    });
  }

  // Hàm tính tổng tồn kho thực tế
  int _calculateTotalStock(ProductModel product) {
    // Nếu có variants → tính tổng stock từ các variant
    if (product.variants != null && product.variants!.isNotEmpty) {
      return product.variants!.fold(0, (sum, variant) => sum + variant.stock);
    }
    // Nếu không có variants → dùng stock của product (có thể null)
    return product.stock ?? 0;
  }

  // Hàm chuyển trạng thái sản phẩm
  Future<void> _toggleStatus(BuildContext context, ProductModel product) async {
    final provider = context.read<ProductProvider>();
    final success = await provider.toggleProductStatus(product.id);

    if (success && mounted) {
      final newStatus = product.status == 'ACTIVE' ? 'DRAFT' : 'ACTIVE';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chuyển trạng thái sản phẩm thành $newStatus'),
          backgroundColor: newStatus == 'ACTIVE' ? Colors.green : Colors.orange,
        ),
      );
      provider.fetchAllProductsForSeller();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Sản phẩm của tôi',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          )
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Bạn chưa có sản phẩm nào',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddProductScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm ngay'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD)),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async => await context
            .read<ProductProvider>()
            .fetchAllProductsForSeller(),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, index) =>
              _buildProductItem(context, products[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D6EFD),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, ProductModel product) {
    final String? image =
    (product.imageUrl.isNotEmpty) ? product.imageUrl : null;

    // Tính tổng tồn kho thực tế
    final int totalStock = _calculateTotalStock(product);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: product,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ẢNH ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: image != null
                    ? Image.network(image, fit: BoxFit.cover)
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),

            // --- THÔNG TIN ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} đ',
                    style: const TextStyle(
                        color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Kho: $totalStock', // ← ĐÃ SỬA: Hiển thị tổng stock thực tế
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          product.status ?? 'N/A',
                          style:
                          TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // --- NÚT CHUYỂN TRẠNG THÁI + MENU ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút chuyển trạng thái
                IconButton(
                  icon: Icon(
                    product.status == 'ACTIVE' ? Icons.visibility : Icons.visibility_off,
                    color: product.status == 'ACTIVE' ? Colors.green : Colors.grey,
                  ),
                  tooltip: product.status == 'ACTIVE' ? 'Ẩn sản phẩm' : 'Hiển thị sản phẩm',
                  onPressed: () => _toggleStatus(context, product),
                ),

                // Menu cũ
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProductScreen(product: product),
                        ),
                      );
                      if (context.mounted) {
                        context.read<ProductProvider>().fetchAllProductsForSeller();
                      }
                    } else if (value == 'delete') {
                      _confirmDeleteProduct(context, product.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        )),
                    const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Sản phẩm này sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu xóa.')),
      );
      context.read<ProductProvider>().fetchAllProductsForSeller();
    }
  }
}