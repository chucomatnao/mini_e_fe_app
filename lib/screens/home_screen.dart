// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Cache tồn kho theo product.id
  final Map<int, int> _stockCache = {};

  // Lấy tồn kho thực tế từ biến thể
  Future<int> _getRealStock(ProductModel product) async {
    if (_stockCache.containsKey(product.id)) {
      return _stockCache[product.id]!;
    }

    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final variants = await provider.listVariants(product.id);

      int total = 0;
      if (variants != null && variants.isNotEmpty) {
        for (var v in variants) {
          final s = v['stock'];
          if (s is int) total += s;
          if (s is String) total += int.tryParse(s) ?? 0;
        }
      } else {
        total = product.stock ?? 0;
      }

      _stockCache[product.id] = total;
      return total;
    } catch (e) {
      final fallback = product.stock ?? 0;
      _stockCache[product.id] = fallback;
      return fallback;
    }
  }

  // Dialog thêm vào giỏ hàng – khôi phục đầy đủ
  void _showProductCartDialog(ProductModel product, {bool isBuyNow = false}) async {
    int quantity = 1;
    int? selectedVariantId;
    List<dynamic> variants = [];

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
          int maxStock = 999999;
          if (selectedVariantId != null) {
            final selected = variants.firstWhere(
                  (v) => v['id'] == selectedVariantId,
              orElse: () => null,
            );
            if (selected != null) {
              final s = selected['stock'];
              maxStock = s is int ? s : (s is String ? int.tryParse(s) ?? 0 : 0);
            }
          } else if (_stockCache.containsKey(product.id)) {
            maxStock = _stockCache[product.id]!;
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
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
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
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${product.price.toInt()}₫',
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  // Không hiển thị trạng thái ở đây – chỉ hiển thị ở ProductDetailScreen khi isFromShopManagement = true
                                ],
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<int>(
                                future: _getRealStock(product),
                                builder: (context, snapshot) {
                                  final stock = snapshot.data ?? 0;
                                  return Text(
                                    'Tồn kho: ${stock > 0 ? stock : 'Hết hàng'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: stock > 0 ? Colors.black87 : Colors.red,
                                      fontWeight: stock > 0 ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (variants.isNotEmpty) ...[
                    const Text('Chọn phân loại:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: variants.map((v) {
                        final isSelected = selectedVariantId == v['id'];
                        final stock = v['stock'] is int ? v['stock'] : (v['stock'] is String ? int.tryParse(v['stock']) ?? 0 : 0);
                        return GestureDetector(
                          onTap: stock <= 0 ? null : () => setStateDialog(() => selectedVariantId = v['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D6EFD) : (stock <= 0 ? Colors.grey.shade200 : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? const Color(0xFF0D6EFD) : Colors.transparent),
                            ),
                            child: Text(
                              '${v['name'] ?? 'Biến thể'} (${stock > 0 ? 'Còn $stock' : 'Hết'})',
                              style: TextStyle(
                                color: isSelected ? Colors.white : (stock <= 0 ? Colors.grey : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

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
                          SizedBox(
                            width: 60,
                            child: Text(
                              '$quantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
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
                      child: Text(
                        isBuyNow ? 'Mua ngay' : 'Thêm vào giỏ hàng',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: screenWidth,
                height: screenHeight * 0.12,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mini E',
                      style: TextStyle(color: Color(0x960004FF), fontSize: 26, fontFamily: 'Quicksand', fontWeight: FontWeight.w700),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng tìm kiếm sắp được thêm!'))),
                          child: Container(
                            height: 45,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF7F7F7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 1, color: Color(0xFF0D6EFD)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.search, size: 20, color: Colors.grey),
                                SizedBox(width: 10),
                                Text(
                                  'Search',
                                  style: TextStyle(color: Color(0xFF8A96A4), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
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
                              if (itemsCount > 0)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: Text(
                                      itemsCount > 99 ? '99+' : '$itemsCount',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              const Positioned(
                                bottom: -24,
                                left: -10,
                                right: -10,
                                child: Text(
                                  'My cart',
                                  style: TextStyle(color: Color(0xFF0A75FF), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
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
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE0E0E0)),
                    bottom: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
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
                    const Text('Danh sách sản phẩm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                        if (productProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (productProvider.products.isEmpty) {
                          return const Center(child: Text('Chưa có sản phẩm nào'));
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3))],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                          child: const Icon(Icons.image),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${product.price.toInt()}₫',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                        // Không hiển thị trạng thái trên HomeScreen
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<int>(
                                      future: _getRealStock(product),
                                      builder: (context, snapshot) {
                                        final stock = snapshot.data ?? 0;
                                        return Text(
                                          stock > 0 ? 'Kho: $stock' : 'Hết hàng',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: stock > 0 ? Colors.black54 : Colors.red,
                                            fontWeight: stock > 0 ? FontWeight.normal : FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
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
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showProductCartDialog(product),
                                            icon: const Icon(Icons.add_shopping_cart, size: 14),
                                            label: const Text('Giỏ', style: TextStyle(fontSize: 11)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              side: const BorderSide(color: Colors.blue),
                                              foregroundColor: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showProductCartDialog(product, isBuyNow: true),
                                            icon: const Icon(Icons.flash_on, size: 14),
                                            label: const Text('Mua', style: TextStyle(fontSize: 11)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 4) {
            Navigator.pushNamed(context, '/profile');
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF5F5F5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF1C1C1C), fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}