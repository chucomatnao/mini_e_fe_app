import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';

class AppColors {
  static const Color background = Color(0xFFF5F7FA);
  static const Color primaryBlue = Color(0xFF0D6EFD);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8F9BB3);
  static const Color borderGrey = Color(0xFFE4E9F2);
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
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              elevation: 0,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa hết', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Consumer<CartProvider>(
          builder: (_, provider, __) => Text(
            'Giỏ hàng (${provider.totalItems})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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

          return Column(
            children: [
              // ✅ Select all row
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: cartProvider.isAllSelected,
                      onChanged: (v) => cartProvider.toggleSelectAll(v ?? false),
                    ),
                    const Text('Chọn tất cả', style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('Đã chọn: ${cartProvider.selectedCount}',
                        style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return CartItemWidget(
                      item: item,
                      provider: cartProvider,
                      formatCurrency: formatCurrency,
                    );
                  },
                ),
              ),
            ],
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
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền (đã chọn)',
                          style: TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatCurrency(cartProvider.selectedSubtotal),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              height: 1.0,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0, left: 4.0),
                            child: Text('vnđ',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: cartProvider.selectedCount == 0
                          ? null
                          : () {
                              // bạn sẽ làm thanh toán sau
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã chọn ${cartProvider.selectedCount} sản phẩm để thanh toán (làm sau).')),
                              );

                              // nếu muốn chuyển:
                              // Navigator.pushNamed(context, '/checkout', arguments: cartProvider.selectedCartItemIds);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        disabledBackgroundColor: Colors.grey.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'TIẾP TỤC',
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
}

// ---------------------------------------------------------
// ITEM WIDGET
// ---------------------------------------------------------
class CartItemWidget extends StatefulWidget {
  final CartItemModel item;
  final CartProvider provider;
  final String Function(double) formatCurrency;

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

    // ✅ FIX: không so sánh oldWidget.item.quantity nữa (vì cùng reference khi optimistic update)
    final newText = widget.item.quantity.toString();
    if (_qtyController.text != newText) {
      _qtyController.text = newText;
      _qtyController.selection = TextSelection.fromPosition(TextPosition(offset: _qtyController.text.length));
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  String get _imageUrl {
    final url = widget.item.imageUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    return 'https://placehold.co/150x150.png?text=No+Image';
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
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _qtyController.text = widget.item.quantity.toString();
            },
            child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ checkbox chọn item
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Checkbox(
              value: widget.item.isSelected,
              onChanged: (_) => widget.provider.toggleSelection(widget.item.id),
            ),
          ),

          // image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _imageUrl,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.background),
              errorWidget: (_, __, ___) => Container(
                width: 88,
                height: 88,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

                if (widget.item.variantName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.item.variantName!,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                  ),
                ],

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // price
                    Text(
                      '${widget.formatCurrency(widget.item.price)} đ',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),

                    // stepper
                    Container(
                      height: 34,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGrey, width: 1.2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
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
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onSubmitted: _submitQuantity,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          _buildStepperBtn(
                            icon: Icons.add_rounded,
                            onTap: () => widget.provider.updateQuantity(widget.item.id, widget.item.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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
