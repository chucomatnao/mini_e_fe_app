// lib/screens/home_screen.dart
import 'package:cached_network_image/cached_network_image.dart'; // ← THÊM DÒNG NÀY
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../../models/product_model.dart';
import 'package:flutter/foundation.dart'; // cho kIsWeb (nếu dùng sau này)

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<int, int> _stockCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchPublicProducts();
    });
  }

  Future<int> _getRealStock(ProductModel product) async {
    if (_stockCache.containsKey(product.id)) {
      return _stockCache[product.id]!;
    }
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final variants = await provider.getVariants(product.id);

      int total = 0;
      if (variants.isNotEmpty) {
        for (var v in variants) {
          total += (v.stock as int);
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

  void _showProductCartDialog(ProductModel product, {bool isBuyNow = false}) async {
    int quantity = 1;
    int? selectedVariantId;
    List<dynamic> variants = [];

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      final result = await productProvider.getVariants(product.id);
      variants = result;
    } catch (e) {
      variants = [];
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          int maxStock = _stockCache[product.id] ?? 999999;

          if (selectedVariantId != null) {
            dynamic selected;
            try {
              selected = variants.firstWhere((v) => v.id == selectedVariantId);
            } catch (e) {
              selected = null;
            }
            if (selected != null) {
              maxStock = selected.stock;
            }
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh sản phẩm trong dialog - dùng CachedNetworkImage
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl.isNotEmpty
                              ? product.imageUrl
                              : 'https://via.placeholder.com/150',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${product.price.toInt()} VNĐ',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<int>(
                              future: _getRealStock(product),
                              builder: (context, snapshot) {
                                final stock = snapshot.data ?? 0;
                                return Text(
                                  'Kho: $stock',
                                  style: const TextStyle(color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (variants.isNotEmpty) ...[
                    const Text('Phân loại:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: variants.map((v) {
                        final isSelected = selectedVariantId == v.id;
                        final stock = v.stock;

                        return ChoiceChip(
                          label: Text('${v.name} ($stock)'),
                          selected: isSelected,
                          onSelected: stock <= 0
                              ? null
                              : (val) => setStateDialog(() => selectedVariantId = val ? v.id : null),
                          selectedColor: const Color(0xFF0D6EFD),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          backgroundColor: Colors.grey.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                              onPressed: quantity <= 1 ? null : () => setStateDialog(() => quantity--),
                              icon: const Icon(Icons.remove_circle_outline)),
                          Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                              onPressed: quantity >= maxStock ? null : () => setStateDialog(() => quantity++),
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D6EFD))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (variants.isNotEmpty && selectedVariantId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng chọn phân loại')));
                          return;
                        }
                        if (maxStock <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sản phẩm đã hết hàng')));
                          return;
                        }

                        try {
                          await Provider.of<CartProvider>(context, listen: false).addToCart(
                            product.id,
                            variantId: selectedVariantId,
                            quantity: quantity,
                          );

                          if (!mounted) return;
                          Navigator.pop(context);

                          if (isBuyNow) {
                            Navigator.pushNamed(context, '/cart');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm vào giỏ hàng'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          String msg = e.toString().replaceAll('Exception: ', '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isBuyNow ? 'MUA NGAY' : 'THÊM VÀO GIỎ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        centerTitle: true,
        title: const Text(
          'Mini-E',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng tìm kiếm'))),
          ),
          Consumer<CartProvider>(
            builder: (_, provider, __) => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                ),
                if ((provider.cartData?.itemsCount ?? 0) > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${provider.cartData!.itemsCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // BANNER (giữ nguyên)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'BỘ SƯU TẬP',
                          style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'MÙA HÈ',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          ),
                          child: const Text('SHOW NOW', style: TextStyle(fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 10,
                    child: Opacity(
                      opacity: 0.8,
                      child: Icon(Icons.woman, size: 140, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CATEGORIES (giữ nguyên)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _CircleCategoryItem(icon: Icons.checkroom, label: 'Áo'),
                  _CircleCategoryItem(icon: Icons.calendar_view_day, label: 'Quần'),
                  _CircleCategoryItem(icon: Icons.girl, label: 'Váy'),
                  _CircleCategoryItem(icon: Icons.do_not_step, label: 'Giày'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SẢN PHẨM NỔI BẬT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 16),

            // PRODUCT GRID
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                if (productProvider.products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Không tải được sản phẩm.\nVui lòng kiểm tra kết nối mạng.', textAlign: TextAlign.center),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PHẦN HÌNH ẢNH - DÙNG CACHEDNETWORKIMAGE
                            Expanded(
                              flex: 6,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl.isNotEmpty
                                      ? product.imageUrl
                                      : 'https://via.placeholder.com/300',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // PHẦN THÔNG TIN
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.price.toInt()} VNĐ',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<int>(
                                      future: _getRealStock(product),
                                      builder: (context, snapshot) {
                                        final stock = snapshot.data ?? 0;
                                        return Text(
                                          stock > 0 ? 'Còn $stock sản phẩm' : 'Hết hàng',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: stock > 0 ? Colors.grey.shade600 : Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => _showProductCartDialog(product),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0D6EFD).withOpacity(0.05),
                                          side: const BorderSide(color: Color(0xFF0D6EFD)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: const Text(
                                          'Thêm vào giỏ',
                                          style: TextStyle(fontSize: 13, color: Color(0xFF0D6EFD), fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 3) {
            Navigator.pushNamed(context, '/personal-info');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Danh mục'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tôi'),
        ],
      ),
    );
  }
}

class _CircleCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CircleCategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Icon(icon, color: Colors.black87, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}