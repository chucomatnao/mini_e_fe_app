import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Providers
import '/../models/product_model.dart';
import '/../providers/product_provider.dart';
import 'add_variant_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeyInfo = GlobalKey<FormState>();

  // --- Controllers cho Tab 1: Info ---
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  // --- State cho Tab 2: Variants ---
  bool _isLoadingVariants = false;
  List<VariantItem> _variants = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Init data từ product được truyền vào
    _titleController = TextEditingController(text: widget.product.title);
    _descController = TextEditingController(text: widget.product.description ?? '');
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(0));

    // Load danh sách biến thể ngay khi vào màn hình
    _fetchVariants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Gọi API lấy danh sách biến thể mới nhất
  Future<void> _fetchVariants() async {
    setState(() => _isLoadingVariants = true);
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final results = await provider.getVariants(widget.product.id);
      setState(() {
        _variants = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải biến thể: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingVariants = false);
      }
    }
  }

  // --- HÀM LƯU TAB 1: INFO (ĐÃ SỬA LỖI TẠI ĐÂY) ---
  Future<void> _saveProductInfo() async {
    if (!_formKeyInfo.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);

    // SỬA: Gọi hàm updateProduct với Named Parameters (productId:, title:, ...)
    final success = await provider.updateProduct(
      productId: widget.product.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      // Các trường khác như slug, status có thể thêm vào đây nếu cần
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: ${provider.error}')),
        );
      }
    }
  }

  // --- HÀM LƯU TAB 2: UPDATE 1 BIẾN THỂ ---
  Future<void> _updateSingleVariant(VariantItem item, double newPrice, int newStock, String newSku) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    final Map<String, dynamic> data = {
      'price': newPrice,
      'stock': newStock,
      'sku': newSku,
    };

    final success = await provider.updateVariant(widget.product.id, item.id, data);
    if (success) {
      if (mounted) {
        Navigator.pop(context); // Đóng Dialog
        _fetchVariants(); // Reload lại list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật biến thể'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi cập nhật biến thể'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UI CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin chung'),
            Tab(text: 'Biến thể & Kho'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildVariantsTab(),
        ],
      ),
    );
  }

  // --- TAB 1 UI ---
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeyInfo,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá bán mặc định (VNĐ)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Mô tả chi tiết', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProductInfo,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Lưu Thay Đổi', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadVariants() async {
    setState(() => _isLoadingVariants = true);
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      // Gọi API lấy danh sách biến thể mới nhất
      final variants = await provider.getVariants(widget.product.id);

      if (mounted) {
        setState(() {
          _variants = variants;
          _isLoadingVariants = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVariants = false);
      }
    }
  }
  // --- TAB 2 UI ---
  Widget _buildVariantsTab() {
    if (_isLoadingVariants) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // --- 1. NÚT TẠO BIẾN THỂ (GENERATE) ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_link),
              label: const Text('Tạo biến thể tự động (Generate)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD), // Màu xanh primary
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Chuyển sang màn hình tạo biến thể
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => AddVariantScreen(productId: widget.product.id),
                  ),
                ).then((_) {
                  // Khi quay lại thì reload danh sách để thấy biến thể mới
                  _loadVariants();
                });
              },
            ),
          ),
        ),

        // --- 2. DANH SÁCH BIẾN THỂ ---
        Expanded(
          child: _variants.isEmpty
              ? const Center(child: Text('Chưa có biến thể nào'))
              : ListView.builder(
            itemCount: _variants.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final item = _variants[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

                  // Hiển thị tên (VD: Đỏ - S)
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Hiển thị SKU, Giá, Kho
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('SKU: ${item.sku}'),
                      Text(
                        'Giá: ${item.price.toStringAsFixed(0)} đ  |  Kho: ${item.stock}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),

                  // --- SỬA LỖI TẠI ĐÂY ---
                  // Đổi _showQuickEditDialog thành _showEditVariantDialog
                  onTap: () => _showEditVariantDialog(item),

                  // --- 3. NÚT XÓA (THÙNG RÁC) ---
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDeleteVariant(item),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _confirmDeleteVariant(VariantItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa biến thể "${item.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Đóng dialog
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog trước khi xử lý

              // Gọi Provider để xóa
              // Sử dụng listen: false vì đang trong callback
              final provider = Provider.of<ProductProvider>(context, listen: false);

              // Gọi hàm deleteVariant đã có trong file product_provider.dart
              final success = await provider.deleteVariant(widget.product.id, item.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa biến thể thành công')),
                );
                // Reload lại danh sách sau khi xóa để cập nhật giao diện
                _loadVariants();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Xóa thất bại')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _showEditVariantDialog(VariantItem item) {
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    final stockCtrl = TextEditingController(text: item.stock.toString());
    final skuCtrl = TextEditingController(text: item.sku);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa: ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: skuCtrl,
              decoration: const InputDecoration(labelText: 'Mã SKU'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Giá bán'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stockCtrl,
              decoration: const InputDecoration(labelText: 'Tồn kho'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(priceCtrl.text) ?? 0;
              final newStock = int.tryParse(stockCtrl.text) ?? 0;
              _updateSingleVariant(item, newPrice, newStock, skuCtrl.text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}