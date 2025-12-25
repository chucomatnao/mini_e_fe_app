// lib/screens/products/product_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';

import 'edit_product_screen.dart';

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
  List<VariantItem> _variants = [];
  bool _isUpdatingStatus = false;

  late ProductModel _currentProduct;

  final Color _primaryColor = const Color(0xFF111827);
  final Color _accentColor = const Color(0xFF3B82F6);
  final Color _bgColor = const Color(0xFFF6F7FB);
  final Color _textTitleColor = const Color(0xFF111827);
  final Color _textBodyColor = const Color(0xFF6B7280);

  // gallery
  late final PageController _pageController;
  int _currentImageIndex = 0;

  // variant selection
  final Map<String, String> _selectedOptions = {};
  VariantItem? _selectedVariant;

  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _pageController = PageController(initialPage: 0);

    // ✅ lấy detail để có images[] + optionSchema
    _loadProductDetail();
    _fetchVariants();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final fresh = await provider.fetchProductDetail(widget.product.id);
      if (!mounted) return;
      if (fresh != null) {
        setState(() {
          _currentProduct = fresh;
          _currentImageIndex = 0;
        });
        _applyVariantSelection(); // re-calc
      }
    } catch (_) {}
  }

  Future<void> _fetchVariants() async {
    setState(() => _isLoadingVariants = true);
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final result = await productProvider.getVariants(widget.product.id);
      if (!mounted) return;
      setState(() {
        _variants = result;
        _isLoadingVariants = false;
      });
      _applyVariantSelection();
    } catch (_) {
      if (mounted) setState(() => _isLoadingVariants = false);
    }
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

  String _formatPrice(dynamic price) {
    double value = 0.0;
    if (price is String) value = double.tryParse(price) ?? 0.0;
    else if (price is num) value = price.toDouble();
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  List<ProductImage> get _images {
    if (_currentProduct.images.isNotEmpty) return _currentProduct.images;
    if (_currentProduct.imageUrl.isNotEmpty) {
      return [
        ProductImage(id: 0, url: _currentProduct.imageUrl, isMain: true, position: 0),
      ];
    }
    return [
      ProductImage(id: 0, url: 'https://placehold.co/600x600.png?text=No+Image', isMain: true, position: 0),
    ];
  }

  bool get _hasOptions =>
      _currentProduct.optionSchema != null && _currentProduct.optionSchema!.isNotEmpty;

  bool get _isFullSelection {
    if (!_hasOptions) return true;
    return _currentProduct.optionSchema!.every((opt) => _selectedOptions.containsKey(opt.name));
  }

  void _applyVariantSelection() {
    if (!_hasOptions || _variants.isEmpty) {
      setState(() => _selectedVariant = null);
      return;
    }

    if (!_isFullSelection) {
      setState(() => _selectedVariant = null);
      return;
    }

    final expectedName = _currentProduct.optionSchema!
        .map((opt) => _selectedOptions[opt.name])
        .join(' - ');

    VariantItem? found;
    try {
      found = _variants.firstWhere((v) => v.name == expectedName);
    } catch (_) {
      found = null;
    }

    setState(() => _selectedVariant = found);

    // ✅ đổi ảnh theo variant.imageId (nếu có)
    if (found?.imageId != null && _currentProduct.images.isNotEmpty) {
      final idx = _currentProduct.images.indexWhere((img) => img.id == found!.imageId);
      if (idx != -1) _jumpToImage(idx);
    }
  }

  void _jumpToImage(int index) {
    if (index < 0 || index >= _images.length) return;
    setState(() => _currentImageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  int get _displayStock {
    if (_selectedVariant != null) return _selectedVariant!.stock;
    if (_variants.isNotEmpty && _hasOptions) {
      // chưa chọn đủ biến thể: show tổng kho (nhìn cho dễ)
      return _variants.fold<int>(0, (sum, v) => sum + v.stock);
    }
    return _currentProduct.stock ?? 0;
  }

  String get _displayPrice {
    if (_selectedVariant != null && _selectedVariant!.price > 0) {
      return _formatPrice(_selectedVariant!.price);
    }
    return _formatPrice(_currentProduct.price);
  }

  Future<void> _toggleProductStatus() async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.toggleProductStatus(_currentProduct.id);
    if (!mounted) return;
    setState(() => _isUpdatingStatus = false);
    if (success) {
      final updated = provider.products.firstWhere(
        (p) => p.id == _currentProduct.id,
        orElse: () => _currentProduct,
      );
      setState(() => _currentProduct = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.status == 'ACTIVE' ? 'Đã bật bán' : 'Đã ẩn sản phẩm'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(_currentProduct.id);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _addToCart({required bool isBuyNow}) async {
    if (_hasOptions && _variants.isNotEmpty && !_isFullSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn đầy đủ phân loại')),
      );
      return;
    }
    if (_hasOptions && _variants.isNotEmpty && _selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biến thể không hợp lệ')),
      );
      return;
    }
    if (_displayStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm đã hết hàng')),
      );
      return;
    }

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(
        _currentProduct.id,
        variantId: _selectedVariant?.id,
        quantity: 1,
      );

      if (!mounted) return;

      if (isBuyNow) {
        Navigator.pushNamed(context, '/cart');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim()), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildOptionPicker() {
    if (!_hasOptions) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn phân loại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),

          ..._currentProduct.optionSchema!.map((opt) {
            final selected = _selectedOptions[opt.name];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.name, style: TextStyle(color: _textBodyColor, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: opt.values.map((value) {
                      final isSelected = selected == value;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedOptions[opt.name] = value;
                          });
                          _applyVariantSelection();
                        },
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSelected ? _primaryColor : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? _primaryColor.withOpacity(0.08) : Colors.white,
                          ),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: isSelected ? _primaryColor : _textTitleColor,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            );
          }).toList(),

          if (_variants.isNotEmpty)
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: _textBodyColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedVariant != null
                        ? 'Đã chọn: ${_selectedVariant!.name}'
                        : (_isFullSelection ? 'Không tìm thấy biến thể phù hợp' : 'Hãy chọn đủ phân loại để xem đúng giá/ảnh/kho'),
                    style: TextStyle(color: _textBodyColor, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManage = _canManageProduct();
    final images = _images;

    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          if (canManage)
            Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), shape: BoxShape.circle),
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProductScreen(product: _currentProduct)),
                ),
                icon: const Icon(Icons.edit, color: Colors.black, size: 20),
              ),
            ),
          Consumer<CartProvider>(
            builder: (_, cartProvider, __) => Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  ),
                ),
                if (cartProvider.totalItems > 0)
                  Positioned(
                    right: 14,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '${cartProvider.totalItems}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======== GALLERY ========
                  SizedBox(
                    height: MediaQuery.of(context).size.width + 80,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                          itemBuilder: (_, index) {
                            return CachedNetworkImage(
                              imageUrl: images[index].url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (_, __) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.image_not_supported, size: 70, color: Colors.grey)),
                              ),
                            );
                          },
                        ),

                        // Dots
                        if (images.length > 1)
                          Positioned(
                            bottom: 68,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (i) {
                                final isActive = _currentImageIndex == i;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                );
                              }),
                            ),
                          ),

                        // Thumbnails (click sẽ chuyển page)
                        if (images.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 16,
                            right: 16,
                            child: SizedBox(
                              height: 58,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (_, index) {
                                  final isSelected = _currentImageIndex == index;
                                  return GestureDetector(
                                    onTap: () => _jumpToImage(index),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? _primaryColor : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: images[index].url,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(color: Colors.grey.shade200),
                                          errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ======== CONTENT ========
                  Container(
                    transform: Matrix4.translationValues(0, -18, 0),
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentProduct.title,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textTitleColor),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Text(
                                '₫$_displayPrice',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _accentColor),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 16, color: _textBodyColor),
                                    const SizedBox(width: 6),
                                    Text('Kho: $_displayStock', style: TextStyle(color: _textBodyColor, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          if (_isLoadingVariants)
                            Row(
                              children: const [
                                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 10),
                                Text('Đang tải biến thể...'),
                              ],
                            ),

                          // ✅ chọn biến thể ngay trên trang
                          if (_hasOptions) ...[
                            const SizedBox(height: 12),
                            _buildOptionPicker(),
                          ],

                          const SizedBox(height: 16),

                          // description
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 10),
                                Text(
                                  _currentProduct.description ?? 'Đang cập nhật...',
                                  style: TextStyle(fontSize: 14, height: 1.5, color: _textBodyColor, fontWeight: FontWeight.w600),
                                  maxLines: _isDescriptionExpanded ? null : 4,
                                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                                if ((_currentProduct.description?.length ?? 0) > 100)
                                  InkWell(
                                    onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                                        style: TextStyle(color: _accentColor, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // manage tools
                          if (canManage) ...[
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => EditProductScreen(product: _currentProduct)),
                                      ),
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Sửa'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _toggleProductStatus,
                                      icon: Icon(
                                        _currentProduct.status == 'ACTIVE' ? Icons.visibility_off : Icons.visibility,
                                        size: 16,
                                      ),
                                      label: Text(_currentProduct.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _confirmDelete,
                                      icon: const Icon(Icons.delete, size: 16),
                                      label: const Text('Xóa'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======== BOTTOM ACTIONS ========
          if (!canManage)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, -6))],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _addToCart(isBuyNow: false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Thêm giỏ', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _addToCart(isBuyNow: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Mua ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
