import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../oders_payments/checkout_screen.dart';

// Định nghĩa một số màu sắc chuẩn cho giao diện
class AppColors {
  static const Color background = Color(0xFFF5F7FA); // Xám xanh nhẹ nền
  static const Color primaryBlue = Color(0xFF0D6EFD);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8F9BB3);
  static const Color borderGrey = Color(0xFFE4E9F2);
  static const Color priceColor = Color(0xFFDB3022); // Màu đỏ cam cho giá, hoặc dùng màu đen đậm
}

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

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Tăng kích thước và độ đậm cho tiêu đề AppBar
        title: Consumer<CartProvider>(
          builder: (_, provider, __) => Text(
            'Giỏ hàng (${provider.totalItems})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Bỏ shadow của AppBar để trông phẳng hiện đại hơn
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderGrey, height: 1.0),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.items.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: () => _confirmClearCart(context, provider),
                // Nút xóa tất cả tinh tế hơn
                child: Text('Xóa tất cả',
                    style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w600, fontSize: 13)),
              );
            },
          )
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }
          if (cartProvider.errorMessage != null) {
            return Center(child: Text('Lỗi: ${cartProvider.errorMessage}', style: const TextStyle(color: Colors.grey)));
          }
          if (cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Giỏ hàng trống', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: cartProvider.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return CartItemWidget(
                item: item,
                provider: cartProvider,
                formatCurrency: formatCurrency,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  )
                ],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)
                )
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính', style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(cartProvider.subtotal),
                            style: const TextStyle(
                                fontSize: 20, // Tổng tiền lớn hơn
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                height: 1.0
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0, left: 4.0),
                            child: Text('vnđ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // 1. Lấy dữ liệu giỏ hàng để kiểm tra
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);

                        // 2. Kiểm tra nếu giỏ hàng trống thì báo lỗi, không cho đi tiếp
                        if (cartProvider.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Giỏ hàng của bạn đang trống!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // 3. Nếu có hàng -> Chuyển sang màn hình Checkout
                        // Đảm bảo bạn đã khai báo route '/checkout' trong main.dart
                        Navigator.pushNamed(context, '/checkout');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'TIẾN HÀNH THANH TOÁN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
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

  void _confirmClearCart(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa giỏ hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm khỏi giỏ hàng không?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.clearSelectedItems();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                elevation: 0,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Xóa hết', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET ITEM ĐÃ ĐƯỢC LÀM ĐẸP
// ---------------------------------------------------------
class CartItemWidget extends StatefulWidget {
  final CartItemModel item;
  final CartProvider provider;
  final Function(double) formatCurrency;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.provider,
    required this.formatCurrency,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != oldWidget.item.quantity) {
      _qtyController.text = widget.item.quantity.toString();
      _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length));
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _submitQuantity(String value) {
    final newQty = int.tryParse(value);
    if (newQty != null) {
      if (newQty <= 0) {
        _confirmRemoveItem();
      } else {
        widget.provider.updateQuantity(widget.item.id, newQty);
      }
    } else {
      _qtyController.text = widget.item.quantity.toString();
    }
    // Ẩn bàn phím sau khi submit
    FocusScope.of(context).unfocus();
  }

  void _confirmRemoveItem() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xoá', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn muốn xóa sản phẩm này khỏi giỏ?'),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(ctx);
            _qtyController.text = widget.item.quantity.toString();
          }, child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.provider.removeItem(widget.item.id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String getImageUrl(int? imageId) {
    if (imageId == null) return 'https://via.placeholder.com/150';
    // TODO: Thay thế bằng domain thật của bạn
    return 'https://your-api-domain.com/images/$imageId';
  }

  @override
  Widget build(BuildContext context) {
    // Thêm Container bao ngoài để tạo bóng và bo góc cho từng item
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 4),
              blurRadius: 12,
            )
          ],
          border: Border.all(color: AppColors.borderGrey.withOpacity(0.5), width: 1)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ảnh sản phẩm (Bo góc mềm hơn)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: AppColors.background,
              child: Image.network(
                getImageUrl(widget.item.imageId),
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88, height: 88, color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 2. Thông tin bên phải
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng trên cùng: Tên SP + Nút Xóa (Góc phải)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600, // Semi-bold
                            color: AppColors.textDark,
                            height: 1.3
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nút xóa (Icon Thùng rác) màu nhạt hơn
                    InkWell(
                      onTap: _confirmRemoveItem,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline_rounded, color: Colors.grey[400], size: 22),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                // Variant Name
                if (widget.item.variantName != null)
                  Text(
                    widget.item.variantName!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                  ),

                const SizedBox(height: 16),

                // Hàng dưới cùng: Giá + Bộ chỉnh số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Giá tiền nổi bật
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.formatCurrency(widget.item.price),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700, // Bold
                              color: AppColors.textDark // Hoặc dùng AppColors.priceColor nếu thích màu đỏ
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2.0, left: 2.0),
                          child: Text('đ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                        ),
                      ],
                    ),

                    // --- BỘ CHỈNH SỐ LƯỢNG (CLEAN HƠN) ---
                    Container(
                      height: 34,
                      decoration: BoxDecoration(
                        // Chỉ dùng viền ngoài, bỏ viền ngăn cách bên trong
                          border: Border.all(color: AppColors.borderGrey, width: 1.2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white
                      ),
                      child: Row(
                        children: [
                          // Nút Trừ
                          _buildStepperBtn(
                            icon: Icons.remove_rounded,
                            onTap: () {
                              if (widget.item.quantity > 1) {
                                widget.provider.updateQuantity(widget.item.id, widget.item.quantity - 1);
                              } else {
                                _confirmRemoveItem();
                              }
                            },
                          ),

                          // Ô nhập liệu (TextField) - Không có viền
                          SizedBox(
                            width: 36,
                            child: TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textDark),
                              decoration: const InputDecoration(
                                border: InputBorder.none, // Bỏ viền input
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onSubmitted: _submitQuantity,
                              textInputAction: TextInputAction.done,
                            ),
                          ),

                          // Nút Cộng
                          _buildStepperBtn(
                            icon: Icons.add_rounded,
                            onTap: () => widget.provider.updateQuantity(widget.item.id, widget.item.quantity + 1),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepperBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: AppColors.textDark),
        ),
      ),
    );
  }
}