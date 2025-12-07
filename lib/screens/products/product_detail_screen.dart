// lib/screens/products/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';
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
  bool _isUpdatingStatus = false;

  // Dùng để cập nhật giao diện ngay khi đổi trạng thái
  late ProductModel _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
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

  int get totalStock {
    if (_variants.isEmpty) return _currentProduct.stock ?? 0;
    return _variants.fold<int>(0, (sum, v) {
      final s = v['stock'];
      if (s is int) return sum + s;
      if (s is String) return sum + (int.tryParse(s) ?? 0);
      return sum;
    });
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    double value = price is String
        ? (double.tryParse(price) ?? 0.0)
        : (price is num ? price.toDouble() : 0.0);
    return value.toInt().toString();
  }

  bool _canManageProduct() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (authProvider.user == null || shopProvider.shop == null) return false;

    final userRole = authProvider.user!.role?.toUpperCase();
    final isSeller = userRole == 'SELLER';
    final isOwnerOfThisShop = shopProvider.shop!.id == widget.product.shopId;

    return isSeller && isOwnerOfThisShop && widget.isFromShopManagement;
  }

  // ĐỔI TRẠNG THÁI – CẬP NHẬT NGAY TRÊN GIAO DIỆN
  Future<void> _toggleProductStatus() async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.toggleProductStatus(_currentProduct.id);

    if (mounted) {
      setState(() => _isUpdatingStatus = false);

      if (success) {
        final updated = provider.products.firstWhere(
              (p) => p.id == _currentProduct.id,
          orElse: () => _currentProduct,
        );
        setState(() => _currentProduct = updated);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated.status == 'ACTIVE'
                ? 'Đã bật bán sản phẩm'
                : 'Đã tạm ẩn sản phẩm'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // DIALOG THÊM VÀO GIỎ HÀNG – ĐÃ KHÔI PHỤC ĐẦY ĐỦ
  void _showAddToCartDialog({bool isBuyNow = false}) {
    int quantity = 1;
    int? selectedVariantId;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          int maxStock = totalStock;
          if (selectedVariantId != null) {
            final selected = _variants.firstWhere(
                  (v) => v['id'] == selectedVariantId,
              orElse: () => null,
            );
            if (selected != null) {
              maxStock = selected['stock'] is int
                  ? selected['stock']
                  : (selected['stock'] is String ? int.tryParse(selected['stock']) ?? 0 : 0);
            }
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
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Thông tin sản phẩm
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
                          child: _currentProduct.imageUrl.isNotEmpty
                              ? Image.network(_currentProduct.imageUrl, height: 140, width: 140, fit: BoxFit.cover)
                              : Container(height: 140, width: 140, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_currentProduct.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_formatPrice(_currentProduct.price)}₫', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red)),
                                  if (_canManageProduct())
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _currentProduct.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _currentProduct.status == 'ACTIVE' ? 'Đang bán' : 'Nháp',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tồn kho: ${maxStock > 0 ? maxStock : 'Hết hàng'}',
                                style: TextStyle(fontSize: 13, color: maxStock > 0 ? Colors.black87 : Colors.red, fontWeight: maxStock > 0 ? FontWeight.normal : FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Chọn biến thể
                  if (_variants.isNotEmpty) ...[
                    const Text('Chọn phân loại:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _variants.map((v) {
                        final isSelected = selectedVariantId == v['id'];
                        final variantStock = v['stock'] is int
                            ? v['stock']
                            : (v['stock'] is String ? int.tryParse(v['stock']) ?? 0 : 0);
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

                  // Số lượng
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
                    const Padding(padding: EdgeInsets.only(top: 8), child: Text('Đã đạt tối đa tồn kho', style: TextStyle(color: Colors.red, fontSize: 12))),

                  const SizedBox(height: 30),

                  // Nút xác nhận
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
                          productId: _currentProduct.id,
                          variantId: selectedVariantId,
                          quantity: quantity,
                        );

                        if (!mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green));
                          Navigator.pop(context);
                          if (isBuyNow) Navigator.pushNamed(context, '/cart');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(cartProvider.error ?? 'Lỗi'), backgroundColor: Colors.red),
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
    final canManage = _canManageProduct();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProduct.title),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _currentProduct.imageUrl.isNotEmpty
                      ? Image.network(_currentProduct.imageUrl, height: 180, width: 180, fit: BoxFit.cover)
                      : Container(height: 180, width: 180, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(_currentProduct.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            if (_currentProduct.description != null && _currentProduct.description!.isNotEmpty)
              Text(_currentProduct.description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 12),

            // Giá + Trạng thái (chỉ seller quản lý mới thấy)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_formatPrice(_currentProduct.price)}₫', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),

                if (canManage)
                  GestureDetector(
                    onTap: _toggleProductStatus,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _currentProduct.status == 'ACTIVE' ? Colors.teal.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _currentProduct.status == 'ACTIVE' ? Colors.teal.shade300 : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentProduct.status == 'ACTIVE' ? 'Đang bán' : 'Nháp',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _currentProduct.status == 'ACTIVE' ? Colors.teal.shade800 : Colors.grey.shade700),
                          ),
                          const SizedBox(width: 12),
                          _isUpdatingStatus
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Switch(
                            value: _currentProduct.status == 'ACTIVE',
                            onChanged: (_) => _toggleProductStatus(),
                            activeColor: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Kho: ${totalStock > 0 ? totalStock : 'Hết hàng'}',
              style: TextStyle(fontSize: 14, color: totalStock > 0 ? Colors.black87 : Colors.red, fontWeight: totalStock > 0 ? FontWeight.normal : FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Biến thể
            if (_currentProduct.variants != null && _currentProduct.variants!.isNotEmpty) ...[
              const Text('Biến thể', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._currentProduct.variants!.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: v.options.map<Widget>((opt) => Chip(label: Text(opt), backgroundColor: Colors.grey.shade200)).toList()),
                  ],
                ),
              )),
            ],

            const SizedBox(height: 24),

            // Nút hành động
            if (!canManage)
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(onPressed: () => _showAddToCartDialog(), icon: const Icon(Icons.add_shopping_cart), label: const Text('Thêm vào giỏ'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(onPressed: () => _showAddToCartDialog(isBuyNow: true), icon: const Icon(Icons.shopping_bag), label: const Text('Mua ngay'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange))),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen(editProduct: _currentProduct))),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue), foregroundColor: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(context, _currentProduct.id),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Xóa'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
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