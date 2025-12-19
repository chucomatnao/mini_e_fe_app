// lib/screens/add_variant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../providers/product_provider.dart'; // Đảm bảo đường dẫn đúng
import 'edit_product_screen.dart';

class AddVariantScreen extends StatefulWidget {
  final int productId;
  const AddVariantScreen({super.key, required this.productId});

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  // Cấu trúc: 'name': Controller, 'values': List<String>, 'tempValue': Controller
  final List<Map<String, dynamic>> _options = [];

  // Màu chủ đạo
  final Color primaryColor = const Color(0xFF0D6EFD);

  @override
  void dispose() {
    for (var opt in _options) {
      opt['name'].dispose();
      opt['tempValue'].dispose();
    }
    super.dispose();
  }

  // Thêm một nhóm thuộc tính mới (VD: Màu sắc)
  void _addOption() {
    if (_options.length < 3) {
      setState(() {
        _options.add({
          'name': TextEditingController(),
          'values': <String>[], // List chứa các tag đã nhập
          'tempValue': TextEditingController(), // Ô nhập liệu
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 3 nhóm thuộc tính')),
      );
    }
  }

  // Xóa cả nhóm thuộc tính
  void _removeOption(int index) {
    setState(() {
      _options[index]['name'].dispose();
      _options[index]['tempValue'].dispose();
      _options.removeAt(index);
    });
  }

  // Logic thêm giá trị (Tag) vào list
  void _addValueToOption(int index, String value) {
    final val = value.trim();
    if (val.isEmpty) return;

    final currentValues = _options[index]['values'] as List<String>;

    // Kiểm tra trùng lặp
    if (!currentValues.contains(val)) {
      setState(() {
        currentValues.add(val);
        _options[index]['tempValue'].clear(); // Clear ô nhập sau khi thêm
      });
    } else {
      _options[index]['tempValue'].clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giá trị "$val" đã tồn tại!'), duration: const Duration(seconds: 1)),
      );
    }
  }

  // Xóa một giá trị (Tag) khỏi list
  void _removeValueFromOption(int index, String valueToRemove) {
    setState(() {
      (_options[index]['values'] as List<String>).remove(valueToRemove);
    });
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
        elevation: 0,
      ),
      body: Column(
        children: [
          // Gợi ý nhỏ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade50,
            child: Text(
              '💡 Mẹo: Nhập giá trị rồi nhấn Enter hoặc dấu phẩy (,) để thêm nhanh.',
              style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
            ),
          ),

          Expanded(
            child: _options.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _options.length,
              itemBuilder: (ctx, i) => _buildOptionCard(i),
            ),
          ),

          _buildBottomAction(provider),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final opt = _options[index];
    final List<String> values = opt['values'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tiêu đề nhóm + Nút xóa nhóm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NHÓM THUỘC TÍNH ${index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _removeOption(index),
                  tooltip: 'Xóa nhóm này',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tên thuộc tính
                TextField(
                  controller: opt['name'],
                  decoration: InputDecoration(
                    labelText: 'Tên thuộc tính',
                    hintText: 'VD: Màu sắc, Size...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Khu vực hiển thị CHIPS (Các giá trị đã nhập)
                if (values.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: values.map((val) {
                      return Chip(
                        label: Text(val),
                        backgroundColor: const Color(0xFFE7F1FF), // Xanh nhạt
                        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        deleteIconColor: primaryColor,
                        onDeleted: () => _removeValueFromOption(index, val),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(color: primaryColor.withOpacity(0.2)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Ô nhập giá trị mới (Logic Enter/Phẩy)
                TextField(
                  controller: opt['tempValue'],
                  decoration: InputDecoration(
                    labelText: 'Thêm giá trị',
                    hintText: 'Nhập (VD: Đỏ) rồi Enter hoặc phẩy (,)',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle, color: primaryColor),
                      onPressed: () => _addValueToOption(index, opt['tempValue'].text),
                    ),
                  ),
                  onSubmitted: (val) => _addValueToOption(index, val),
                  onChanged: (val) {
                    if (val.contains(',')) {
                      final newValue = val.replaceAll(',', '');
                      _addValueToOption(index, newValue);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có biến thể nào',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text('Thêm nhóm thuộc tính để bắt đầu', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_options.length < 3)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Thêm nhóm thuộc tính mới'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isLoading || _options.isEmpty ? null : _submitVariants,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'Tạo và cấu hình giá',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === ĐÃ SỬA LOGIC TẠI ĐÂY ===
  Future<void> _submitVariants() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    // 1. Chuẩn bị dữ liệu
    final List<Map<String, dynamic>> options = _options.map((opt) {
      return {
        'name': (opt['name'] as TextEditingController).text.trim(),
        'values': opt['values'] as List<String>,
      };
    }).toList();

    // 2. Validate
    if (options.any((o) => o['name'].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tên thuộc tính không được để trống')));
      return;
    }
    if (options.any((o) => (o['values'] as List).isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mỗi thuộc tính phải có ít nhất 1 giá trị')));
      return;
    }

    try {
      // 3. Gọi API Generate (Tạo biến thể)
      final result = await provider.generateVariants(
        widget.productId,
        options,
        mode: 'replace',
      );

      if (result != null && mounted) {
        // 4. Gọi thêm API lấy chi tiết sản phẩm (Để có ProductModel)
        final updatedProduct = await provider.fetchProductDetail(widget.productId);

        if (updatedProduct != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo biến thể thành công!'), backgroundColor: Colors.green),
          );

          // 5. Chuyển sang EditProductScreen với object 'product'
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => EditProductScreen(product: updatedProduct), // ĐÃ SỬA
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi tải dữ liệu sản phẩm mới')),
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
}