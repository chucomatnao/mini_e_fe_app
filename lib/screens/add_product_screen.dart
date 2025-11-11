// lib/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'add_variant_screen.dart'; // Import AddVariantScreen

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _slugController = TextEditingController();
  List<File> _images = [];

  // ==================================================================
  // CHỌN ẢNH TỪ GALLERY
  // ==================================================================
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _images.addAll(pickedImages.map((xFile) => File(xFile.path)));
      });
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sản phẩm')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // TITLE
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
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
              validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
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

            // CHỌN ẢNH
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: const Text('Chọn ảnh'),
            ),
            const SizedBox(height: 8),
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.file(_images[i], width: 100, fit: BoxFit.cover),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // NÚT TẠO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: provider.isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    final price = double.tryParse(_priceController.text) ?? 0;
                    final stock = int.tryParse(_stockController.text) ?? null;

                    try {
                      final product = await provider.createProduct(
                        title: _titleController.text,
                        price: price,
                        stock: stock,
                        description: _descriptionController.text,
                        slug: _slugController.text,
                        images: _images,
                      );

                      if (product != null && product.id > 0) { // KIỂM TRA product.id tồn tại
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tạo sản phẩm thành công!')),
                        );

                        // LUỒNG: TỰ ĐỘNG CHUYỂN ĐẾN THÊM BIẾN THỂ
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => AddVariantScreen(productId: product.id),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tạo sản phẩm thất bại. Thử lại.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tạo sản phẩm', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}