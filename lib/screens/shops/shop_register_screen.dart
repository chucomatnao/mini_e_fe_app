// lib/screens/shops/shop_register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/shop_provider.dart';

// Widgets mới tích hợp
import '../../widgets/vietnam_address_selector.dart';
import '../../widgets/osm_location_picker.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers giữ nguyên như cũ
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Controller này sẽ chứa chuỗi địa chỉ đầy đủ từ Selector trả về
  final _addressCtrl = TextEditingController();

  // Lưu toạ độ (giữ nguyên tên biến)
  double? _shopLat;
  double? _shopLng;

  bool _checkingName = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng ký
  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_shopLat == null || _shopLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn vị trí shop trên bản đồ')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ShopProvider>();

      // Kiểm tra tên shop (nếu cần logic check trùng)
      // await provider.checkShopName(_nameCtrl.text);

      // Gọi hàm register trong Provider
      // Lưu ý: shopAddress lấy từ _addressCtrl (đã được Selector điền)
      await provider.register({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'shopAddress': _addressCtrl.text.trim(),
        'shopLat': _shopLat,
        'shopLng': _shopLng,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký shop thành công! Chờ duyệt.')),
        );
        Navigator.pop(context); // Quay lại màn hình trước
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Đăng ký mở Shop'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin cơ bản'),
              _buildCard(
                children: [
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Tên Shop',
                    icon: Icons.store,
                    validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập tên shop' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'Email liên hệ',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => (val == null || !val.contains('@')) ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneCtrl,
                    label: 'Số điện thoại',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (val) => (val == null || val.length < 9) ? 'SĐT không hợp lệ' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descCtrl,
                    label: 'Mô tả ngắn',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Địa chỉ & Vị trí'),
              _buildCard(
                children: [
                  // 1. Widget chọn địa chỉ hành chính (Tỉnh/Huyện/Xã)
                  VietnamAddressSelector(
                    onAddressChanged: (fullAddress) {
                      // Cập nhật chuỗi địa chỉ đầy đủ vào controller
                      _addressCtrl.text = fullAddress;
                    },
                    onCoordinatesChanged: (lat, lng) {
                      // Nếu chọn địa chỉ có toạ độ (từ gợi ý), cập nhật map
                      if (lat != null && lng != null) {
                        setState(() {
                          _shopLat = lat;
                          _shopLng = lng;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text('Ghim vị trí chính xác:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // 2. Widget bản đồ OSM
                  SizedBox(
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OsmLocationPicker(
                        initLat: _shopLat, // Truyền vào để map update khi chọn từ Selector
                        initLng: _shopLng,
                        onPicked: (lat, lng) {
                          // Người dùng bấm trên map -> Cập nhật toạ độ cuối cùng
                          setState(() {
                            _shopLat = lat;
                            _shopLng = lng;
                          });
                        },
                      ),
                    ),
                  ),

                  // Hiển thị toạ độ đã chọn (Optional)
                  if (_shopLat != null && _shopLng != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Toạ độ: ${_shopLat!.toStringAsFixed(5)}, ${_shopLng!.toStringAsFixed(5)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ĐĂNG KÝ NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets (Giữ nguyên style cũ) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}