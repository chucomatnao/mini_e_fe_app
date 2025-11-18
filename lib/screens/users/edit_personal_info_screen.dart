// lib/screens/edit_personal_info_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';   // Thêm package này
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  // Avatar
  File? _selectedImageFile; // Ảnh mới chọn từ thư viện
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _genders = [
    {'value': 'MALE', 'label': 'Nam'},
    {'value': 'FEMALE', 'label': 'Nữ'},
    {'value': 'OTHER', 'label': 'Khác'},
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).me;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedGender = user?.gender;

    if (user?.birthday != null && user!.birthday!.isNotEmpty) {
      try {
        _selectedBirthDate = DateTime.parse(user!.birthday!);
      } catch (e) {
        try {
          _selectedBirthDate = DateFormat('dd/MM/yyyy').parse(user!.birthday!);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ==================== CHỌN ẢNH ====================
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  // ==================== CHỌN NGÀY ====================
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0D6EFD)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  // ==================== CHỌN GIỚI TÍNH ====================
  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Chọn giới tính', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ..._genders.map((g) => ListTile(
              leading: Icon(
                _selectedGender == g['value'] ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _selectedGender == g['value'] ? const Color(0xFF0D6EFD) : Colors.grey,
              ),
              title: Text(g['label']!),
              onTap: () {
                setState(() => _selectedGender = g['value']);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== LƯU THAY ĐỔI ====================
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final originalUser = userProvider.me;

      final Map<String, dynamic> updates = {};

      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();

      if (newName.isNotEmpty && newName != originalUser?.name) updates['name'] = newName;
      if (newPhone != originalUser?.phone) updates['phone'] = newPhone.isEmpty ? null : newPhone;
      if (_selectedGender != originalUser?.gender) updates['gender'] = _selectedGender;

      if (_selectedBirthDate != null) {
        final formatted = DateFormat('yyyy-MM-dd').format(_selectedBirthDate!);
        if (formatted != originalUser?.birthday) updates['birthday'] = formatted;
      }

      // Nếu có ảnh mới → thêm vào để upload
      if (_selectedImageFile != null) {
        updates['avatar'] = _selectedImageFile; // UserProvider sẽ xử lý multipart
      }

      if (updates.isNotEmpty) {
        await userProvider.updateProfile(updates);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
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
    final currentUser = Provider.of<UserProvider>(context, listen: false).me;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ==================== AVATAR ====================
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF0D6EFD),
                      backgroundImage: _selectedImageFile != null
                          ? FileImage(_selectedImageFile!) // Ưu tiên ảnh mới chọn
                          : null,
                      child: _selectedImageFile == null
                          ? Text(
                        currentUser?.name?.isNotEmpty == true
                            ? currentUser!.name![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D6EFD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library, color: Color(0xFF0D6EFD)),
                label: const Text('Chọn ảnh từ thư viện', style: TextStyle(color: Color(0xFF0D6EFD))),
              ),
              const SizedBox(height: 32),

              // Các field form (giống như trước)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại (không bắt buộc)',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return RegExp(r'^[0-9]{9,11}$').hasMatch(v) ? null : 'Số điện thoại không hợp lệ';
                },
              ),
              const SizedBox(height: 20),

              // Giới tính
              InkWell(
                onTap: _showGenderPicker,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Giới tính',
                    prefixIcon: const Icon(Icons.transgender),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedGender == null
                          ? 'Chưa chọn'
                          : _genders.firstWhere((g) => g['value'] == _selectedGender)['label']!),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ngày sinh
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedBirthDate == null
                          ? 'Chưa chọn'
                          : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Nút Lưu & Hủy
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}