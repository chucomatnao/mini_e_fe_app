// lib/screens/edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  // Màu chủ đạo cho giao diện (Modern Blue)
  final Color _primaryColor = const Color(0xFF0D6EFD);
  final Color _greyColor = const Color(0xFFF3F4F6);

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
        const SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Widget helper để tạo TextField đẹp hơn
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showEditVariantDialog(VariantItem variant) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final nameCtrl = TextEditingController(text: variant.name);
    final skuCtrl = TextEditingController(text: variant.sku);
    final priceCtrl = TextEditingController(text: variant.price.toStringAsFixed(0));
    final stockCtrl = TextEditingController(text: variant.stock.toString());
    int? selectedImageId = variant.imageId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_note, color: _primaryColor),
            const SizedBox(width: 8),
            const Text('Sửa biến thể'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernTextField(controller: nameCtrl, label: 'Tên biến thể'),
              Row(
                children: [
                  Expanded(child: _buildModernTextField(controller: skuCtrl, label: 'SKU')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernTextField(
                      controller: stockCtrl,
                      label: 'Tồn kho',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _buildModernTextField(
                controller: priceCtrl,
                label: 'Giá bán',
                keyboardType: TextInputType.number,
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 8),
              // Chọn ảnh
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ảnh đại diện',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedImageId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: widget.product.images.asMap().entries.map((entry) {
                      int idx = entry.key;
                      ProductImage img = entry.value;
                      return DropdownMenuItem<int>(
                        value: img.id,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: img.url,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: Colors.grey[200]),
                                errorWidget: (_, __, ___) => const Icon(Icons.error, size: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Ảnh ${idx + 1}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      selectedImageId = newId;
                    },
                    hint: const Text('Chọn ảnh từ thư viện sản phẩm'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final dto = {
                'name': nameCtrl.text.trim(),
                'sku': skuCtrl.text.trim(),
                'price': double.tryParse(priceCtrl.text) ?? variant.price,
                'stock': int.tryParse(stockCtrl.text) ?? variant.stock,
                'imageId': selectedImageId,
              };
              final success = await provider.updateVariant(
                widget.product.id,
                variant.id,
                dto,
              );
              if (success && mounted) {
                Navigator.pop(ctx);
                _fetchVariants();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật biến thể thành công')),
                );
              }
            },
            child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greyColor, // Nền xám nhạt hiện đại
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Thông tin chung'),
            Tab(text: 'Biến thể (Size/Màu)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- TAB 1: THÔNG TIN ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKeyInfo,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          controller: _titleController,
                          label: 'Tên sản phẩm',
                          icon: Icons.shopping_bag_outlined,
                          validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _priceController,
                                label: 'Giá bán (VNĐ)',
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
                              ),
                            ),
                          ],
                        ),
                        _buildModernTextField(
                          controller: _descController,
                          label: 'Mô tả chi tiết',
                          maxLines: 5,
                          icon: Icons.description_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _saveProductInfo,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Lưu thông tin',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- TAB 2: BIẾN THỂ ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cấu hình biến thể',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blue.shade800),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Thêm/Xóa thuộc tính hoặc tạo lại biến thể',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddVariantScreen(
                                productId: widget.product.id,
                                currentProduct: widget.product,
                              ),
                            ),
                          ).then((_) => _fetchVariants());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cấu hình'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List Variants
                Expanded(
                  child: _isLoadingVariants
                      ? const Center(child: CircularProgressIndicator())
                      : _variants.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('Chưa có biến thể nào',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: _variants.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final item = _variants[index];
                      String? variantImageUrl;
                      if (item.imageId != null) {
                        try {
                          final img = widget.product.images.firstWhere(
                                (img) => img.id == item.imageId,
                          );
                          variantImageUrl = img.url;
                        } catch (_) {}
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Ảnh
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                  color: Colors.grey.shade50,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: variantImageUrl != null
                                      ? CachedNetworkImage(
                                    imageUrl: variantImageUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 20, color: Colors.grey),
                                  )
                                      : const Icon(Icons.image,
                                      color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: item.options.map((opt) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                            BorderRadius.circular(4),
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            '${opt['value']}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade800),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'SKU: ${item.sku}  |  Tồn: ${item.stock}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              // Giá & Nút sửa
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.price.toStringAsFixed(0)}đ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20),
                                    color: Colors.grey.shade600,
                                    style: IconButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                                    onPressed: () =>
                                        _showEditVariantDialog(item),
                                  ),
                                ],
                              )
                            ],
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