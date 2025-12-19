// lib/screens/add_product_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '/../providers/product_provider.dart';
import '/../models/product_model.dart';
import 'add_variant_screen.dart';
import 'edit_product_screen.dart'; // Đảm bảo bạn có file này

class AddProductScreen extends StatefulWidget {
  final ProductModel? editProduct;

  const AddProductScreen({super.key, this.editProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _slugController;

  // Ảnh mới
  List<File> _images = [];
  List<Uint8List> _imageBytes = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editProduct?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.editProduct?.description ?? '');
    _priceController =
        TextEditingController(text: widget.editProduct?.price.toString() ?? '');
    _slugController = TextEditingController(text: widget.editProduct?.slug ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  // Chọn ảnh
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isEmpty) return;

    if (kIsWeb) {
      final List<Uint8List> bytesList = [];
      for (var xFile in picked) {
        final bytes = await xFile.readAsBytes();
        bytesList.add(bytes);
      }
      setState(() => _imageBytes.addAll(bytesList));
    } else {
      setState(() {
        _images.addAll(picked.map((xFile) => File(xFile.path)));
      });
    }
  }

  // Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final isEditMode = widget.editProduct != null;

    final price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0.0;

    try {
      if (isEditMode) {
        // CẬP NHẬT SẢN PHẨM
        final hasNewImages =
            (kIsWeb && _imageBytes.isNotEmpty) || (!kIsWeb && _images.isNotEmpty);

        final success = await provider.updateProduct(
          productId: widget.editProduct!.id,
          title: _titleController.text.trim(),
          price: price,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          slug: _slugController.text.trim().isNotEmpty
              ? _slugController.text.trim()
              : null,
          images: (!kIsWeb && hasNewImages) ? _images : null,
          imageBytes: (kIsWeb && hasNewImages) ? _imageBytes : null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(hasNewImages
                  ? 'Cập nhật sản phẩm thành công! Ảnh mới đã được thêm.'
                  : 'Cập nhật sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // TẠO MỚI SẢN PHẨM
        final product = await provider.createProduct(
          title: _titleController.text.trim(),
          price: price,
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
            MaterialPageRoute(
              builder: (_) => AddVariantScreen(productId: product.id),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
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
              // Tên sản phẩm
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v?.trim().isEmpty == true ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),

              // Slug
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
                      final slug = raw
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^\w\s-]'), '')
                          .replaceAll(RegExp(r'\s+'), '-')
                          .replaceAll(RegExp(r'-+'), '-')
                          .replaceAll(RegExp(r'^-|-$'), '');
                      _slugController.text = slug;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Giá
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá bán *',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'Vui lòng nhập giá';
                  if (double.tryParse(v!.replaceAll(',', '')) == null) {
                    return 'Giá không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // === NÚT QUẢN LÝ BIẾN THỂ (ĐÃ SỬA LỖI TẠI ĐÂY) ===
              if (isEditMode)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProductScreen(
                            // SỬA: Truyền 'product' thay vì 'productId'
                            product: widget.editProduct!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('Quản lý biến thể'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      side: const BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (isEditMode) const SizedBox(height: 32),

              // Ảnh sản phẩm
              const Text(
                'Ảnh sản phẩm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Ảnh hiện tại (chỉ hiển thị khi edit - không cho xóa)
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
                      const Text(
                        'Ảnh hiện tại:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.editProduct!.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

              // Ảnh mới đã chọn
              if (totalNewImages > 0)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: (kIsWeb ? _imageBytes : _images).map((dynamic item) {
                    final bytes = kIsWeb
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
                            onTap: () => setState(() {
                              kIsWeb ? _imageBytes.remove(item) : _images.remove(item);
                            }),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Nút chọn ảnh
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(isEditMode
                    ? 'Thêm ảnh mới (tối đa 10)'
                    : 'Chọn ảnh sản phẩm (tối đa 10)'),
              ),
              const SizedBox(height: 32),

              // Nút lưu
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
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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