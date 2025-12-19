import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Providers
import '/../models/product_model.dart';
import '/../providers/product_provider.dart';

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

  // --- TAB 2 UI ---
  Widget _buildVariantsTab() {
    if (_isLoadingVariants) return const Center(child: CircularProgressIndicator());

    if (_variants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sản phẩm chưa có biến thể nào.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  // Chuyển sang trang tạo biến thể
                  Navigator.pushNamed(context, '/add-variant', arguments: {'productId': widget.product.id})
                      .then((_) => _fetchVariants()); // Reload khi quay lại
                },
                child: const Text('Tạo biến thể ngay')
            )
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _variants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _variants[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('SKU: ${item.sku} | Tồn kho: ${item.stock}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${item.price.toStringAsFixed(0)} đ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 20, color: Colors.blue),
              ],
            ),
            onTap: () => _showEditVariantDialog(item),
          ),
        );
      },
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