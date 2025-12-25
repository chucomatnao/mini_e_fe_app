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
  late final TextEditingController _slugController;

  // Ảnh mới chọn
  List<File> _images = [];          // Mobile
  List<Uint8List> _imageBytes = []; // Web

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editProduct?.title ?? '');
    _descriptionController = TextEditingController(text: widget.editProduct?.description ?? '');
    _priceController = TextEditingController(text: widget.editProduct?.price.toStringAsFixed(0) ?? '');
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

  // Chọn nhiều ảnh
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

    // Giới hạn tối đa 10 ảnh
    if (kIsWeb && _imageBytes.length > 10) {
      _imageBytes = _imageBytes.sublist(0, 10);
    } else if (!kIsWeb && _images.length > 10) {
      _images = _images.sublist(0, 10);
    }
  }

  // Xóa ảnh đã chọn
  void _removeImage(dynamic item) {
    setState(() {
      if (kIsWeb) {
        _imageBytes.remove(item);
      } else {
        _images.remove(item);
      }
    });
  }

  // Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final isEditMode = widget.editProduct != null;

    final price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0.0;

    try {
      if (isEditMode) {
        // Chỉ update text fields (backend chưa hỗ trợ update ảnh)
        final success = await provider.updateProduct(
          productId: widget.editProduct!.id,
          title: _titleController.text.trim(),
          price: price,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          slug: _slugController.text.trim().isNotEmpty ? _slugController.text.trim() : null,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // TẠO SẢN PHẨM MỚI - UPLOAD ẢNH ĐÚNG CÁCH
        final newProduct = await provider.createProduct(
          title: _titleController.text.trim(),
          price: price,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          slug: _slugController.text.trim().isNotEmpty ? _slugController.text.trim() : null,
          images: kIsWeb ? _imageBytes : _images, // Gửi đúng vào 'images' (List<dynamic>)
        );

        if (newProduct != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Chuyển sang màn hình thêm biến thể
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AddVariantScreen(productId: newProduct.id),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên sản phẩm' : null,
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
                  if (double.tryParse(v!.replaceAll(',', '')) == null || double.tryParse(v)! <= 0) {
                    return 'Giá phải là số dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Ảnh hiện tại (chỉ khi edit)
              if (isEditMode && widget.editProduct!.imageUrl.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ảnh hiện tại:', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    const SizedBox(height: 16),
                  ],
                ),

              // Ảnh mới đã chọn
              if (totalNewImages > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ảnh mới (${totalNewImages}/10):',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
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
                                onTap: () => _removeImage(item),
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
                  ],
                ),

              // Nút chọn ảnh
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text('Chọn ảnh sản phẩm (tối đa 10, đã chọn: $totalNewImages)'),
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
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    isEditMode ? 'Cập nhật sản phẩm' : 'Tạo sản phẩm',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}