// lib/screens/add_product_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/../../providers/product_provider.dart';
import '../../models/product_model.dart';
import 'add_variant_screen.dart';
import 'update_variant_screen.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? editProduct;

  const AddProductScreen({super.key, this.editProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _slugController;

  // ============================================================
  // CHỈ GIỮ ẢNH MỚI (XÓA LOGIC ẢNH CŨ)
  // ============================================================
  List<File> _images = [];
  List<Uint8List> _imageBytes = [];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.editProduct?.title ?? '');
    _descriptionController = TextEditingController(text: widget.editProduct?.description ?? '');
    _priceController = TextEditingController(text: widget.editProduct?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.editProduct?.stock?.toString() ?? '');
    _slugController = TextEditingController(text: widget.editProduct?.slug ?? '');

    // ============================================================
    // XÓA PHẦN LOAD ẢNH CŨ - KHÔNG CẦN NỮA
    // ============================================================
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHỌN ẢNH - GIỮ NGUYÊN LOGIC CŨ
  // ============================================================
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      if (kIsWeb) {
        final List<Uint8List> bytesList = [];
        for (var xFile in pickedImages) {
          final bytes = await xFile.readAsBytes();
          bytesList.add(bytes);
        }
        setState(() => _imageBytes.addAll(bytesList));
      } else {
        setState(() {
          _images.addAll(pickedImages.map((xFile) => File(xFile.path)));
        });
      }
    }
  }

  // ============================================================
  // HÀM SUBMIT - ĐƠN GIẢN HÓA
  // ============================================================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final isEditMode = widget.editProduct != null;

    final price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;

    try {
      if (isEditMode) {
        // ============================================================
        // CHỈNH SỬA: CHỈ GỬI ẢNH MỚI (NẾU CÓ)
        // Backend sẽ TỰ GIỮ ẢNH CŨ nếu không có ảnh mới
        // ============================================================
        final hasNewImages = (kIsWeb && _imageBytes.isNotEmpty) ||
            (!kIsWeb && _images.isNotEmpty);

        final success = await provider.updateProduct(
          productId: widget.editProduct!.id,
          title: _titleController.text.trim(),
          price: price,
          stock: stock == 0 ? null : stock,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          slug: _slugController.text.trim().isNotEmpty
              ? _slugController.text.trim()
              : null,
          // CHỈ GỬI ẢNH KHI CÓ ẢNH MỚI
          images: (!kIsWeb && hasNewImages) ? _images : null,
          imageBytes: (kIsWeb && hasNewImages) ? _imageBytes : null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hasNewImages
                  ? 'Cập nhật sản phẩm thành công! Ảnh mới đã được thêm vào.'
                  : 'Cập nhật sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // ============================================================
        // TẠO MỚI - GIỮ NGUYÊN
        // ============================================================
        final product = await provider.createProduct(
          title: _titleController.text.trim(),
          price: price,
          stock: stock == 0 ? null : stock,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          slug: _slugController.text.trim().isNotEmpty
              ? _slugController.text.trim()
              : null,
          images: kIsWeb ? null : (_images.isNotEmpty ? _images : null),
          imageBytes: kIsWeb ? (_imageBytes.isNotEmpty ? _imageBytes : null) : null,
        );

        if (product != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo sản phẩm thành công!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AddVariantScreen(productId: product.id)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final isEditMode = widget.editProduct != null;

    final totalNewImages = kIsWeb ? _imageBytes.length : _images.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty == true ? 'Nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _slugController,
                decoration: InputDecoration(
                  labelText: 'Slug (tùy chọn)',
                  hintText: 'Để trống sẽ tự sinh',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.auto_fix_high),
                    onPressed: () {
                      final raw = _titleController.text.trim();
                      if (raw.isEmpty) return;
                      final slug = raw.toLowerCase()
                          .replaceAll(RegExp(r'[^\w\s-]', unicode: true), '')
                          .replaceAll(RegExp(r'\s+'), '-')
                          .replaceAll(RegExp(r'-+'), '-')
                          .replaceAll(RegExp(r'^-|-$'), '');
                      _slugController.text = slug;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giá *',
                        prefixText: 'vn₫ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Nhập giá'
                          : (double.tryParse(v!.replaceAll(',', '')) == null
                          ? 'Giá không hợp lệ'
                          : null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tồn kho',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ============================================================
              // NÚT QUẢN LÝ BIẾN THỂ (CHỈ KHI EDIT)
              // ============================================================
              if (isEditMode)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateVariantScreen(
                            productId: widget.editProduct!.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune, color: Colors.blue),
                    label: const Text(
                      'Quản lý biến thể',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      side: const BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              if (isEditMode) const SizedBox(height: 32),

              // ============================================================
              // PHẦN ẢNH - CHỈ HIỂN THỊ ẢNH MỚI
              // ============================================================
              const Text(
                'Ảnh sản phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // ============================================================
              // HIỂN THỊ ẢNH CŨ (CHỈ ĐỂ THAM KHẢO - KHÔNG CHO XÓA)
              // ============================================================
              if (isEditMode && widget.editProduct!.imageUrl.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Ảnh hiện tại của sản phẩm:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.editProduct!.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '💡 Thêm ảnh mới bên dưới để bổ sung vào sản phẩm',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // ============================================================
              // HIỂN THỊ ẢNH MỚI (CHO PHÉP XÓA)
              // ============================================================
              if (totalNewImages > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditMode ? 'Ảnh mới sẽ thêm vào:' : 'Ảnh đã chọn:',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (kIsWeb ? _imageBytes : _images).map((dynamic item) {
                        final Uint8List bytes = kIsWeb
                            ? item as Uint8List
                            : File((item as File).path).readAsBytesSync();

                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                bytes,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (kIsWeb) {
                                      _imageBytes.remove(item);
                                    } else {
                                      _images.remove(item);
                                    }
                                  });
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // ============================================================
              // NÚT CHỌN ẢNH
              // ============================================================
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(isEditMode ? 'Thêm ảnh mới' : 'Chọn ảnh (tối đa 10)'),
              ),
              const SizedBox(height: 32),

              // ============================================================
              // NÚT LƯU
              // ============================================================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0D6EFD),
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm();
                    }
                  },
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    isEditMode ? 'Cập nhật sản phẩm' : 'Tạo sản phẩm',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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