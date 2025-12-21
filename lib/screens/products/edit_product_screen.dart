// lib/screens/edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../models/product_model.dart';
import '/../providers/product_provider.dart';
import 'add_variant_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeyInfo = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  bool _isLoadingVariants = false;
  List<VariantItem> _variants = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _titleController = TextEditingController(text: widget.product.title);
    _descController =
        TextEditingController(text: widget.product.description ?? '');
    _priceController =
        TextEditingController(text: widget.product.price.toStringAsFixed(0));

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi tải biến thể: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingVariants = false);
    }
  }

  Future<void> _saveProductInfo() async {
    if (!_formKeyInfo.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.updateProduct(
      productId: widget.product.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin sản phẩm thành công')),
      );
      _fetchVariants(); // Reload nếu cần
    }
  }

  void _updateSingleVariant(VariantItem item, double newPrice, int newStock,
      String newSku) async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.updateVariant(
      widget.product.id,
      item.id,
      {
        if (newPrice > 0) 'price': newPrice,
        'stock': newStock,
        if (newSku.trim().isNotEmpty) 'sku': newSku.trim().toUpperCase(),
      },
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật biến thể thành công')),
      );
      _fetchVariants();
    }
  }

  void _showEditVariantDialog(VariantItem item) {
    final priceCtrl =
    TextEditingController(text: item.price.toStringAsFixed(0));
    final stockCtrl = TextEditingController(text: item.stock.toString());
    final skuCtrl = TextEditingController(text: item.sku);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa biến thể: ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.options
                      .map((opt) => Text(
                      '${opt['option']}: ${opt['value']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)))
                      .toList(),
                ),
              ),
            TextField(
              controller: skuCtrl,
              decoration: const InputDecoration(labelText: 'Mã SKU'),
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Giá bán'),
              keyboardType: TextInputType.number,
            ),
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
              Navigator.pop(ctx);
              _updateSingleVariant(item, newPrice, newStock, skuCtrl.text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Biến thể'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Thông tin
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKeyInfo,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                    validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Giá cơ bản'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveProductInfo,
                    child: const Text('Lưu thông tin'),
                  ),
                ],
              ),
            ),
          ),

          // Tab 2: Biến thể
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // Lấy product mới nhất trước khi mở màn hình cấu hình
                    final provider = Provider.of<ProductProvider>(context, listen: false);
                    final latestProduct = await provider.fetchProductDetail(widget.product.id);

                    if (latestProduct != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddVariantScreen(
                            productId: widget.product.id,
                            currentProduct: latestProduct, // ← TRUYỀN PRODUCT ĐỂ LOAD SCHEMA
                          ),
                        ),
                      ).then((_) => _fetchVariants()); // Reload variants khi quay lại
                    }
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Cấu hình lại biến thể'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Để thêm/xóa/thay đổi thuộc tính (Màu, Size...) hoặc xóa biến thể, dùng nút trên.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoadingVariants
                      ? const Center(child: CircularProgressIndicator())
                      : _variants.isEmpty
                      ? const Center(
                    child: Text('Chưa có biến thể nào'),
                  )
                      : ListView.builder(
                    itemCount: _variants.length,
                    itemBuilder: (ctx, index) {
                      final item = _variants[index];
                      return Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              if (item.options.isNotEmpty)
                                ...item.options.map((opt) => Text(
                                    '${opt['option']}: ${opt['value']}')),
                              Text('SKU: ${item.sku}'),
                              Text(
                                  'Giá: ${item.price.toStringAsFixed(0)}đ | Tồn: ${item.stock}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showEditVariantDialog(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}