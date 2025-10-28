import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

/// Màn hình Profile hiển thị và cho phép chỉnh sửa thông tin cá nhân của người dùng.
/// Tích hợp với API backend qua AuthProvider để gọi PATCH /users/:id.
/// Hỗ trợ loading, error handling, và thông báo qua SnackBar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  /// Hiển thị SnackBar với thông báo
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Hiển thị dialog để chỉnh sửa text field (name, phone)
  void _showEditDialog(
      BuildContext context,
      String title,
      String currentValue,
      Function(String) onSave,
      ) {
    final controller = TextEditingController(text: currentValue);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chỉnh sửa $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập $title mới',
            errorText: auth.errorMessage, // Hiển thị lỗi từ AuthProvider
          ),
          enabled: !auth.isLoading, // Vô hiệu hóa khi đang loading
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: auth.isLoading
                ? null // Vô hiệu hóa nút khi đang loading
                : () {
              final newValue = controller.text.trim();
              if (newValue.isEmpty && title != 'Số điện thoại') {
                _showSnackBar(context, '$title không được để trống', isError: true);
                return;
              }
              onSave(newValue); // Gọi hàm lưu
              Navigator.pop(ctx);
            },
            child: auth.isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị một dòng thông tin (label + value + nút Sửa)
  Widget _infoRow(
      BuildContext context,
      String label,
      String? value,
      VoidCallback onEdit,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '—',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Text(
              'Sửa',
              style: TextStyle(color: Colors.blue, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget menu item cho các chức năng khác (ngân hàng, địa chỉ, v.v.)
  Widget _menuTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4F4F4F)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy AuthProvider để truy cập user và trạng thái
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Kiểm tra nếu chưa đăng nhập hoặc đang tải
    if (user == null || auth.isLoading && user.id == null) {
      return Scaffold(
        body: Center(
          child: auth.isLoading
              ? const CircularProgressIndicator()
              : const Text('Vui lòng đăng nhập để xem hồ sơ'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D6EFD),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ──────────────────── AVATAR + NAME + EMAIL ────────────────────
              Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF0872FF),
                    child: Text(
                      user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name ?? 'Người dùng',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'email@example.com',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showSnackBar(context, 'Tính năng tải ảnh sắp có!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFD9D9D9)),
                      elevation: 0,
                    ),
                    child: const Text('Chọn ảnh', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ──────────────────── THÔNG TIN CÁ NHÂN ────────────────────
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      // Sửa Tên
                      _infoRow(context, 'Tên đăng nhập', user.name, () {
                        _showEditDialog(context, 'Tên', user.name ?? '', (newValue) {
                          auth.updateProfile({'name': newValue});
                        });
                      }),
                      // Email không cho sửa
                      _infoRow(context, 'Email', user.email, () {
                        _showSnackBar(context, 'Email không thể thay đổi', isError: true);
                      }),
                      // Sửa Số điện thoại
                      _infoRow(context, 'Số điện thoại', user.phone, () {
                        _showEditDialog(context, 'Số điện thoại', user.phone ?? '', (newValue) {
                          auth.updateProfile({'phone': newValue.isEmpty ? null : newValue});
                        });
                      }),
                      // Sửa Ngày sinh
                      _infoRow(context, 'Ngày sinh', user.birthday, () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(user.birthday ?? '') ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        ).then((date) {
                          if (date != null) {
                            final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            auth.updateProfile({'birthday': formatted});
                          }
                        });
                      }),
                      // Sửa Giới tính
                      _infoRow(context, 'Giới tính', user.gender == 'MALE' ? 'Nam' : user.gender == 'FEMALE' ? 'Nữ' : user.gender == 'OTHER' ? 'Khác' : null, () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: ['MALE', 'FEMALE', 'OTHER'].map((g) {
                              final display = g == 'MALE' ? 'Nam' : g == 'FEMALE' ? 'Nữ' : 'Khác';
                              return ListTile(
                                title: Text(display),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  auth.updateProfile({'gender': g});
                                },
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ──────────────────── MENU CHỨC NĂNG ────────────────────
              _menuTile(
                context,
                icon: Icons.account_balance,
                title: 'Ngân hàng',
                onTap: () => _showSnackBar(context, 'Chức năng Ngân hàng sắp có!'),
              ),
              _menuTile(
                context,
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ',
                onTap: () => _showSnackBar(context, 'Chức năng Địa chỉ sắp có!'),
              ),
              _menuTile(
                context,
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () => Navigator.pushNamed(context, '/forgot-password'),
              ),
              _menuTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Cài đặt thông báo',
                onTap: () => _showSnackBar(context, 'Chức năng Cài đặt thông báo sắp có!'),
              ),
              _menuTile(
                context,
                icon: Icons.shopping_bag_outlined,
                title: 'Đơn mua',
                onTap: () => _showSnackBar(context, 'Chức năng Đơn mua sắp có!'),
              ),
              _menuTile(
                context,
                icon: Icons.campaign_outlined,
                title: 'Thông báo',
                onTap: () => _showSnackBar(context, 'Chức năng Thông báo sắp có!'),
              ),
              _menuTile(
                context,
                icon: Icons.card_giftcard_outlined,
                title: 'Voucher',
                onTap: () => _showSnackBar(context, 'Chức năng Voucher sắp có!'),
              ),
              _menuTile(
                context,
                icon: Icons.store_mall_directory_outlined,
                title: 'Quản lý shop',
                onTap: () => _showSnackBar(context, 'Chức năng Quản lý shop sắp có!'),
              ),

              const SizedBox(height: 16),

              // ──────────────────── ĐĂNG XUẤT ────────────────────
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await auth.logout();
                  if (auth.user == null) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    _showSnackBar(context, auth.errorMessage ?? 'Đăng xuất thất bại', isError: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}