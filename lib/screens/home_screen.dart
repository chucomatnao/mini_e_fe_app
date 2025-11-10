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
    final productProvider = Provider.of<ProductProvider>(context);

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
                          color: Color(0x960004FF),
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

                // DANH SÁCH SẢN PHẨM
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

                      // TRẠNG THÁI LOADING / RỖNG / LỖI
                      if (productProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (productProvider.error != null)
                        Center(
                          child: Column(
                            children: [
                              Text(
                                productProvider.error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => productProvider.fetchProducts(),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      else if (productProvider.products.isEmpty)
                          const Center(child: Text('Không có sản phẩm nào.'))
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = productProvider.products[index];

                              return GestureDetector(
                                onTap: () {
                                  // Điều hướng chi tiết sản phẩm (nếu có)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Chi tiết: ${product.title}')),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F000000),
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ẢNH SẢN PHẨM
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: product.imageUrl.isNotEmpty
                                            ? Image.network(
                                          product.imageUrl,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image, size: 40),
                                          ),
                                        )
                                            : Container(
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 40),
                                        ),
                                      ),

                                      // TIÊU ĐỀ
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product.title, // SỬA: product.title thay vì product.name
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      // GIÁ
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '${product.price.toStringAsFixed(0)} VND', // Đổi $ → VND
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      // STOCK (nếu có)
                                      if (product.stock != null)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                                          child: Text(
                                            'Còn: ${product.stock}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: product.stock! > 0 ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
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