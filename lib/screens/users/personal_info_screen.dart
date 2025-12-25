// lib/screens/personal_info_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'edit_personal_info_screen.dart';

// Import màn hình Shop
import '../shops/shop_register_screen.dart';
import '../shops/shop_management_screen.dart';

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

  // Hàm tải thông tin User
  Future<void> _loadProfile(AuthProvider auth, UserProvider userProvider, {bool forceRefresh = false}) async {
    // Nếu forceRefresh = true, bỏ qua kiểm tra _hasFetched để tải lại từ đầu
    if (_hasFetched && !forceRefresh) return;
    _hasFetched = true;

    // await Future.delayed(const Duration(milliseconds: 400)); // Có thể bỏ delay này nếu không cần thiết

    if (auth.accessToken != null) {
      try {
        // Luôn fetch lại mới nhất để cập nhật trạng thái Shop/Role
        await userProvider.fetchMe();
      } catch (e) {
        if (mounted) _showSnackBar(context, 'Không tải được hồ sơ: $e', isError: true);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

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
                    label,
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
        // Load profile lần đầu
        if (!_hasFetched) {
          _loadProfile(auth, userProvider);
        }

        final currentUser = userProvider.me ?? auth.user;

        // ============================================================
        // [QUAN TRỌNG] LOGIC KIỂM TRA ĐÃ CÓ SHOP HAY CHƯA
        // ============================================================
        bool hasShop = false;

        if (currentUser != null) {
          // Cách 1: Kiểm tra Role (Thường dùng nhất)
          // Giả sử backend trả về role là 'SELLER' hoặc 'ADMIN' thì là có shop
          if (currentUser.role == 'SELLER' || currentUser.role == 'ADMIN') {
            hasShop = true;
          }

          // Cách 2: Kiểm tra shopId (Nếu model user có trường shopId)
          // if (currentUser.shopId != null && currentUser.shopId!.isNotEmpty) {
          //   hasShop = true;
          // }
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
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
              : RefreshIndicator(
            // Cho phép kéo xuống để tải lại profile (cập nhật trạng thái user -> seller)
            onRefresh: () async {
              await _loadProfile(auth, userProvider, forceRefresh: true);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // 1. Header Avatar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Row(
                      children: [
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
                                  // Nếu là Seller thì hiện tick xanh
                                  if (hasShop)
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
                              // Badge hiển thị vai trò
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: hasShop ? Colors.orange[50] : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  hasShop ? 'NHÀ BÁN HÀNG' : 'KHÁCH HÀNG',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: hasShop ? Colors.orange : Colors.blue,
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

                  // 2. Thông tin cá nhân
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
                                : 'Khác',
                          ),
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
                  // 3. NÚT ĐIỀU HƯỚNG SHOP (DYNAMIC)
                  // ============================================
                  Container(
                    width: double.infinity,
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (hasShop) {
                            // --- ĐÃ CÓ SHOP (SELLER) ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopManagementScreen(),
                              ),
                            );
                          } else {
                            // --- CHƯA CÓ SHOP (USER) ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopRegisterScreen(),
                              ),
                            ).then((_) {
                              // [QUAN TRỌNG] Khi quay lại từ trang đăng ký, tải lại profile
                              // để kiểm tra xem đã thành Seller chưa.
                              _loadProfile(auth, userProvider, forceRefresh: true);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Icon: Đổi icon tùy trạng thái
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: hasShop ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  hasShop ? Icons.store_mall_directory : Icons.add_business,
                                  color: hasShop ? const Color(0xFF0D6EFD) : Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Text: Đổi nội dung tùy trạng thái
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasShop ? 'Quản lý Shop' : 'Đăng ký Shop',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasShop
                                          ? 'Quản lý sản phẩm, đơn hàng và doanh thu'
                                          : 'Bắt đầu kinh doanh ngay hôm nay',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow icon
                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}