import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../providers/product_provider.dart';
import 'add_variant_screen.dart'; // Import để chuyển trang nếu cần

class UpdateVariantScreen extends StatefulWidget {
  final int productId;
  const UpdateVariantScreen({super.key, required this.productId});

  @override
  State<UpdateVariantScreen> createState() => _UpdateVariantScreenState();
}

class _UpdateVariantScreenState extends State<UpdateVariantScreen> {
  // Biến trạng thái
  bool _isLoading = true;
  bool _isSaving = false;

  // Màu chủ đạo (Copy từ file add_variant)
  final Color primaryColor = const Color(0xFF0D6EFD);

  // List chứa dữ liệu biến thể
  // id: null nếu là biến thể mới thêm tay, có số nếu là biến thể cũ
  List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVariants();
    });
  }

  @override
  void dispose() {
    for (var v in _variants) {
      v['name'].dispose();
      v['price'].dispose();
      v['stock'].dispose();
      v['sku']?.dispose();
    }
    super.dispose();
  }

  // 1. Tải dữ liệu từ Server
  Future<void> _loadVariants() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final data = await provider.listVariants(widget.productId);

      if (mounted) {
        setState(() {
          _variants = (data ?? []).map((v) {
            return {
              'id': v['id'], // ID thực tế từ database
              'name': TextEditingController(text: v['name'] ?? ''),
              'price': TextEditingController(text: v['price']?.toString() ?? '0'),
              'stock': TextEditingController(text: v['stock']?.toString() ?? '0'),
              'sku': TextEditingController(text: v['sku'] ?? ''),
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải: $e')));
      }
    }
  }

  // 2. Chức năng THÊM dòng biến thể (Giống nút Thêm Option)
  void _addNewVariantRow() {
    setState(() {
      _variants.add({
        'id': null, // Đánh dấu là mới
        'name': TextEditingController(text: ''), // Để trống tên cho người dùng nhập
        'price': TextEditingController(text: '0'),
        'stock': TextEditingController(text: '0'),
        'sku': TextEditingController(text: ''),
      });
    });

    // Cuộn xuống cuối (Optional)
  }

  // 3. Chức năng XÓA biến thể (Giống nút Xóa Option)
  Future<void> _deleteVariant(int index) async {
    final item = _variants[index];
    final isNewItem = item['id'] == null; // Kiểm tra xem có phải hàng mới thêm không

    // Hiển thị hộp thoại xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa biến thể "${item['name'].text}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Logic xóa
    if (isNewItem) {
      // Nếu là dòng mới thêm tay (chưa lưu server) -> Chỉ cần xóa khỏi giao diện
      setState(() {
        item['name'].dispose();
        item['price'].dispose();
        item['stock'].dispose();
        item['sku'].dispose();
        _variants.removeAt(index);
      });
    } else {
      // Nếu là dữ liệu cũ -> Gọi API xóa thật
      final provider = Provider.of<ProductProvider>(context, listen: false);
      try {
        final success = await provider.deleteVariant(widget.productId, item['id']);
        if (success && mounted) {
          setState(() {
            _variants.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa biến thể thành công')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e')));
      }
    }
  }

  // 4. Chức năng LƯU TẤT CẢ (Save All)
  Future<void> _saveAllChanges() async {
    setState(() => _isSaving = true);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    int successCount = 0;

    try {
      // Dùng Future.wait để xử lý song song hoặc vòng lặp để xử lý tuần tự
      // Ở đây dùng vòng lặp để dễ debug
      for (var v in _variants) {
        final name = v['name'].text.trim();
        if (name.isEmpty) continue; // Bỏ qua nếu không có tên

        final dto = {
          'name': name,
          'price': double.tryParse(v['price'].text.replaceAll(',', '')) ?? 0,
          'stock': int.tryParse(v['stock'].text.replaceAll(',', '')) ?? 0,
          'sku': v['sku'].text.trim(),
        };

        if (v['id'] != null) {
          // --- Cập nhật (Update) ---
          await provider.updateVariant(widget.productId, v['id'], dto);
          successCount++;
        } else {
          // --- Tạo mới (Create) ---
          // Giả định Provider có hàm createVariantSingle
          await provider.createVariant(widget.productId, dto);
          successCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu thành công $successCount biến thể'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVariants(); // Tải lại để cập nhật ID mới
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền giống add_variant
      appBar: AppBar(
        title: const Text('Quản lý biến thể'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Nút tắt mở trang tạo tự động (nếu cần)
          IconButton(
            icon: const Icon(Icons.auto_awesome_motion),
            tooltip: 'Tạo tự động',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddVariantScreen(productId: widget.productId)),
              ).then((_) => _loadVariants());
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Gợi ý nhỏ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade50,
            child: Text(
              '💡 Mẹo: Nhập tên (VD: Đỏ - XL), giá và tồn kho rồi nhấn Lưu tất cả.',
              style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
            ),
          ),

          // Danh sách biến thể
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _variants.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _variants.length,
              itemBuilder: (ctx, i) => _buildVariantCard(i),
            ),
          ),

          // Khu vực nút bấm dưới cùng
          _buildBottomAction(),
        ],
      ),
    );
  }

  // Widget hiển thị Card biến thể (Style giống _buildOptionCard)
  Widget _buildVariantCard(int index) {
    final v = _variants[index];
    final isNew = v['id'] == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Viền xanh nếu là item mới
        border: isNew ? Border.all(color: primaryColor.withOpacity(0.5)) : null,
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
          // Header: Tiêu đề + Nút Xóa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(isNew ? Icons.add_circle : Icons.edit,
                        size: 16, color: isNew ? primaryColor : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      isNew ? 'BIẾN THỂ MỚI' : 'BIẾN THỂ #${v['id']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isNew ? primaryColor : Colors.blueGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteVariant(index),
                  tooltip: 'Xóa biến thể này',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body: Các ô nhập liệu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Tên biến thể & SKU
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: v['name'],
                        decoration: _inputDecoration('Tên (VD: Đỏ - XL)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: v['sku'],
                        decoration: _inputDecoration('SKU (Mã kho)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Giá & Tồn kho
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: v['price'],
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Giá bán', suffix: 'đ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: v['stock'],
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Tồn kho'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Style Input (Giống hệt file AddVariant)
  InputDecoration _inputDecoration(String label, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      filled: true,
      fillColor: Colors.grey.shade50,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1),
      ),
    );
  }

  // Widget hiển thị khi trống
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có biến thể nào',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text('Bấm nút Thêm bên dưới để bắt đầu', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Khu vực nút bấm (Giống _buildBottomAction)
  Widget _buildBottomAction() {
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
          // Nút thêm thủ công
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addNewVariantRow,
              icon: const Icon(Icons.add),
              label: const Text('Thêm biến thể thủ công'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nút Lưu Tất Cả
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAllChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'Lưu tất cả thay đổi',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}