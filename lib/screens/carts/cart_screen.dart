// lib/screens/carts/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // 1. Đang tải
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Xử lý lỗi (Đặc biệt là lỗi 401 Unauthorized)
          if (cartProvider.errorMessage != null) {
            // Kiểm tra xem lỗi có phải do chưa đăng nhập không
            // Service ném 'Unauthorized' hoặc backend trả về json chứa 'Unauthorized'
            final err = cartProvider.errorMessage!;
            final isAuthError = err.contains('Unauthorized') || err.contains('401');

            if (isAuthError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Bạn chưa đăng nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Vui lòng đăng nhập để xem giỏ hàng', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Chuyển hướng sang trang Login tại đây
                        // Navigator.pushNamed(context, '/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng Login chưa được gắn vào nút này!'))
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Đăng nhập ngay', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            // Các lỗi khác
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(err.replaceAll('Exception: ', ''), textAlign: TextAlign.center),
                  ),
                  ElevatedButton(onPressed: () => cartProvider.fetchCart(), child: const Text('Thử lại')),
                ],
              ),
            );
          }

          final cartData = cartProvider.cartData;

          // 3. Giỏ hàng trống
          if (cartData == null || cartData.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Giỏ hàng trống', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Hãy thêm sản phẩm bạn thích!', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          // 4. Hiển thị danh sách sản phẩm
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartData.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cartData.items[index];
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          // Ảnh
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: item.imageId != null
                                ? const Icon(Icons.image, color: Colors.grey) // Thay bằng Image.network khi có URL
                                : const Icon(Icons.image, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          // Thông tin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (item.variantName != null)
                                  Text(item.variantName!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Text('${item.price} đ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          // Nút tăng giảm
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    cartProvider.updateQuantity(item.id, item.quantity - 1);
                                  } else {
                                    cartProvider.removeItem(item.id);
                                  }
                                },
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0D6EFD)),
                                onPressed: () => cartProvider.updateQuantity(item.id, item.quantity + 1),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Footer tổng tiền
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tổng cộng:', style: TextStyle(color: Colors.grey)),
                        Text('${cartProvider.subtotal} đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD)),
                      child: const Text('Thanh toán', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}