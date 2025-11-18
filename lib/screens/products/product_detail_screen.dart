// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import 'products/add_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool isFromShopManagement;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isFromShopManagement = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoadingVariants = false;
  List<dynamic> _variants = [];

  @override
  void initState() {
    super.initState();
    _fetchVariants();
  }

  Future<void> _fetchVariants() async {
    setState(() => _isLoadingVariants = true);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final result = await productProvider.listVariants(widget.product.id);
    if (mounted) {
      setState(() {
        _isLoadingVariants = false;
        _variants = result ?? [];
      });
    }
  }

  bool _canEditOrDelete() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (authProvider.user == null || shopProvider.shop == null) return false;

    final userRole = authProvider.user!.role?.toUpperCase();
    final isAdmin = userRole == 'ADMIN';
    final isSeller = userRole == 'SELLER';
    final isOwnerOfThisShop = shopProvider.shop!.id == widget.product.shopId;

    return (isAdmin || (isSeller && isOwnerOfThisShop)) && widget.isFromShopManagement;
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
    );
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã mua sản phẩm')),
    );
  }

  void _confirmDelete(BuildContext context, int productId) async {
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
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(productId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final canEdit = _canEditOrDelete();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === ẢNH ===
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                    product.imageUrl,
                    height: 180,
                    width: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      width: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  )
                      : Container(
                    height: 180,
                    width: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // === TIÊU ĐỀ ===
            Text(product.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // === MÔ TẢ ===
            if (product.description != null && product.description!.isNotEmpty)
              Text(product.description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 12),

            // === GIÁ + TRẠNG THÁI ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${product.price.toStringAsFixed(0)}₫', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(product.status == 'ACTIVE' ? 'Hoạt động' : 'Ẩn', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // === KHO ===
            Text(product.stock != null ? 'Kho: ${product.stock}' : 'Chưa có thông tin kho', style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 16),

            // === BIẾN THỂ ===
            if (product.variants != null && product.variants!.isNotEmpty) ...[
              const Text('Biến thể', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...product.variants!.map((variant) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(variant.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: variant.options.map<Widget>((option) {
                        return Chip(label: Text(option), backgroundColor: Colors.grey.shade200, labelStyle: const TextStyle(fontSize: 12));
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ],

            // === NÚT HÀNH ĐỘNG ===
            const SizedBox(height: 24),
            if (!canEdit) ...[
              // NGƯỜI MUA / XEM Ở HOME
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Thêm vào giỏ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _buyNow,
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Mua ngay'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // CHỦ SHOP MỞ TỪ SHOPMANAGEMENT → 2 NÚT SỬA + XÓA
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductScreen(editProduct: product),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Sửa', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          side: const BorderSide(color: Colors.blue),
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmDelete(context, product.id),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Xóa', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}