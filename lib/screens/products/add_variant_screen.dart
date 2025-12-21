// lib/screens/add_variant_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../providers/product_provider.dart';
import '/../models/product_model.dart'; // ← THÊM import này
import 'edit_product_screen.dart';

class AddVariantScreen extends StatefulWidget {
  final int productId;
  final ProductModel? currentProduct; // ← THÊM: Để truyền product hiện tại

  const AddVariantScreen({
    super.key,
    required this.productId,
    this.currentProduct, // Optional, nếu có thì load schema cũ
  });

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  List<Map<String, dynamic>> _options = [];
  String _mode = 'replace'; // mặc định thay thế toàn bộ
  final Color primaryColor = const Color(0xFF0D6EFD);

  @override
  void initState() {
    super.initState();
    _loadExistingOptions();
  }

  // ← HÀM MỚI: Load optionSchema hiện tại từ product
  void _loadExistingOptions() {
    if (widget.currentProduct != null &&
        widget.currentProduct!.optionSchema != null &&
        widget.currentProduct!.optionSchema!.isNotEmpty) {
      setState(() {
        _options = widget.currentProduct!.optionSchema!.map((schema) {
          return {
            'name': TextEditingController(text: schema.name),
            'values': List<String>.from(schema.values),
            'tempValue': TextEditingController(),
          };
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    for (var opt in _options) {
      opt['name'].dispose();
      opt['tempValue'].dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_options.length < 5) {
      setState(() {
        _options.add({
          'name': TextEditingController(),
          'values': <String>[],
          'tempValue': TextEditingController(),
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 5 nhóm thuộc tính')),
      );
    }
  }

  void _removeOption(int index) {
    setState(() {
      _options[index]['name'].dispose();
      _options[index]['tempValue'].dispose();
      _options.removeAt(index);
    });
  }

  void _addValueToOption(int index, String value) {
    final val = value.trim();
    if (val.isEmpty) return;

    final currentValues = _options[index]['values'] as List<String>;
    if (!currentValues.contains(val)) {
      setState(() {
        currentValues.add(val);
        _options[index]['tempValue'].clear();
      });
    } else {
      _options[index]['tempValue'].clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giá trị "$val" đã tồn tại!')),
      );
    }
  }

  void _removeValueFromOption(int index, String valueToRemove) {
    setState(() {
      (_options[index]['values'] as List<String>).remove(valueToRemove);
    });
  }

  Future<void> _submitVariants() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    final List<Map<String, dynamic>> options = _options.map((opt) {
      return {
        'name': (opt['name'] as TextEditingController).text.trim(),
        'values': opt['values'] as List<String>,
      };
    }).toList();

    if (options.any((o) => o['name'].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên thuộc tính không được để trống')),
      );
      return;
    }
    if (options.any((o) => (o['values'] as List).isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mỗi thuộc tính phải có ít nhất 1 giá trị')),
      );
      return;
    }

    try {
      final result = await provider.generateVariants(
        widget.productId,
        options,
        mode: _mode,
      );

      if (result != null && mounted) {
        final updatedProduct = await provider.fetchProductDetail(widget.productId);
        if (updatedProduct != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật biến thể thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => EditProductScreen(product: updatedProduct),
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cấu hình biến thể'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Thay thế toàn bộ biến thể cũ\n(Tắt để chỉ thêm mới)',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Switch(
                      value: _mode == 'replace',
                      onChanged: (val) => setState(() => _mode = val ? 'replace' : 'add'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _options.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có nhóm thuộc tính nào.\nNhấn nút bên dưới để thêm.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _options.length,
                itemBuilder: (ctx, index) {
                  final opt = _options[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: opt['name'],
                                  decoration: const InputDecoration(
                                    labelText: 'Tên thuộc tính (VD: Màu sắc)',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeOption(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: (opt['values'] as List<String>).map((val) {
                              return Chip(
                                label: Text(val),
                                onDeleted: () => _removeValueFromOption(index, val),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: opt['tempValue'],
                                  decoration: const InputDecoration(
                                    hintText: 'Nhập giá trị mới',
                                  ),
                                  onSubmitted: (v) => _addValueToOption(index, v),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => _addValueToOption(
                                    index, opt['tempValue'].text),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Thêm nhóm thuộc tính'),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading || _options.isEmpty ? null : _submitVariants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Cập nhật biến thể',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}