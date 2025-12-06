// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // HÀM HIỆN DIALOG THÊM VÀO GIỎ HÀNG (dùng chung cho cả "Giỏ" và "Mua")
  void _showProductCartDialog(BuildContext context, ProductModel product, {bool isBuyNow = false}) async {
    int quantity = 1;
    int? selectedVariantId;
    List<dynamic> variants = [];
    bool isLoadingVariants = true;

    // GỌI API LẤY BIẾN THỂ (giống hệt ProductDetailScreen)
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      final result = await productProvider.listVariants(product.id);
      variants = result ?? [];
    } catch (e) {
      variants = [];
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Tính tồn kho
          int maxStock = product.stock ?? 999999;
          if (selectedVariantId != null) {
            final selected = variants.firstWhere((v) => v['id'] == selectedVariantId, orElse: () => {});
            maxStock = selected['stock'] is int ? selected['stock'] : 999999;
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 650),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút đóng
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
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
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(product.imageUrl, height: 140, width: 140, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 140, width: 140, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 40)))
                              : Container(height: 140, width: 140, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${product.price.toInt()}₫', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                                    child: Text(product.status == 'ACTIVE' ? 'Hoạt động' : 'Ẩn', style: const TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Tồn kho: $maxStock', style: TextStyle(fontSize: 13, color: maxStock > 0 ? Colors.black87 : Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CHỌN BIẾN THỂ
                  if (variants.isNotEmpty) ...[
                    const Text('Chọn phân loại:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: variants.map((v) {
                        final isSelected = selectedVariantId == v['id'];
                        final stock = v['stock'] is int ? v['stock'] : 999999;
                        return GestureDetector(
                          onTap: stock <= 0 ? null : () => setStateDialog(() {
                            selectedVariantId = v['id'];
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D6EFD) : (stock <= 0 ? Colors.grey.shade200 : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent),
                            ),
                            child: Text(
                              v['name'] ?? 'Biến thể',
                              style: TextStyle(color: isSelected ? Colors.white : (stock <= 0 ? Colors.grey : Colors.black87)),
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
                    const Padding(padding: EdgeInsets.only(top: 8), child: Text('Đã đạt tối đa tồn kho', style: TextStyle(color: Colors.red, fontSize: 12))),

                  const SizedBox(height: 30),

                  // NÚT XÁC NHẬN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (variants.isNotEmpty && selectedVariantId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phân loại')));
                          return;
                        }
                        if (quantity > maxStock) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số lượng vượt quá tồn kho')));
                          return;
                        }

                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        final success = await cartProvider.addItem(
                          productId: product.id,
                          variantId: selectedVariantId,
                          quantity: quantity,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green));
                          Navigator.pop(context);
                          if (isBuyNow) Navigator.pushNamed(context, '/cart');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cartProvider.error ?? 'Lỗi'), backgroundColor: Colors.red));
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
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final userName = authProvider.user?.name;
    final displayInitial = (userName != null && userName.isNotEmpty) ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            color: Colors.white,
            child: Column(
              children: [
                // HEADER: Logo + Tìm kiếm + My cart (GIỮ NGUYÊN 100%)
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.12,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mini E', style: TextStyle(color: Color(0x960004FF), fontSize: 26, fontFamily: 'Quicksand', fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: GestureDetector(
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng tìm kiếm sắp được thêm!'))),
                            child: Container(
                              height: 45,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF7F7F7),
                                shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xFF0D6EFD)), borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Row(children: [SizedBox(width: 15), Icon(Icons.search, size: 20, color: Colors.grey), SizedBox(width: 10), Text('Search', style: TextStyle(color: Color(0xFF8A96A4), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500))]),
                            ),
                          ),
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final itemsCount = cartProvider.cart?.itemsCount ?? 0;
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/cart'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: Color(0xFF0A75FF), size: 28),
                                if (itemsCount > 0 && !cartProvider.isLoading)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: Text(itemsCount > 99 ? '99+' : '$itemsCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                    ),
                                  ),
                                const Positioned(bottom: -24, left: -10, right: -10, child: Text('My cart', style: TextStyle(color: Color(0xFF0A75FF), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // DANH MỤC NGANG
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE0E0E0)), bottom: BorderSide(color: Color(0xFFE0E0E0)))),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _CategoryItem(label: 'All category'),
                      _CategoryItem(label: 'Hot offers'),
                      _CategoryItem(label: 'Gift boxes'),
                      _CategoryItem(label: 'Projects'),
                      _CategoryItem(label: 'Menu item'),
                      _CategoryItem(label: 'Help'),
                    ],
                  ),
                ),

                // DANH SÁCH SẢN PHẨM
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Danh sách sản phẩm', style: TextStyle(color: Color(0xFF181821), fontSize: 22, fontFamily: 'Quicksand', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          if (productProvider.isLoading) {
                            return const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Đang tải sản phẩm...')]));
                          }
                          if (productProvider.error != null) {
                            return Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text('Lỗi: ${productProvider.error}', style: const TextStyle(color: Colors.red)),
                                  ElevatedButton(onPressed: () => productProvider.fetchProducts(), child: const Text('Thử lại')),
                                ],
                              ),
                            );
                          }
                          if (productProvider.products.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  const Text('Chưa có sản phẩm nào.\nHãy thêm sản phẩm đầu tiên!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                                  ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/add-product'), icon: const Icon(Icons.add), label: const Text('Thêm sản phẩm')),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = productProvider.products[index];

                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3))]),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: product.imageUrl.isNotEmpty
                                              ? Image.network(product.imageUrl, height: 140, width: 140, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 140, width: 140, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 40)))
                                              : Container(height: 140, width: 140, color: Colors.grey[300], child: const Icon(Icons.image, size: 40)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(product.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${product.price.toInt()}₫', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                                            child: Text(product.status == 'ACTIVE' ? 'Hoạt động' : 'Ẩn', style: const TextStyle(fontSize: 9)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (product.stock != null)
                                        Text('Kho: ${product.stock}', style: TextStyle(fontSize: 11, color: product.stock! > 0 ? Colors.black54 : Colors.red)),
                                      if (product.variants != null && product.variants!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Wrap(
                                            spacing: 4,
                                            children: product.variants!.take(2).map((v) {
                                              final opt = v.options.isNotEmpty ? v.options.first : '';
                                              return Chip(label: Text(opt, style: const TextStyle(fontSize: 9)), backgroundColor: Colors.grey.shade200, padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap);
                                            }).toList(),
                                          ),
                                        ),
                                      const Spacer(),

                                      // 2 NÚT – DÙNG DIALOG MỚI
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 32,
                                              child: OutlinedButton.icon(
                                                onPressed: () => _showProductCartDialog(context, product, isBuyNow: false),
                                                icon: const Icon(Icons.add_shopping_cart, size: 14),
                                                label: const Text('Giỏ', style: TextStyle(fontSize: 11)),
                                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), side: const BorderSide(color: Colors.blue), foregroundColor: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: SizedBox(
                                              height: 32,
                                              child: ElevatedButton.icon(
                                                onPressed: () => _showProductCartDialog(context, product, isBuyNow: true),
                                                icon: const Icon(Icons.flash_on, size: 14),
                                                label: const Text('Mua', style: TextStyle(fontSize: 11)),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 4)),
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chuyển đến tab $index')));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Mall'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Live & Video'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tôi'),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  const _CategoryItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFF5F5F5)),
      child: Center(child: Text(label, style: const TextStyle(color: Color(0xFF1C1C1C), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500))),
    );
  }
}