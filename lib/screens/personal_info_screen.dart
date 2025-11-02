import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

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

    // 🧠 CHỜ token load xong (tránh check null quá sớm)
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
      // ⚠️ Chỉ logout nếu sau khi chờ mà vẫn không có token
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  void _showEditDialog(
      BuildContext context, String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chỉnh sửa $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nhập $title mới',
            errorText: userProvider.error,
          ),
          enabled: !userProvider.isLoading,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: userProvider.isLoading
                ? null
                : () {
              final newValue = controller.text.trim();
              if (newValue.isEmpty && title != 'Số điện thoại') {
                _showSnackBar(context, '$title không được để trống', isError: true);
                return;
              }
              onSave(newValue);
              Navigator.pop(ctx);
            },
            child: userProvider.isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, String label, String? value, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 5,
            child: Text(value ?? '—',
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Text('Sửa', style: TextStyle(color: Colors.blue, fontSize: 14)),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // AVATAR
                Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFF0872FF),
                      child: Text(
                        currentUser.name?.isNotEmpty == true
                            ? currentUser.name![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _showSnackBar(context, 'Tính năng tải ảnh sắp có!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD9D9D9)),
                        elevation: 0,
                      ),
                      child: const Text('Chọn ảnh',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // CARD
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin cá nhân',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        _infoRow(context, 'Tên đăng nhập', currentUser.name, () {
                          _showEditDialog(
                              context, 'Tên', currentUser.name ?? '', (newValue) async {
                            try {
                              await userProvider.updateProfile({'name': newValue});
                              _showSnackBar(context, 'Cập nhật tên thành công!');
                            } catch (e) {
                              _showSnackBar(context,
                                  userProvider.error ?? 'Cập nhật thất bại',
                                  isError: true);
                            }
                          });
                        }),
                        _infoRow(context, 'Email', currentUser.email,
                                () => _showSnackBar(
                                context, 'Email không thể thay đổi',
                                isError: true)),
                        _infoRow(context, 'Số điện thoại', currentUser.phone, () {
                          _showEditDialog(context, 'Số điện thoại',
                              currentUser.phone ?? '', (newValue) async {
                                try {
                                  await userProvider.updateProfile(
                                      {'phone': newValue.isEmpty ? null : newValue});
                                  _showSnackBar(context, 'Cập nhật số điện thoại thành công!');
                                } catch (e) {
                                  _showSnackBar(context,
                                      userProvider.error ?? 'Cập nhật thất bại',
                                      isError: true);
                                }
                              });
                        }),
                        _infoRow(context, 'Ngày sinh', currentUser.birthday, () {
                          showDatePicker(
                            context: context,
                            initialDate:
                            DateTime.tryParse(currentUser.birthday ?? '') ??
                                DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ).then((date) async {
                            if (date != null) {
                              final formatted =
                                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              try {
                                await userProvider
                                    .updateProfile({'birthday': formatted});
                                _showSnackBar(context, 'Cập nhật ngày sinh thành công!');
                              } catch (e) {
                                _showSnackBar(context,
                                    userProvider.error ?? 'Cập nhật thất bại',
                                    isError: true);
                              }
                            }
                          });
                        }),
                        _infoRow(context, 'Giới tính',
                            currentUser.gender == 'MALE'
                                ? 'Nam'
                                : currentUser.gender == 'FEMALE'
                                ? 'Nữ'
                                : currentUser.gender == 'OTHER'
                                ? 'Khác'
                                : null, () {
                              showModalBottomSheet(
                                context: context,
                                builder: (ctx) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children:
                                  ['MALE', 'FEMALE', 'OTHER'].map((g) {
                                    final display = g == 'MALE'
                                        ? 'Nam'
                                        : g == 'FEMALE'
                                        ? 'Nữ'
                                        : 'Khác';
                                    return ListTile(
                                      title: Text(display),
                                      onTap: () async {
                                        Navigator.pop(ctx);
                                        try {
                                          await userProvider
                                              .updateProfile({'gender': g});
                                          _showSnackBar(
                                              context, 'Cập nhật giới tính thành công!');
                                        } catch (e) {
                                          _showSnackBar(
                                              context,
                                              userProvider.error ??
                                                  'Cập nhật thất bại',
                                              isError: true);
                                        }
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
              ],
            ),
          ),
        );
      },
    );
  }
}
