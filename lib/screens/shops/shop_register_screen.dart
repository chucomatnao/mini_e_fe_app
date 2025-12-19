// lib/screens/shops/shop_register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';

class ShopRegisterScreen extends StatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  State<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends State<ShopRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(); // NEW
  final _addressCtrl = TextEditingController(); // NEW

  bool _checkingName = false;

  @override
  Widget build(BuildContext context) {
    final shopProvider = Provider.of<ShopProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhạt
      appBar: AppBar(
        title: const Text('Đăng ký Shop mới', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('1. Thông tin cơ bản'),
                _buildCard(
                  children: [
                    // Tên Shop
                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'Tên cửa hàng *',
                      icon: Icons.store,
                      suffix: _checkingName
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : null,
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Vui lòng nhập tên shop' : null,
                    ),
                    const SizedBox(height: 16),
                    // Mô tả
                    _buildTextField(
                      controller: _descCtrl,
                      label: 'Mô tả ngắn *',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Nhập mô tả giới thiệu shop' : null,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('2. Liên hệ & Địa chỉ'),
                _buildCard(
                  children: [
                    // Email
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email liên hệ',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Phone (New Field from Backend)
                    _buildTextField(
                      controller: _phoneCtrl,
                      label: 'Số điện thoại *',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Nhập SĐT để khách liên hệ' : null,
                    ),
                    const SizedBox(height: 16),
                    // Address (New Field from Backend)
                    _buildTextField(
                      controller: _addressCtrl,
                      label: 'Địa chỉ cửa hàng',
                      icon: Icons.location_on,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    // Map Picker Placeholder (Backend: lat/lng)
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.map, color: Color(0xFF0D6EFD)),
                          SizedBox(width: 8),
                          Text('Ghim vị trí trên bản đồ (Sắp có)', style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('3. Hình ảnh (Logo & Bìa)'),
                _buildCard(
                  children: [
                    Row(
                      children: [
                        // Logo Upload Placeholder
                        Expanded(
                          flex: 1,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt, color: Colors.grey),
                                  SizedBox(height: 4),
                                  Text('Logo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Cover Upload Placeholder
                        Expanded(
                          flex: 2,
                          child: AspectRatio(
                            aspectRatio: 16/9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.image, color: Colors.grey),
                                  SizedBox(height: 4),
                                  Text('Ảnh bìa', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: shopProvider.isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        // Gọi hàm register với đầy đủ thông tin (cần cập nhật service ở provider để nhận thêm param)
                        // Mock data cho các field thiếu logic upload
                        await shopProvider.register({
                          'name': _nameCtrl.text.trim(),
                          'email': _emailCtrl.text.trim().toLowerCase(),
                          'description': _descCtrl.text.trim(),
                          'shopPhone': _phoneCtrl.text.trim(), // Send to backend
                          'shopAddress': _addressCtrl.text.trim(), // Send to backend
                        });

                        if (shopProvider.error == null && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đăng ký thành công! Chờ duyệt...')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: shopProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('GỬI ĐĂNG KÝ NGAY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
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
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}