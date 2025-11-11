// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool isEditMode;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isEditMode = false,
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

  bool _isOwner() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return false;
    final isAdmin = user.role?.toUpperCase() == 'ADMIN';
    final isSellerOwner = user.role?.toUpperCase() == 'SELLER' && user.shopId == widget.product.shopId;
    return isAdmin || isSellerOwner;
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: widget.isEditMode && _isOwner()
            ? [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}, tooltip: 'Chỉnh sửa'),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}, tooltip: 'Xóa'),
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.white,
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

            // Tiêu đề
            Text(
              product.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Mô tả
            if (product.description != null && product.description!.isNotEmpty)
              Text(
                product.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
            const SizedBox(height: 12),

            // Giá + Trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${product.price.toStringAsFixed(0)}₫',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.status == 'ACTIVE' ? 'Hoạt động' : 'Không rõ',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Kho
            Text(
              product.stock != null ? 'Kho: ${product.stock}' : 'Chưa có thông tin kho',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // BIẾN THỂ (từ optionSchema)
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
                      children: variant.options.map((option) {
                        return Chip(
                          label: Text(option),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ],

            const SizedBox(height: 16),

            // NÚT HÀNH ĐỘNG
            if (!widget.isEditMode) ...[
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
            ] else if (_isOwner()) ...[
              // Chỉ seller thấy nút thêm biến thể
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-variant', arguments: {'productId': product.id});
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm biến thể'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}