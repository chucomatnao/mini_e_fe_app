// lib/screens/personal_info_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
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

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '—',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
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
          appBar: AppBar(
            title: const Text('Thông tin cá nhân'),
            centerTitle: true,
            backgroundColor: const Color(0xFF0D6EFD),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ============================================
                // AVATAR SECTION
                // ============================================
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF0D6EFD),
                        child: Text(
                          currentUser.name?.isNotEmpty == true
                              ? currentUser.name![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentUser.name ?? 'Người dùng',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ============================================
                // THÔNG TIN CHI TIẾT
                // ============================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),

                        _buildInfoRow('Tên đăng nhập', currentUser.name),
                        _buildInfoRow('Email', currentUser.email),
                        _buildInfoRow('Số điện thoại', currentUser.phone),
                        _buildInfoRow('Ngày sinh', currentUser.birthday),
                        _buildInfoRow(
                          'Giới tính',
                          currentUser.gender == 'MALE'
                              ? 'Nam'
                              : currentUser.gender == 'FEMALE'
                              ? 'Nữ'
                              : currentUser.gender == 'OTHER'
                              ? 'Khác'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ============================================
                // NÚT CHỈNH SỬA
                // ============================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditPersonalInfoScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text(
                      'Chỉnh sửa thông tin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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