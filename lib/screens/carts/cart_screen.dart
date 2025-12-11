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
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${cartProvider.error}', textAlign: TextAlign.center),
                  ElevatedButton(onPressed: () => cartProvider.fetchCart(), child: const Text('Thử lại')),
                ],
              ),
            );
          }

          final cart = cartProvider.cart;

          if (cart == null || cart.items.isEmpty) {
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

          // Tách danh sách: sản phẩm hợp lệ và không hợp lệ
          final validItems = cart.items.where((item) => item.isAvailable).toList();
          final invalidItems = cart.items.where((item) => !item.isAvailable).toList();

          return Column(
            children: [
              // Danh sách sản phẩm
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final isInvalid = !item.isAvailable;

                    return Opacity(
                      opacity: isInvalid ? 0.5 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isInvalid ? Colors.red.shade200 : Colors.transparent),
                          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // NÚT XÓA Ở ĐẦU DÒNG
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => cartProvider.removeItem(item.id),
                            ),

                            // Ảnh
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                  ? Image.network(item.imageUrl!, width: 90, height: 90, fit: BoxFit.cover)
                                  : Container(width: 90, height: 90, color: Colors.grey[300], child: const Icon(Icons.image)),
                            ),
                            const SizedBox(width: 12),

                            // Thông tin
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productTitle,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  if (item.variantLabel != null && item.variantLabel!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                      child: Text('Phân loại: ${item.variantLabel}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                    ),
                                  const SizedBox(height: 8),

                                  // THÔNG BÁO HẾT HÀNG / KHÔNG TỒN TẠI
                                  if (isInvalid)
                                    const Text(
                                      'Sản phẩm đã hết hoặc không tồn tại',
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${item.unitPrice.toInt()}₫', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),

                                      // NÚT SỐ LƯỢNG (chỉ bật khi sản phẩm hợp lệ)
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: isInvalid ? Colors.grey.shade300 : Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              iconSize: 20,
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.remove, color: isInvalid ? Colors.grey : Colors.grey[600]),
                                              onPressed: isInvalid
                                                  ? null
                                                  : () {
                                                if (item.quantity > 1) {
                                                  cartProvider.updateItemQuantity(item.id, item.quantity - 1);
                                                } else {
                                                  cartProvider.removeItem(item.id);
                                                }
                                              },
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: TextField(
                                                enabled: !isInvalid,
                                                controller: TextEditingController(text: item.quantity.toString())
                                                  ..selection = TextSelection.fromPosition(
                                                    TextPosition(offset: item.quantity.toString().length),
                                                  ),
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                                onSubmitted: (value) {
                                                  final qty = int.tryParse(value) ?? 1;
                                                  if (qty > 0) {
                                                    cartProvider.updateItemQuantity(item.id, qty);
                                                  } else {
                                                    cartProvider.removeItem(item.id);
                                                  }
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              iconSize: 20,
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.add, color: isInvalid ? Colors.grey : const Color(0xFF0D6EFD)),
                                              onPressed: isInvalid ? null : () => cartProvider.updateItemQuantity(item.id, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // NÚT XÓA TẤT CẢ SẢN PHẨM KHÔNG HỢP LỆ
              if (invalidItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      for (final item in invalidItems) {
                        cartProvider.removeItem(item.id);
                      }
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: Text('Xóa ${invalidItems.length} sản phẩm không hợp lệ'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                  ),
                ),

              // Thanh tổng tiền (chỉ tính sản phẩm hợp lệ)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng', style: TextStyle(fontSize: 16)),
                        Text(
                          '${validItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice).toInt()}₫',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: validItems.isEmpty
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng thanh toán đang phát triển!'), backgroundColor: Colors.orange),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: validItems.isEmpty ? Colors.grey : Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          validItems.isEmpty ? 'Không có sản phẩm hợp lệ' : 'Thanh toán (${validItems.length} sản phẩm)',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}