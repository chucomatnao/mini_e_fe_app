import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MODELS ---
import '../../models/product_model.dart';

// --- PROVIDERS ---
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/cart_provider.dart';

// --- SCREENS ---
import 'edit_product_screen.dart';

// ==========================================
// WIDGET CHÍNH: MÀN HÌNH CHI TIẾT SẢN PHẨM (MODERN UI)
// ==========================================
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool isFromShopManagement;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isFromShopManagement = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- 1. KHAI BÁO BIẾN TRẠNG THÁI (GIỮ NGUYÊN) ---
  bool _isLoadingVariants = false;
  List<VariantItem> _variants = [];
  bool _isUpdatingStatus = false;
  late ProductModel _currentProduct;
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;

  // --- MÀU SẮC GIAO DIỆN MỚI (MODERN THEME) ---
  final Color _primaryColor = const Color(0xFF111827); // Màu đen than (Elegant)
  final Color _accentColor = const Color(0xFF3B82F6);  // Màu xanh điểm nhấn
  final Color _bgColor = const Color(0xFFF9FAFB);      // Màu nền trắng xám hiện đại
  final Color _textTitleColor = const Color(0xFF111827);
  final Color _textBodyColor = const Color(0xFF6B7280);

  // --- 2. KHỞI TẠO (GIỮ NGUYÊN) ---
  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _fetchVariants();
  }

  // --- 3. LOGIC (GIỮ NGUYÊN) ---
  Future<void> _fetchVariants() async {
    setState(() => _isLoadingVariants = true);
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final result = await productProvider.getVariants(widget.product.id);
      if (mounted) {
        setState(() {
          _variants = result;
          _isLoadingVariants = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingVariants = false);
    }
  }

  int get totalStock {
    if (_variants.isEmpty) return _currentProduct.stock ?? 0;
    return _variants.fold<int>(0, (sum, v) => sum + v.stock);
  }

  String _formatPrice(dynamic price) {
    double value = 0.0;
    if (price is String) value = double.tryParse(price) ?? 0.0;
    else if (price is num) value = price.toDouble();
    return value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  bool _canManageProduct() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    if (authProvider.user == null || shopProvider.shop == null) return false;
    final userRole = authProvider.user!.role?.toUpperCase();
    final isSeller = userRole == 'SELLER';
    final isOwnerOfThisShop = shopProvider.shop!.id == widget.product.shopId;
    return isSeller && isOwnerOfThisShop && widget.isFromShopManagement;
  }

  Future<void> _toggleProductStatus() async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.toggleProductStatus(_currentProduct.id);
    if (mounted) {
      setState(() => _isUpdatingStatus = false);
      if (success) {
        final updated = provider.products.firstWhere(
              (p) => p.id == _currentProduct.id,
          orElse: () => _currentProduct,
        );
        setState(() => _currentProduct = updated);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(updated.status == 'ACTIVE' ? 'Đã bật bán' : 'Đã ẩn sản phẩm'),
          backgroundColor: Colors.green,
        ));
      }
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(_currentProduct.id);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: Colors.green));
      }
    }
  }

  // ==========================================
  // BOTTOM SHEET (UI ĐƯỢC CHỈNH SỬA CHO ĐẸP HƠN)
  // ==========================================
  void _showBottomSheetCart({bool isBuyNow = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép full màn hình
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildCartBottomSheet(isBuyNow),
    );
  }

  Widget _buildCartBottomSheet(bool isBuyNow) {
    int quantity = 1;
    Map<String, String> selectedOptions = {};

    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Bắt đầu ở 70% màn hình để tránh bị chật
      minChildSize: 0.5,     // Tối thiểu 50%
      maxChildSize: 0.95,    // Tối đa 95%
      builder: (_, scrollController) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            // ... (Logic tìm variant giữ nguyên như cũ) ...
            VariantItem? foundVariant;
            bool isFullSelection = false;

            if (_currentProduct.optionSchema != null && _currentProduct.optionSchema!.isNotEmpty) {
              isFullSelection = _currentProduct.optionSchema!.every(
                      (opt) => selectedOptions.containsKey(opt.name)
              );
            } else {
              isFullSelection = true;
            }

            if (isFullSelection && _variants.isNotEmpty) {
              final expectedName = _currentProduct.optionSchema?.map((opt) {
                return selectedOptions[opt.name];
              }).join(' - ');
              try {
                foundVariant = _variants.firstWhere(
                      (v) => v.name == expectedName,
                  orElse: () => _variants[0],
                );
              } catch (_) {}
            }

            int maxStock = foundVariant?.stock ?? (_variants.isEmpty ? (_currentProduct.stock ?? 0) : totalStock);
            String displayPrice = foundVariant != null && foundVariant.price > 0
                ? _formatPrice(foundVariant.price)
                : _formatPrice(_currentProduct.price);
            String? variantNameDisplay = foundVariant?.name;
            // ... (Hết phần logic cũ) ...

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Quan trọng: Co lại theo nội dung
                children: [
                  // 1. Handle Bar (Thanh gạch ngang)
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 15, top: 5),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),

                  // 2. Header Sheet (Ảnh + Giá + Kho) - FIX TRÀN NGANG
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh sản phẩm (Fix lỗi crash nếu ảnh lỗi)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _currentProduct.imageUrl,
                          width: 100, height: 100, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100, height: 100, color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thông tin bên phải (Dùng Expanded để tránh tràn lề phải)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Giá tiền
                            Text(
                              '₫$displayPrice',
                              style: TextStyle(fontSize: 22, color: _primaryColor, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            // Kho
                            Text('Kho: $maxStock', style: TextStyle(color: _textBodyColor, fontSize: 13)),
                            const SizedBox(height: 8),
                            // Phân loại đã chọn
                            if (variantNameDisplay != null && isFullSelection)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  'Đã chọn: $variantNameDisplay',
                                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                  overflow: TextOverflow.ellipsis, // Fix tràn
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),

                  // 3. Body Sheet (Cuộn được) - FIX TRÀN DỌC
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero, // Bỏ padding thừa
                      children: [
                        if (_currentProduct.optionSchema != null)
                          ..._currentProduct.optionSchema!.map((optionGroup) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(optionGroup.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textTitleColor)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12, runSpacing: 12,
                                  children: optionGroup.values.map((value) {
                                    final isSelected = selectedOptions[optionGroup.name] == value;
                                    return GestureDetector(
                                      onTap: () {
                                        setStateSheet(() {
                                          if (isSelected) {
                                            selectedOptions.remove(optionGroup.name);
                                          } else {
                                            selectedOptions[optionGroup.name] = value;
                                          }
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? _primaryColor : Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black87,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),

                        const SizedBox(height: 20),
                        // Số lượng (Dùng MainAxisAlignment.spaceBetween để tránh lỗi RenderFlex)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Số lượng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textTitleColor)),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: quantity > 1 ? () => setStateSheet(() => quantity--) : null,
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: (isFullSelection && quantity < maxStock) || (!isFullSelection && quantity < totalStock)
                                        ? () => setStateSheet(() => quantity++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40), // Khoảng trống dưới cùng để cuộn không bị che
                      ],
                    ),
                  ),

                  // 4. Button Confirm (Luôn ghim ở đáy)
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          // 1. Kiểm tra logic giao diện (giữ nguyên)
                          if (_variants.isNotEmpty && !isFullSelection) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn đầy đủ phân loại')));
                            return;
                          }
                          if (maxStock <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sản phẩm đã hết hàng')));
                            return;
                          }

                          final cartProvider = Provider.of<CartProvider>(context, listen: false);

                          // 2. SỬA: Gọi hàm addToCart và dùng try-catch
                          // Vì Provider của bạn 'rethrow' lỗi, nên phải bắt lỗi ở đây để UI không bị crash
                          try {
                            await cartProvider.addToCart(
                                _currentProduct.id, // productId
                                variantId: foundVariant?.id, // variantId (có thể null)
                                quantity: quantity // quantity
                            );

                            if (!mounted) return;

                            // Thành công
                            Navigator.pop(context); // Đóng bottom sheet

                            if (isBuyNow) {
                              Navigator.pushNamed(context, '/cart');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green)
                              );
                            }
                          } catch (e) {
                            // Thất bại: Hiển thị lỗi từ catch hoặc từ errorMessage trong provider
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(e.toString().replaceAll('Exception:', '').trim()), // Làm sạch thông báo lỗi
                                    backgroundColor: Colors.red
                                )
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (isFullSelection && maxStock > 0) || _variants.isEmpty ? _primaryColor : Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                            maxStock <= 0 ? 'HẾT HÀNG' : (isBuyNow ? 'Mua ngay' : 'Thêm vào giỏ'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MAIN UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final canManage = _canManageProduct();

    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true, // Cho ảnh tràn lên AppBar

      // APP BAR TRONG SUỐT CHO HIỆN ĐẠI
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.black, size: 20)),
          ),
          Consumer<CartProvider>(
            builder: (_, cartProvider, __) => Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                  child: IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black)
                  ),
                ),
                // SỬA: Dùng getter 'totalItems' từ Provider của bạn
                if (cartProvider.totalItems > 0)
                  Positioned(
                    right: 14, top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      // SỬA: Hiển thị totalItems
                      child: Text(
                          '${cartProvider.totalItems}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. HÌNH ẢNH SẢN PHẨM (FULL WIDTH - VUÔNG)
                  SizedBox(
                    height: MediaQuery.of(context).size.width, // Tỷ lệ 1:1
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: 1,
                          onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                          itemBuilder: (ctx, index) {
                            return Image.network(
                              _currentProduct.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_,__,___) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                              ),
                            );
                          },
                        ),
                        // Dot Indicator thay vì số
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(1, (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentImageIndex == index ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )),
                          ),
                        )
                      ],
                    ),
                  ),

                  // B. NỘI DUNG CHÍNH (THIẾT KẾ CARD BO TRÒN LÊN TRÊN ẢNH)
                  Container(
                    transform: Matrix4.translationValues(0, -20, 0), // Đẩy lên đè nhẹ lên ảnh
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // 1. Tên & Giá
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _currentProduct.title,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textTitleColor, height: 1.3),
                                    ),
                                  ),
                                  // Nút Favorite nhỏ
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.favorite_border, color: Colors.grey),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '₫${_formatPrice(_currentProduct.price)}',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _primaryColor),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.star, color: Colors.amber, size: 16),
                                        SizedBox(width: 4),
                                        Text('5.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(' (1.2k bán)', style: TextStyle(color: Colors.grey, fontSize: 12))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 2. Chọn Phân Loại (Style kiểu danh sách thay vì hiện hết ra)
                        if (_currentProduct.optionSchema != null && _currentProduct.optionSchema!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () => _showBottomSheetCart(isBuyNow: false),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.tune, size: 20, color: _textTitleColor),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Chọn phân loại', style: TextStyle(fontWeight: FontWeight.bold, color: _textTitleColor)),
                                          const SizedBox(height: 4),
                                          Text(
                                              _currentProduct.optionSchema!.map((e) => e.name).join(', '),
                                              style: TextStyle(fontSize: 12, color: _textBodyColor)
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 14, color: _textBodyColor),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // 3. Thông tin Shop (Style Modern Card)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(25),
                                    image: const DecorationImage(image: NetworkImage('https://via.placeholder.com/150'), fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Shop Chính Hãng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textTitleColor)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                          const SizedBox(width: 6),
                                          Text('Đang hoạt động', style: TextStyle(color: _textBodyColor, fontSize: 12)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: (){},
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: _primaryColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Text('Xem Shop', style: TextStyle(color: _primaryColor, fontSize: 12)),
                                )
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 4. Mô tả sản phẩm
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mô tả sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textTitleColor)),
                              const SizedBox(height: 12),
                              Text(
                                _currentProduct.description ?? 'Đang cập nhật...',
                                style: TextStyle(fontSize: 15, height: 1.6, color: _textBodyColor),
                                maxLines: _isDescriptionExpanded ? null : 4,
                                overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              ),
                              if ((_currentProduct.description?.length ?? 0) > 100)
                                GestureDetector(
                                  onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                                      style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),

                        // 5. Khu vực Quản lý (Chỉ chủ shop)
                        if (canManage) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('Công cụ quản lý', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textTitleColor)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: widget.product))),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Sửa'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleProductStatus,
                                    icon: Icon(_currentProduct.status == 'ACTIVE' ? Icons.visibility_off : Icons.visibility, size: 16),
                                    label: Text(_currentProduct.status == 'ACTIVE' ? 'Ẩn' : 'Hiện'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmDelete(context),
                                    icon: const Icon(Icons.delete, size: 16),
                                    label: const Text('Xóa'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],

                        const SizedBox(height: 100), // Padding dưới cùng
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTTOM NAVIGATION ACTION (Floating Style)
      bottomNavigationBar: canManage ? null : Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Nút Chat (Minimal)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  color: _textTitleColor,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),

              // Nút Thêm Giỏ (Secondary)
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => _showBottomSheetCart(isBuyNow: false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Thêm giỏ hàng', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nút Mua Ngay (Primary)
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _showBottomSheetCart(isBuyNow: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Mua ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}