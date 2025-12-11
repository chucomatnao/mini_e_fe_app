// lib/screens/edit_personal_info_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

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
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

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

      if (_selectedImageFile != null) {
        updates['avatar'] = _selectedImageFile;
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

  // Widget hỗ trợ: Input Field với Label bên trên
  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // Widget hỗ trợ: Nút chọn giới tính (Segmented Button)
  Widget _buildGenderOption(String value, String label) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D6EFD) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0D6EFD) : Colors.grey[300]!,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).me;

    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch sẽ
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== AVATAR ====================
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0D6EFD).withOpacity(0.2), width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF0D6EFD),
                            backgroundImage: _selectedImageFile != null
                                ? FileImage(_selectedImageFile!)
                                : null,
                            child: _selectedImageFile == null
                                ? Text(
                              currentUser?.name?.isNotEmpty == true
                                  ? currentUser!.name![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : null,
                          ),
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
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text(
                        'Đổi ảnh đại diện',
                        style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==================== FORM FIELDS ====================

              // Họ và tên
              _buildLabeledTextField(
                label: 'Họ và tên',
                controller: _nameController,
                hint: 'Nhập họ tên của bạn',
                validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 20),

              // Số điện thoại
              _buildLabeledTextField(
                label: 'Số điện thoại',
                controller: _phoneController,
                hint: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  return RegExp(r'^[0-9]{9,11}$').hasMatch(v) ? null : 'SĐT không hợp lệ';
                },
              ),
              const SizedBox(height: 20),

              // Ngày sinh
              Text(
                'Ngày sinh',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedBirthDate == null
                            ? 'dd/mm/yyyy'
                            : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!),
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedBirthDate == null ? Colors.grey[400] : Colors.black87,
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Giới tính (Giao diện 3 nút ngang)
              Text(
                'Giới tính',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderOption('MALE', 'Nam'),
                  const SizedBox(width: 10),
                  _buildGenderOption('FEMALE', 'Nữ'),
                  const SizedBox(width: 10),
                  _buildGenderOption('OTHER', 'Khác'),
                ],
              ),

              const SizedBox(height: 40),

              // ==================== NÚT LƯU ====================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Bo tròn nhiều hơn
                    elevation: 2,
                    shadowColor: const Color(0xFF0D6EFD).withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                      : const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}