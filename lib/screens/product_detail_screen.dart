import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoadingVariants = false;
  List<dynamic> _variants = [];

  @override
  void initState() {
    super.initState();
    _fetchVariants();
  }

  Future<void> _fetchVariants() async {
    setState(() => _isLoadingVariants = true);

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final result = await productProvider.listVariants(widget.product.id);

    if (mounted) {
      setState(() {
        _isLoadingVariants = false;
        _variants = result ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl.isNotEmpty)
              Center(
                child: Image.network(
                  product.imageUrl,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            Text(
              product.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${product.price.toStringAsFixed(0)} VND',
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),

            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(product.description!),
            ],

            const SizedBox(height: 24),
            const Divider(),

            // ==============================
            // 🧩 DANH SÁCH BIẾN THỂ
            // ==============================
            const Text(
              'Biến thể sản phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoadingVariants)
              const Center(child: CircularProgressIndicator())
            else if (_variants.isEmpty)
              const Text('Chưa có biến thể nào.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _variants.length,
                itemBuilder: (context, index) {
                  final v = _variants[index];
                  final name = v['name'] ?? 'Biến thể #${index + 1}';
                  final price = double.tryParse(v['price']?.toString() ?? '') ?? 0.0;
                  final stock = v['stock'] ?? 0;
                  final imageUrl = v['image']?['url'];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: imageUrl != null
                          ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.inventory_2_outlined),
                      title: Text(name),
                      subtitle: Text(
                        '${price.toStringAsFixed(0)} VND — Còn: $stock',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add-variant',
                  arguments: {'productId': product.id},
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm biến thể'),
            ),
          ],
        ),
      ),
    );
  }
}
