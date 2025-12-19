import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT MODELS ---
import '../../models/product_model.dart'; // Model chứa dữ liệu sản phẩm

// --- IMPORT PROVIDERS ---
import '../../providers/product_provider.dart'; // Gọi API lấy biến thể
import '../../providers/auth_provider.dart';    // Kiểm tra đăng nhập/quyền user
import '../../providers/shop_provider.dart';    // Kiểm tra shop sở hữu
import '../../providers/cart_provider.dart';    // Thêm vào giỏ hàng

// --- IMPORT SCREENS ---
import 'edit_product_screen.dart'; // Màn hình sửa sản phẩm (cho Seller)

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool isFromShopManagement; // Cờ để biết có phải chủ shop đang xem không

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isFromShopManagement = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- BIẾN TRẠNG THÁI (STATE) ---

  bool _isLoadingVariants = false; // Trạng thái đang tải API biến thể
  List<VariantItem> _variants = []; // Danh sách biến thể chi tiết (có giá, kho, SKU)
  bool _isUpdatingStatus = false;   // Trạng thái đang bật/tắt sản phẩm
  late ProductModel _currentProduct; // Sản phẩm hiện tại đang xem

  // Trạng thái UI
  int _currentImageIndex = 0;       // Index của ảnh đang xem trên Slider
  bool _isDescriptionExpanded = false; // Trạng thái xem thêm/thu gọn mô tả

  // Màu sắc chủ đạo (Theme)
  final Color _primaryColor = const Color(0xFFEE4D2D); // Màu Cam Đỏ (giống Shopee)
  final Color _bgColor = const Color(0xFFF5F5F5);      // Màu nền xám nhạt

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    // Gọi API lấy danh sách biến thể ngay khi vào màn hình
    _fetchVariants();
  }

  // --- 1. LOGIC GỌI API ---
  Future<void> _fetchVariants() async {
    setState(() => _isLoadingVariants = true);
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      // Gọi hàm getVariants từ Provider để lấy List<VariantItem>
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

  // --- 2. CÁC HÀM TIỆN ÍCH (HELPER) ---

  // Tính tổng tồn kho của tất cả biến thể
  int get totalStock {
    if (_variants.isEmpty) return _currentProduct.stock ?? 0;
    return _variants.fold<int>(0, (sum, v) => sum + v.stock);
  }

  // Format giá tiền (VD: 100000 -> 100.000)
  String _formatPrice(dynamic price) {
    double value = 0.0;
    if (price is String) value = double.tryParse(price) ?? 0.0;
    else if (price is num) value = price.toDouble();

    return value.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  // Kiểm tra xem người dùng hiện tại có phải là chủ shop của sản phẩm này không
  bool _canManageProduct() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (authProvider.user == null || shopProvider.shop == null) return false;
    final userRole = authProvider.user!.role?.toUpperCase();
    final isSeller = userRole == 'SELLER';
    // Shop ID của user phải trùng với Shop ID của sản phẩm
    final isOwnerOfThisShop = shopProvider.shop!.id == widget.product.shopId;

    return isSeller && isOwnerOfThisShop && widget.isFromShopManagement;
  }

  // --- 3. CÁC HÀNH ĐỘNG (ACTIONS) ---

  // Bật/Tắt trạng thái kinh doanh (Active/Draft)
  Future<void> _toggleProductStatus() async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.toggleProductStatus(_currentProduct.id);

    if (mounted) {
      setState(() => _isUpdatingStatus = false);
      if (success) {
        // Cập nhật lại UI local sau khi API thành công
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

  // Xóa sản phẩm
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(_currentProduct.id);
      if (success && mounted) {
        Navigator.pop(context); // Thoát màn hình chi tiết
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa sản phẩm'), backgroundColor: Colors.green));
      }
    }
  }

  // --- 4. BOTTOM SHEET: CHỌN PHÂN LOẠI & MUA HÀNG ---
  // Hàm mở Bottom Sheet
  void _showBottomSheetCart({bool isBuyNow = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép full màn hình nếu nội dung dài
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildCartBottomSheet(isBuyNow),
    );
  }

  // Widget nội dung của Bottom Sheet
  Widget _buildCartBottomSheet(bool isBuyNow) {
    int quantity = 1; // Số lượng mặc định
    // Map lưu các lựa chọn của khách. VD: {'Màu sắc': 'Đỏ', 'Size': 'M'}
    Map<String, String> selectedOptions = {};

    return DraggableScrollableSheet(
      initialChildSize: 0.75, // Chiều cao ban đầu (75% màn hình)
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return StatefulBuilder(
          // Dùng StatefulBuilder để cập nhật UI cục bộ trong BottomSheet
          builder: (context, setStateSheet) {

            // --- LOGIC TÌM BIẾN THỂ (MATCHING) ---
            VariantItem? foundVariant;
            bool isFullSelection = false; // Đã chọn đủ các nhóm chưa?

            // Kiểm tra xem khách đã chọn hết các nhóm option chưa (Màu + Size)
            if (_currentProduct.optionSchema != null && _currentProduct.optionSchema!.isNotEmpty) {
              isFullSelection = _currentProduct.optionSchema!.every(
                      (opt) => selectedOptions.containsKey(opt.name)
              );
            } else {
              isFullSelection = true; // Sản phẩm không có biến thể
            }

            // Nếu đã chọn đủ, tìm biến thể tương ứng trong list _variants
            if (isFullSelection && _variants.isNotEmpty) {
              // Ghép chuỗi tên để tìm. VD: "Đỏ - M"
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

            // --- TÍNH TOÁN HIỂN THỊ ---
            // Nếu tìm thấy biến thể -> Lấy kho của biến thể. Nếu không -> Lấy tổng kho
            int maxStock = foundVariant?.stock ?? (_variants.isEmpty ? (_currentProduct.stock ?? 0) : totalStock);

            // Nếu tìm thấy biến thể -> Lấy giá biến thể. Nếu không -> Giá gốc
            String displayPrice = foundVariant != null && foundVariant.price > 0
                ? _formatPrice(foundVariant.price)
                : _formatPrice(_currentProduct.price);

            String? variantNameDisplay = foundVariant?.name;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header của Sheet: Ảnh nhỏ + Giá + Kho
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(_currentProduct.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₫$displayPrice', style: TextStyle(fontSize: 20, color: _primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Kho: $maxStock', style: const TextStyle(color: Colors.grey)),

                            // Hiển thị tên biến thể đã chọn hoặc cảnh báo
                            if (variantNameDisplay != null && isFullSelection)
                              Text('Đã chọn: $variantNameDisplay', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            if (!isFullSelection && _variants.isNotEmpty)
                              const Text('Vui lòng chọn phân loại', style: TextStyle(fontSize: 12, color: Colors.red)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(height: 30),

                  // Body: Danh sách các nút chọn (Chips)
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Duyệt qua từng nhóm Option (VD: Màu sắc, Size)
                        if (_currentProduct.optionSchema != null)
                          ..._currentProduct.optionSchema!.map((optionGroup) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tên nhóm (VD: Màu sắc)
                                Text(optionGroup.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                // Các giá trị (VD: Đỏ, Xanh)
                                Wrap(
                                  spacing: 10, runSpacing: 10,
                                  children: optionGroup.values.map((value) {
                                    final isSelected = selectedOptions[optionGroup.name] == value;
                                    return ChoiceChip(
                                      label: Text(value),
                                      selected: isSelected,
                                      onSelected: (val) {
                                        setStateSheet(() {
                                          if (val) {
                                            selectedOptions[optionGroup.name] = value;
                                          } else {
                                            selectedOptions.remove(optionGroup.name); // Bỏ chọn
                                          }
                                        });
                                      },
                                      selectedColor: _primaryColor.withOpacity(0.1),
                                      labelStyle: TextStyle(
                                        color: isSelected ? _primaryColor : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: BorderSide(color: isSelected ? _primaryColor : Colors.grey.shade300),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),

                        // Phần chọn số lượng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.w600)),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: quantity > 1 ? () => setStateSheet(() => quantity--) : null,
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    // Không cho tăng nếu quá tồn kho
                                    onPressed: (isFullSelection && quantity < maxStock) || (!isFullSelection && quantity < totalStock)
                                        ? () => setStateSheet(() => quantity++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Footer: Nút Xác nhận
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validate 1: Phải chọn đủ option
                        if (_variants.isNotEmpty && !isFullSelection) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn đầy đủ phân loại')));
                          return;
                        }

                        // Validate 2: Hết hàng
                        if (maxStock <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sản phẩm/Biến thể này đã hết hàng')));
                          return;
                        }

                        // Gọi Provider thêm vào giỏ
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        final success = await cartProvider.addItem(
                            productId: _currentProduct.id,
                            variantId: foundVariant?.id, // ID của biến thể tìm thấy
                            quantity: quantity
                        );

                        if (!mounted) return;
                        if (success) {
                          Navigator.pop(context); // Đóng Sheet
                          if (isBuyNow) {
                            Navigator.pushNamed(context, '/cart');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng'), backgroundColor: Colors.green));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(cartProvider.error ?? 'Lỗi'), backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (isFullSelection && maxStock > 0) || _variants.isEmpty ? _primaryColor : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(
                          maxStock <= 0 ? 'HẾT HÀNG' : (isBuyNow ? 'Mua Ngay' : 'Thêm Vào Giỏ Hàng'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
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

  // --- 5. UI CHÍNH (MAIN BUILD) ---
  @override
  Widget build(BuildContext context) {
    final canManage = _canManageProduct(); // Kiểm tra quyền chủ shop

    return Scaffold(
      backgroundColor: _bgColor,
      // AppBar
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          // Icon Giỏ hàng có Badge số lượng
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(onPressed: () => Navigator.pushNamed(context, '/cart'), icon: const Icon(Icons.shopping_cart_outlined)),
                if ((cart.cart?.itemsCount ?? 0) > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('${cart.cart!.itemsCount}', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                    ),
                  )
              ],
            ),
          )
        ],
      ),

      // Nội dung chính (Scroll được)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. SLIDER ẢNH
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.white,
                  child: PageView.builder(
                    itemCount: 1, // Nếu có nhiều ảnh thì thay đổi số này
                    onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                    itemBuilder: (ctx, index) {
                      return Image.network(
                        _currentProduct.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                // Indicator số trang (1/5)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                  child: Text('${_currentImageIndex + 1}/1', style: const TextStyle(color: Colors.white, fontSize: 12)),
                )
              ],
            ),

            // B. GIÁ & TÊN SẢN PHẨM
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₫${_formatPrice(_currentProduct.price)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryColor)),
                  const SizedBox(height: 8),
                  Text(_currentProduct.title, style: const TextStyle(fontSize: 16, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  // Đánh giá & Đã bán
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const Text(' 5.0 ', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      Text('|  Đã bán 1.2k', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const Spacer(),
                      // Tag trạng thái (Chỉ Seller thấy)
                      if (canManage)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: _currentProduct.status == 'ACTIVE' ? Colors.green.shade50 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                              _currentProduct.status == 'ACTIVE' ? 'Đang bán' : 'Ẩn',
                              style: TextStyle(fontSize: 10, color: _currentProduct.status == 'ACTIVE' ? Colors.green : Colors.grey)
                          ),
                        )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // C. HIỂN THỊ PHÂN LOẠI (YÊU CẦU MỚI CỦA BẠN)
            // Thay vì 1 dòng, ta hiển thị rõ các Options
            if (_currentProduct.optionSchema != null && _currentProduct.optionSchema!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duyệt qua từng nhóm (VD: Màu sắc, Size)
                    ..._currentProduct.optionSchema!.map((optionGroup) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên nhóm (Màu sắc:)
                            SizedBox(
                              width: 80,
                              child: Text(
                                '${optionGroup.name}:',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                            // Danh sách giá trị (Đỏ, Xanh...)
                            Expanded(
                              child: Wrap(
                                spacing: 8, runSpacing: 8,
                                children: optionGroup.values.map((val) {
                                  // Nút hiển thị giá trị (Không chọn được ở đây, chỉ hiển thị)
                                  // Bấm vào sẽ mở BottomSheet để chọn thực tế
                                  return GestureDetector(
                                    onTap: () => _showBottomSheetCart(isBuyNow: false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Text(val, style: const TextStyle(fontSize: 13)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            // D. CÔNG CỤ QUẢN LÝ (CHỈ CHỦ SHOP THẤY)
            if (canManage) ...[
              const SizedBox(height: 10),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quản lý Shop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: widget.product))),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Sửa SP'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleProductStatus,
                            icon: Icon(_currentProduct.status == 'ACTIVE' ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                            label: Text(_currentProduct.status == 'ACTIVE' ? 'Ẩn SP' : 'Hiện SP'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmDelete(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, elevation: 0),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Xóa Sản Phẩm Này', style: TextStyle(color: Colors.red)),
                      ),
                    )
                  ],
                ),
              )
            ],

            const SizedBox(height: 10),

            // E. THÔNG TIN SHOP
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Shop Chính Hãng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Online 5 phút trước', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: (){},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primaryColor),
                      foregroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Xem Shop'),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // F. MÔ TẢ SẢN PHẨM
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mô tả sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    _currentProduct.description ?? 'Chưa có mô tả',
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if ((_currentProduct.description?.length ?? 0) > 100)
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                        child: Text(_isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm', style: TextStyle(color: _primaryColor)),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding cho BottomBar không che nội dung
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR (CHAT - CART - BUY) ---
      bottomNavigationBar: canManage
          ? null // Nếu là chủ shop thì không hiện nút mua
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Nút Chat
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [Icon(Icons.chat_bubble_outline, color: Colors.grey), Text('Chat', style: TextStyle(fontSize: 10, color: Colors.grey))],
              ),
              const SizedBox(width: 16),
              // Nút Thêm Giỏ (Mở BottomSheet)
              GestureDetector(
                onTap: () => _showBottomSheetCart(isBuyNow: false),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [Icon(Icons.add_shopping_cart, color: Colors.grey), Text('Thêm giỏ', style: TextStyle(fontSize: 10, color: Colors.grey))],
                ),
              ),
              const SizedBox(width: 16),
              // Nút Mua Ngay
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showBottomSheetCart(isBuyNow: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('MUA NGAY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}