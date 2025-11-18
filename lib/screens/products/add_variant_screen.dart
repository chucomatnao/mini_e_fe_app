import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'update_variant_screen.dart';

class AddVariantScreen extends StatefulWidget {
  final int productId;
  const AddVariantScreen({super.key, required this.productId});

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  final List<Map<String, TextEditingController>> _options = [];

  void _addOption() {
    if (_options.length < 5) {
      setState(() {
        _options.add({
          'name': TextEditingController(),
          'values': TextEditingController(),
        });
      });
    }
  }

  @override
  void dispose() {
    for (var opt in _options) {
      opt['name']!.dispose();
      opt['values']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm biến thể')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _options.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có option. Nhấn "Thêm option" để bắt đầu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _options.length,
                itemBuilder: (ctx, i) {
                  final opt = _options[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: opt['name'],
                            decoration: const InputDecoration(
                              labelText: 'Tên option (VD: Màu sắc)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: opt['values'],
                            decoration: const InputDecoration(
                              labelText: 'Giá trị (VD: Đỏ, Xanh, Vàng)',
                              hintText: 'Phân cách bằng dấu phẩy',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  opt['name']!.dispose();
                                  opt['values']!.dispose();
                                  _options.removeAt(i);
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Xóa',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_options.length < 5)
              ElevatedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Thêm option'),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed:
                provider.isLoading || _options.isEmpty ? null : () async {
                  final List<Map<String, dynamic>> options = _options.map((opt) {
                    final rawValues = opt['values']!.text
                        .split(',')
                        .map((v) => v.trim())
                        .where((v) => v.isNotEmpty)
                        .toList();

                    return {
                      'name': opt['name']!.text.trim(),
                      'values': rawValues,
                    };
                  }).toList();

                  if (options.any((o) => o['name'].isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tên option không được để trống')),
                    );
                    return;
                  }

                  try {
                    final result = await provider.generateVariants(
                      widget.productId,
                      options,
                      mode: 'replace',
                    );

                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tạo biến thể thành công!')),
                      );

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                UpdateVariantScreen(productId: widget.productId),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tạo biến thể', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
