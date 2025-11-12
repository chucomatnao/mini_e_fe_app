// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final userName = authProvider.user?.name;
    final displayInitial = (userName != null && userName.isNotEmpty)
        ? userName[0].toUpperCase()
        : 'U';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            color: Colors.white,
            child: Column(
              children: [
                // HEADER: Logo + Tìm kiếm + My cart
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.12,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mini E',
                        style: TextStyle(
                          color: const Color(0x960004FF),
                          fontSize: 26,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tính năng tìm kiếm sắp được thêm!')),
                              );
                            },
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
                                    style: TextStyle(
                                      color: Color(0xFF8A96A4),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Điều hướng đến giỏ hàng!')),
                          );
                        },
                        child: const Text(
                          'My cart',
                          style: TextStyle(
                            color: Color(0xFF0A75FF),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

                // DANH SÁCH SẢN PHẨM (WRAP BẰNG CONSUMER ĐỂ REBUILD TỰ ĐỘNG)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách sản phẩm',
                        style: TextStyle(
                          color: Color(0xFF181821),
                          fontSize: 22,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // CONSUMER ĐỂ HANDLE LOADING/ERROR/EMPTY/DATA
                      Consumer<ProductProvider>(
                        builder: (context, productProvider, child) {
                          if (productProvider.isLoading) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Đang tải sản phẩm...'),
                                ],
                              ),
                            );
                          }

                          if (productProvider.error != null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                                  SizedBox(height: 16),
                                  Text(
                                    'Lỗi tải sản phẩm: ${productProvider.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      productProvider.clearError();
                                      productProvider.fetchProducts();
                                    },
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (productProvider.products.isEmpty) {
                            return  Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'Chưa có sản phẩm nào.\nHãy thêm sản phẩm đầu tiên!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, '/add-product'),
                                    icon: Icon(Icons.add),
                                    label: const Text('Thêm sản phẩm'),
                                  ),
                                ],
                              ),
                            );
                          }

                          // GRIDVIEW KHI CÓ DATA
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.68, // TĂNG ĐỂ TRÁNH TRÀN
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = productProvider.products[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/product-detail', arguments: product);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3)),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 1. ẢNH NHỎ HƠN → 140x140
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
                                            child: const Icon(Icons.image, size: 40),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // 2. TÊN – 1 DÒNG
                                      Text(
                                        product.title,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // 3. GIÁ + TRẠNG THÁI (CÙNG HÀNG)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${product.price.toStringAsFixed(0)}₫',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: product.status == 'ACTIVE' ? Colors.teal.shade100 : Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              product.status == 'ACTIVE' ? 'Hoạt động' : 'Ẩn',
                                              style: const TextStyle(fontSize: 9),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // 4. KHO – NHỎ GỌN
                                      if (product.stock != null)
                                        Text(
                                          'Kho: ${product.stock}',
                                          style: TextStyle(fontSize: 11, color: product.stock! > 0 ? Colors.black54 : Colors.red),
                                        ),

                                      // 5. BIẾN THỂ – CHỈ 1 DÒNG, 2 CHIP
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
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              );
                                            }).toList(),
                                          ),
                                        ),

                                      const Spacer(),

                                      // 6. 2 NÚT NHỎ – KHÔNG TRÀN
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 32,
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Đã thêm vào giỏ'), backgroundColor: Colors.green),
                                                  );
                                                },
                                                icon: const Icon(Icons.add_shopping_cart, size: 14),
                                                label: const Text('Giỏ', style: TextStyle(fontSize: 11)),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  side: const BorderSide(color: Colors.blue),
                                                  foregroundColor: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: SizedBox(
                                              height: 32,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Đã mua'), backgroundColor: Colors.orange),
                                                  );
                                                },
                                                icon: const Icon(Icons.flash_on, size: 14),
                                                label: const Text('Mua', style: TextStyle(fontSize: 11)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange,
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                ),
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

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Chuyển đến tab $index')),
            );
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

// WIDGET DANH MỤC NGANG
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
          style: const TextStyle(
            color: Color(0xFF1C1C1C),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}