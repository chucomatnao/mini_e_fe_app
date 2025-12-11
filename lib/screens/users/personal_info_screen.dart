// lib/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'edit_personal_info_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _hasFetched = false;

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadProfile(AuthProvider auth, UserProvider userProvider) async {
    if (_hasFetched) return;
    _hasFetched = true;

    await Future.delayed(const Duration(milliseconds: 400));

    if (auth.accessToken != null) {
      try {
        if (userProvider.me == null) {
          await userProvider.fetchMe();
        }
      } catch (e) {
        if (mounted) _showSnackBar(context, 'Không tải được hồ sơ: $e', isError: true);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  // Widget hiển thị từng dòng thông tin có Icon
  Widget _buildInfoRowWithIcon(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (value == null || value.isEmpty)
                  Text(
                    label, // Hiển thị label nếu không có value
                    style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                  )
                else ...[
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Có thể hiện label nhỏ bên dưới nếu muốn, nhưng theo hình mẫu thì chỉ hiện value
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, UserProvider>(
      builder: (context, auth, userProvider, child) {
        _loadProfile(auth, userProvider);
        final currentUser = userProvider.me ?? auth.user;

        return Scaffold(
          backgroundColor: Colors.grey[100], // Màu nền xám nhạt giống hình
          appBar: AppBar(
            title: const Text(
              'Hồ sơ của tôi',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
              },
            ),
          ),
          body: (currentUser == null)
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ============================================
                // HEADER PROFILE (Avatar + Tên ngang)
                // ============================================
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                  child: Row(
                    children: [
                      // Avatar có viền
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0D6EFD), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFF0D6EFD),
                          child: Text(
                            currentUser.name?.isNotEmpty == true
                                ? currentUser.name![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thông tin bên phải Avatar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    currentUser.name ?? 'Người dùng',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Badge xác thực (Giả lập giao diện)
                                const Icon(Icons.verified, color: Colors.blue, size: 18),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentUser.email ?? 'Chưa cập nhật email',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Badge "Nhà bán hàng" (Giả lập visual)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'KHÁCH HÀNG', // Hoặc NHÀ BÁN HÀNG tùy logic
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================
                // CARD THÔNG TIN CÁ NHÂN
                // ============================================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header của Card + Nút chỉnh sửa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            // Nút chỉnh sửa đưa vào đây theo yêu cầu
                            SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditPersonalInfoScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 14),
                                label: const Text('Chỉnh sửa', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D6EFD),
                                  side: const BorderSide(color: Color(0xFF0D6EFD)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 10),

                        // Các dòng thông tin có Icon
                        _buildInfoRowWithIcon(
                          Icons.phone_outlined,
                          'Số điện thoại',
                          currentUser.phone,
                        ),
                        _buildInfoRowWithIcon(
                          Icons.cake_outlined,
                          'Ngày sinh',
                          currentUser.birthday,
                        ),
                        _buildInfoRowWithIcon(
                          currentUser.gender == 'FEMALE'
                              ? Icons.female
                              : currentUser.gender == 'MALE' ? Icons.male : Icons.transgender,
                          'Giới tính',
                          currentUser.gender == 'MALE'
                              ? 'Nam'
                              : currentUser.gender == 'FEMALE'
                              ? 'Nữ'
                              : currentUser.gender == 'OTHER'
                              ? 'Khác'
                              : 'Chưa cập nhật',
                        ),
                        // Giả lập dòng "Thành viên từ" nếu muốn giống hình,
                        // hoặc hiển thị ID/Username nếu không có ngày tham gia
                        _buildInfoRowWithIcon(
                          Icons.calendar_today_outlined,
                          'Tên đăng nhập',
                          currentUser.name,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================
                // CARD BẢO MẬT (Giữ chỗ cho đẹp giống hình)
                // ============================================
                // Dù chức năng chưa có trong code cũ, ta thêm UI tĩnh
                // để giống hình ảnh, nhưng không gắn sự kiện điều hướng phức tạp.
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: const Text(
                            'Bảo mật & Tài khoản',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.lock_outline, color: Colors.grey[600]),
                          title: const Text('Đổi mật khẩu', style: TextStyle(fontSize: 16)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            // Logic đổi mật khẩu hoặc thông báo tính năng đang phát triển
                            _showSnackBar(context, 'Tính năng đang phát triển');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}