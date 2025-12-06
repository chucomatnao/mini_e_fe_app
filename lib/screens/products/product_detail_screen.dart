// lib/screens/products/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart'; // THÊM: Để thêm vào giỏ hàng
import 'add_product_screen.dart';

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

  // Format giá an toàn (fix lỗi toStringAsFixed)
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    double value = price is String
        ? (double.tryParse(price) ?? 0.0)
        : (price is num ? price.toDouble() : 0.0);
    return value.toInt().toString();
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

  // HIỆN BOTTOM SHEET CHỌN BIẾN THỂ + SỐ LƯỢNG
  // Chỉ thay đoạn hàm _showAddToCartDialog (hoặc _showAddToCartBottomSheet) bằng đoạn này:

  void _showAddToCartDialog({bool isBuyNow = false}) {
    int quantity = 1;
    int? selectedVariantId;
    int maxStock = widget.product.stock ?? 999999; // Mặc định nếu không có biến thể

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Cập nhật maxStock khi chọn biến thể
          if (selectedVariantId != null) {
            final selectedVariant = _variants.firstWhere((v) => v['id'] == selectedVariantId, orElse: () => null);
            maxStock = selectedVariant?['stock'] is int
                ? selectedVariant['stock']
                : (selectedVariant?['stock'] is String
                ? int.tryParse(selectedVariant['stock']) ?? 999999
                : 999999);
          } else {
            maxStock = widget.product.stock ?? 999999;
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 620),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút đóng
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // THÔNG TIN SẢN PHẨM
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3))],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.product.imageUrl.isNotEmpty
                              ? Image.network(widget.product.imageUrl, height: 140, width: 140, fit: BoxFit.cover)
                              : Container(height: 140, width: 140, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.product.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_formatPrice(widget.product.price)}₫', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: widget.product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                                    child: Text(widget.product.status == 'ACTIVE' ? 'Hoạt động' : 'Ẩn', style: const TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Tồn kho: $maxStock', style: TextStyle(fontSize: 13, color: maxStock > 0 ? Colors.black87 : Colors.red)),
                              if (widget.product.variants != null && widget.product.variants!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Wrap(
                                    spacing: 6,
                                    children: widget.product.variants!.take(3).map((v) {
                                      final opt = v.options.isNotEmpty ? v.options.first : '';
                                      return Chip(label: Text(opt, style: const TextStyle(fontSize: 10)), backgroundColor: Colors.grey.shade200);
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CHỌN BIẾN THỂ
                  if (_variants.isNotEmpty) ...[
                    const Text('Chọn phân loại:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _variants.map((v) {
                        final isSelected = selectedVariantId == v['id'];
                        final variantStock = v['stock'] is int ? v['stock'] : (v['stock'] is String ? int.tryParse(v['stock']) ?? 999 : 999);
                        return GestureDetector(
                          onTap: variantStock <= 0 ? null : () => setStateDialog(() => selectedVariantId = v['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D6EFD) : (variantStock <= 0 ? Colors.grey.shade200 : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent),
                            ),
                            child: Text(
                              '${v['name'] ?? 'Biến thể'} (${variantStock > 0 ? 'Còn $variantStock' : 'Hết hàng'})',
                              style: TextStyle(color: isSelected ? Colors.white : (variantStock <= 0 ? Colors.grey : Colors.black87), fontSize: 13),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // SỐ LƯỢNG
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 32),
                            onPressed: quantity <= 1 ? null : () => setStateDialog(() => quantity--),
                          ),
                          SizedBox(width: 60, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 32, color: Color(0xFF0D6EFD)),
                            onPressed: quantity >= maxStock ? null : () => setStateDialog(() => quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (quantity >= maxStock && maxStock > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Đã đạt tối đa tồn kho', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  const SizedBox(height: 30),

                  // NÚT XÁC NHẬN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_variants.isNotEmpty && selectedVariantId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phân loại')));
                          return;
                        }
                        if (quantity > maxStock) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng vượt quá tồn kho')));
                          return;
                        }

                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        final success = await cartProvider.addItem(
                          productId: widget.product.id,
                          variantId: selectedVariantId,
                          quantity: quantity,
                        );

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context);
                          if (isBuyNow) Navigator.pushNamed(context, '/cart');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(cartProvider.error ?? 'Lỗi khi thêm vào giỏ hàng'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isBuyNow ? 'Mua ngay' : 'Thêm vào giỏ hàng', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final canEdit = _canEditOrDelete();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ẢNH
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

            // TIÊU ĐỀ
            Text(product.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // MÔ TẢ
            if (product.description != null && product.description!.isNotEmpty)
              Text(product.description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 12),

            // GIÁ + TRẠNG THÁI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_formatPrice(product.price)}₫', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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

            // KHO
            Text(product.stock != null ? 'Kho: ${product.stock}' : 'Chưa có thông tin kho', style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 16),

            // BIẾN THỂ
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

            const SizedBox(height: 24),

            // NÚT HÀNH ĐỘNG
            if (!canEdit) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddToCartDialog(isBuyNow: false),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Thêm vào giỏ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddToCartDialog(isBuyNow: false),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Mua ngay'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddProductScreen(editProduct: product)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 8)),
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

  void _confirmDelete(BuildContext context, int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(productId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    }
  }
}