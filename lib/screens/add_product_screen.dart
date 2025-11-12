// lib/screens/add_product_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart'; // THÊM: DÙNG CHO editProduct
import 'add_variant_screen.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? editProduct; // THÊM: CHO PHÉP CHỈNH SỬA

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

  // ẢNH MỚI (khi sửa)
  List<File> _images = [];
  List<Uint8List> _imageBytes = [];

  // ẢNH CŨ (hiển thị khi sửa)
  List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();

    // KHỞI TẠO CONTROLLER VỚI DỮ LIỆU CŨ NẾU CÓ
    _titleController = TextEditingController(text: widget.editProduct?.title ?? '');
    _descriptionController = TextEditingController(text: widget.editProduct?.description ?? '');
    _priceController = TextEditingController(text: widget.editProduct?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.editProduct?.stock?.toString() ?? '');
    _slugController = TextEditingController(text: widget.editProduct?.slug ?? '');

    // LẤY ẢNH CŨ NẾU LÀ CHỈNH SỬA
    if (widget.editProduct != null && widget.editProduct!.imageUrl.isNotEmpty) {
      _existingImageUrls = [widget.editProduct!.imageUrl];
    }
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

  // ==================================================================
  // CHỌN NHIỀU ẢNH (MOBILE + WEB)
  // ==================================================================
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final isEditMode = widget.editProduct != null;

    final totalNewImages = kIsWeb ? _imageBytes.length : _images.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // TITLE
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              validator: (v) => v!.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 8),

            // DESCRIPTION
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),

            // PRICE
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá (VND)'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 8),

            // STOCK
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: 'Tồn kho'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            // SLUG
            TextFormField(
              controller: _slugController,
              decoration: const InputDecoration(labelText: 'Slug (tùy chọn)'),
            ),
            const SizedBox(height: 16),

            // NÚT CHỌN ẢNH
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Chọn ảnh mới'),
            ),
            const SizedBox(height: 8),

            // HIỂN THỊ ẢNH CŨ (khi sửa)
            if (_existingImageUrls.isNotEmpty) ...[
              const Text('Ảnh hiện tại:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _existingImageUrls.length,
                  itemBuilder: (ctx, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _existingImageUrls[i],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // HIỂN THỊ ẢNH MỚI
            if (totalNewImages > 0) ...[
              const Text('Ảnh mới:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: totalNewImages,
                  itemBuilder: (ctx, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.memory(_imageBytes[i], width: 100, height: 100, fit: BoxFit.cover)
                            : Image.file(_images[i], width: 100, height: 100, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // NÚT LƯU / CẬP NHẬT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isEditMode ? Colors.orange : null,
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                  if (!_formKey.currentState!.validate()) return;

                  final price = double.tryParse(_priceController.text) ?? 0;
                  final stock = int.tryParse(_stockController.text);

                  try {
                    List<File>? mobileImages = kIsWeb ? null : _images;
                    List<Uint8List>? webImages = kIsWeb ? _imageBytes : null;

                    if (isEditMode) {
                      // CHỈNH SỬA
                      final success = await provider.updateProduct(
                        productId: widget.editProduct!.id,
                        title: _titleController.text.trim(),
                        price: price,
                        stock: stock,
                        description: _descriptionController.text.trim().isNotEmpty
                            ? _descriptionController.text.trim()
                            : null,
                        slug: _slugController.text.trim().isNotEmpty
                            ? _slugController.text.trim()
                            : null,
                        images: mobileImages,
                        imageBytes: webImages,
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
                      // TẠO MỚI
                      final product = await provider.createProduct(
                        title: _titleController.text.trim(),
                        price: price,
                        stock: stock,
                        description: _descriptionController.text.trim().isNotEmpty
                            ? _descriptionController.text.trim()
                            : null,
                        slug: _slugController.text.trim().isNotEmpty
                            ? _slugController.text.trim()
                            : null,
                        images: mobileImages,
                        imageBytes: webImages,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                },
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isEditMode ? 'Cập nhật sản phẩm' : 'Tạo sản phẩm',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}