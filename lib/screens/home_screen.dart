import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.85;

    final userName = authProvider.user?.name;
    final displayInitial = (userName != null && userName.isNotEmpty)
        ? userName[0].toUpperCase()
        : 'U';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                // HEADER
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.12,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: screenWidth * 0.05,
                        child: const Text(
                          'Mini E',
                          style: TextStyle(
                            color: Color(0x960004FF),
                            fontSize: 26,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        left: screenWidth * 0.2,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tính năng tìm kiếm sắp được thêm!'),
                              ),
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.55,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: const Color(0x7FFFF7F7),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFF0D6EFD),
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                              child: Text(
                                'Search',
                                style: TextStyle(
                                  color: Color(0xFF8A96A4),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: screenWidth * 0.15,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Điều hướng đến giỏ hàng!'),
                              ),
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
                      ),
                      Positioned(
                        right: screenWidth * 0.05,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF0872FF),
                              shape: OvalBorder(),
                            ),
                            child: Center(
                              child: Text(
                                displayInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // MAIN CONTENT
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: screenWidth * 0.5,
                          height: screenHeight * 0.7,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF7050EF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(100),
                                bottomRight: Radius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: cardWidth,
                          padding: const EdgeInsets.all(20),
                          decoration: ShapeDecoration(
                            color: const Color(0x4CD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Colors.white),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Danh sách sản phẩm',
                                style: TextStyle(
                                  color: Color(0xFF181821),
                                  fontSize: 24,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              productProvider.isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : productProvider.products.isEmpty
                                  ? const Center(child: Text('Không có sản phẩm nào.'))
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: productProvider.products.length,
                                itemBuilder: (context, index) {
                                  final product = productProvider.products[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x1F000000),
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: product.imageUrl.isNotEmpty
                                              ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              product.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                            ),
                                          )
                                              : const Icon(Icons.image, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '\$${product.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Inter',
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Xem chi tiết: ${product.name}')),
                                            );
                                          },
                                          child: const Icon(Icons.arrow_forward_ios, size: 16),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
