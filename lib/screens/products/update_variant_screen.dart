import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../providers/product_provider.dart';

class UpdateVariantScreen extends StatefulWidget {
  final int productId;
  const UpdateVariantScreen({super.key, required this.productId});

  @override
  State<UpdateVariantScreen> createState() => _UpdateVariantScreenState();
}

class _UpdateVariantScreenState extends State<UpdateVariantScreen> {
  List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  Future<void> _loadVariants() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    final data = await provider.listVariants(widget.productId);
    if (data != null) {
      setState(() {
        _variants = data.map((v) {
          return {
            'id': v['id'],
            'name': TextEditingController(text: v['name'] ?? ''),
            'price': TextEditingController(text: v['price']?.toString() ?? ''),
            'stock': TextEditingController(text: v['stock']?.toString() ?? ''),
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật biến thể')),
      body: _variants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _variants.length,
        itemBuilder: (ctx, i) {
          final v = _variants[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: v['name'],
                    decoration: const InputDecoration(labelText: 'Tên biến thể'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: v['price'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Giá'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: v['stock'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tồn kho'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final dto = {
                        'name': v['name'].text.trim(),
                        if (v['price'].text.isNotEmpty)
                          'price': double.tryParse(v['price'].text),
                        if (v['stock'].text.isNotEmpty)
                          'stock': int.tryParse(v['stock'].text),
                      };

                      final success = await provider.updateVariant(
                          widget.productId, v['id'], dto);

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cập nhật thành công')),
                        );
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.popUntil(
              context, ModalRoute.withName('/shop-management'));
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
