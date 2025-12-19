// lib/screens/shops/seller_product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart'; // Đảm bảo bạn đã có model này
import '../products/add_product_screen.dart'; // Màn hình thêm sản phẩm cũ của bạn
import '../products/product_detail_screen.dart'; // Màn hình chi tiết (nếu cần)

class SellerProductListScreen extends StatefulWidget {
  const SellerProductListScreen({Key? key}) : super(key: key);

  @override
  State<SellerProductListScreen> createState() => _SellerProductListScreenState();
}

class _SellerProductListScreenState extends State<SellerProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi API lấy lại danh sách sản phẩm mới nhất mỗi khi vào màn hình này
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProductsForSeller();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products; // Giả sử provider lưu list vào biến products

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Sản phẩm của tôi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Điều hướng sang màn hình thêm sản phẩm
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
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
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Bạn chưa có sản phẩm nào', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm ngay'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD)),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async => await context.read<ProductProvider>().fetchAllProductsForSeller(),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, index) => _buildProductItem(context, products[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D6EFD),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, ProductModel product) {
    // 1. Xử lý ảnh an toàn
    final String? image = (product.imageUrl != null && product.imageUrl.isNotEmpty)
        ? product.imageUrl
        : null;

    // --- BỌC INKWELL ĐỂ BẮT SỰ KIỆN BẤM VÀO SẢN PHẨM ---
    return InkWell(
      onTap: () {
        // CHỨC NĂNG 1: XEM CHI TIẾT
        // Điều hướng sang màn hình chi tiết và truyền object product sang
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
                    product.title, // Dùng title theo ProductModel
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} đ',
                    style: const TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('Kho: ${product.stock ?? 0}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          product.status ?? 'N/A',
                          style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // --- MENU THAO TÁC (SỬA / XÓA) ---
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'edit') {
                  // CHỨC NĂNG 2: SỬA SẢN PHẨM
                  // Điều hướng sang màn hình AddProductScreen nhưng truyền kèm product
                  // Màn hình AddProductScreen cần logic nhận arguments để fill dữ liệu
                  Navigator.pushNamed(
                      context,
                      '/add-product',
                      arguments: product // Truyền sản phẩm cần sửa sang
                  );
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      // Gọi Provider xóa
      // await context.read<ProductProvider>().deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi yêu cầu xóa (Cần implement Provider)')));
    }
  }
}