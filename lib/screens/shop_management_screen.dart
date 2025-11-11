import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart'; // Để lấy products của shop
import 'shop_register_screen.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart'; // Để navigate đến detail (edit mode nếu cần)

class ShopManagementScreen extends StatefulWidget {
  const ShopManagementScreen({Key? key}) : super(key: key);

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Gọi load shop ngay khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.accessToken != null) {
        context.read<ShopProvider>().loadMyShop();
        // THÊM: Fetch products sau khi load shop (để filter sau)
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Shop'),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: shopProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopProvider.error != null
          ? _buildError(context, shopProvider.error!)
          : shopProvider.shop == null
          ? _buildNoShop(context)
          : _buildShopInfo(context, shopProvider),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // XỬ LÝ LỖI
  // ──────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Lỗi: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // CHƯA CÓ SHOP → HIỆN MÀN HÌNH ĐĂNG KÝ
  // ──────────────────────────────────────────────────────────────
  Widget _buildNoShop(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Bạn chưa có shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopRegisterScreen()));
            },
            icon: const Icon(Icons.add_business),
            label: const Text('Đăng ký Shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D6EFD),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // ĐÃ CÓ SHOP → HIỆN THÔNG TIN + 3 NÚT CÙNG HÀNG + DANH SÁCH SẢN PHẨM
  // ──────────────────────────────────────────────────────────────
  Widget _buildShopInfo(BuildContext context, ShopProvider shopProvider) {
    final shop = shopProvider.shop!;

    return SingleChildScrollView( // Để scroll khi có nhiều products
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD: AVATAR + TÊN + TRẠNG THÁI
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar (hiện ảnh nếu có, nếu không hiện icon shop)
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: shop.logoUrl != null
                        ? NetworkImage(shop.logoUrl!) as ImageProvider
                        : null,
                    child: shop.logoUrl == null
                        ? const Icon(Icons.store, size: 40, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Tên shop + trạng thái
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shop.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            shop.status == 'ACTIVE'
                                ? 'Hoạt động'
                                : shop.status == 'PENDING'
                                ? 'Chờ duyệt'
                                : 'Bị khóa',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          backgroundColor: shop.status == 'ACTIVE'
                              ? Colors.green
                              : shop.status == 'PENDING'
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // SỬA: 3 NÚT LỚN CÙNG HÀNG (THÊM SẢN PHẨM + CHỈNH SỬA + XÓA)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Thêm sản phẩm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, shopProvider),
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa thông tin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(context, shopProvider),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Xóa Shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // DANH SÁCH SẢN PHẨM CỦA SHOP (FILTER TỪ PRODUCT PROVIDER)
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              // Filter products của shop này (client-side, không sửa backend)
              final shopProducts = productProvider.products
                  .where((product) => product.shopId == shop.id)
                  .toList();

              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (shopProducts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Chưa có sản phẩm nào trong shop này.'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddProductScreen()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm sản phẩm đầu tiên'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sản phẩm của shop',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('Tổng: ${shopProducts.length}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Trong phần GridView.builder của ShopManagementScreen
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: shopProducts.length,
                        itemBuilder: (context, index) {
                          final product = shopProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(product: product, isEditMode: true),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ảnh
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: product.imageUrl.isNotEmpty
                                          ? Image.network(
                                        product.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image, size: 32),
                                        ),
                                      )
                                          : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 32)),
                                    ),
                                  ),

                                  // Thông tin
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Tên sản phẩm
                                          Text(
                                            product.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 4),

                                          // Giá
                                          Text(
                                            '${product.price.toStringAsFixed(0)}₫',
                                            style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                          ),

                                          // Kho
                                          if (product.stock != null)
                                            Text(
                                              'Kho: ${product.stock}',
                                              style: TextStyle(fontSize: 11, color: product.stock! > 0 ? Colors.green : Colors.red),
                                            ),

                                          const SizedBox(height: 6),

                                          // BIẾN THỂ (nếu có)
                                          if (product.variants != null && product.variants!.isNotEmpty)
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 2,
                                              children: product.variants!.take(2).map((variant) {
                                                final optionText = variant.options.take(2).join(', ');
                                                return Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${variant.name}: $optionText',
                                                    style: const TextStyle(fontSize: 9, color: Colors.black87),
                                                  ),
                                                );
                                              }).toList(),
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // DIALOG CHỈNH SỬA SHOP (GIỮ NGUYÊN)
  // ──────────────────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, ShopProvider shopProvider) async {
    final shop = shopProvider.shop!;
    final nameCtrl = TextEditingController(text: shop.name);
    final emailCtrl = TextEditingController(text: shop.email ?? '');
    final descCtrl = TextEditingController(text: shop.description ?? '');

    // Biến lưu ảnh được chọn (đặt trong StatefulBuilder để cập nhật UI)
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          File? _selectedImage; // Biến lưu ảnh tạm trong dialog

          // Hàm chọn ảnh từ thư viện
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            if (pickedFile != null) {
              setStateDialog(() {
                _selectedImage = File(pickedFile.path); // Cập nhật ảnh
              });
            }
          }

          return AlertDialog(
            title: const Text('Chỉnh sửa Shop'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AVATAR CÓ THỂ BẤM ĐỂ CHỌN ẢNH
                  GestureDetector(
                    onTap: pickImage, // Bấm vào ảnh → mở thư viện
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) // Ưu tiên ảnh mới chọn
                          : shop.logoUrl != null
                          ? NetworkImage(shop.logoUrl!) // Ảnh cũ từ server
                          : null,
                      child: _selectedImage == null && shop.logoUrl == null
                          ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bấm vào ảnh để chọn',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // CÁC FIELD CHỈNH SỬA (GIỮ NGUYÊN NHƯ CŨ)
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên Shop', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: shopProvider.isLoading
                    ? null
                    : () async {
                  // So sánh để chỉ gửi dữ liệu thay đổi
                  final data = <String, dynamic>{};
                  if (nameCtrl.text.trim() != shop.name) data['name'] = nameCtrl.text.trim();
                  if (emailCtrl.text.trim() != (shop.email ?? '')) data['email'] = emailCtrl.text.trim();
                  if (descCtrl.text.trim() != (shop.description ?? '')) data['description'] = descCtrl.text.trim();

                  // XỬ LÝ ẢNH (chưa upload thật – chỉ hiện thông báo)
                  if (_selectedImage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng upload ảnh đang phát triển...')),
                    );
                  }

                  // Gửi dữ liệu nếu có thay đổi
                  if (data.isNotEmpty) {
                    await shopProvider.update(shop.id, data);
                  }
                  Navigator.pop(ctx);
                  _showResult(context, shopProvider);
                },
                child: shopProvider.isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // XÁC NHẬN XÓA SHOP (GIỮ NGUYÊN)
  // ──────────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, ShopProvider shopProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa Shop'),
        content: const Text('Bạn có chắc chắn muốn xóa shop này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ??
        false;

    if (confirm) {
      await shopProvider.delete(shopProvider.shop!.id);
      _showResult(context, shopProvider);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // HIỆN THÔNG BÁO KẾT QUẢ (GIỮ NGUYÊN)
  // ──────────────────────────────────────────────────────────────
  void _showResult(BuildContext context, ShopProvider shopProvider) {
    final message = shopProvider.error ?? 'Thành công!';
    final isError = shopProvider.error != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );

    if (!isError && shopProvider.shop == null) {
      Navigator.pop(context); // Quay lại nếu xóa shop
    }
  }
}