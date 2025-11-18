// lib/screens/admins/admin_user_detail_screen.dart

import 'package:flutter/material.dart';
import '../../service/api_client.dart';
import '../../utils/app_constants.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final int userId;
  const AdminUserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? user;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiClient().get(UsersApi.byId(widget.userId.toString()));
      setState(() {
        user = res.data['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông tin: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleBlock() async {
    if (user == null) return;
    setState(() => busy = true);
    final isDeleted = user!['deletedAt'] != null;
    try {
      if (isDeleted) {
        await ApiClient().post(UsersApi.restore(widget.userId.toString()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã mở khóa'), backgroundColor: Colors.green));
      } else {
        await ApiClient().delete(UsersApi.byId(widget.userId.toString()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã khóa'), backgroundColor: Colors.orange));
      }
      await _loadDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : user == null
          ? const Center(child: Text('Không tìm thấy người dùng'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: user!['avatarUrl'] != null ? NetworkImage(user!['avatarUrl']) : null,
                  child: user!['avatarUrl'] == null
                      ? Text((user!['name'] ?? 'U').toString()[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user!['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(user!['email'] ?? ''),
                      const SizedBox(height: 6),
                      Chip(label: Text(user!['role'] ?? '')),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: busy ? null : _toggleBlock,
                  icon: busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(user!['deletedAt'] != null ? Icons.lock_open : Icons.lock),
                  color: user!['deletedAt'] != null ? Colors.green : Colors.red,
                  tooltip: user!['deletedAt'] != null ? 'Mở khóa' : 'Khóa',
                ),
              ],
            ),

            const SizedBox(height: 16),

            ListTile(
              title: const Text('Số điện thoại'),
              subtitle: Text(user!['phone'] ?? '-'),
            ),
            ListTile(
              title: const Text('Ngày sinh'),
              subtitle: Text(user!['birthday'] ?? '-'),
            ),
            ListTile(
              title: const Text('Giới tính'),
              subtitle: Text(user!['gender'] ?? '-'),
            ),
            ListTile(
              title: const Text('Đã xác thực email'),
              subtitle: Text((user!['isVerified'] ?? false) ? 'Có' : 'Chưa'),
            ),
            ListTile(
              title: const Text('Ngày tạo'),
              subtitle: Text(user!['createdAt'] ?? '-'),
            ),
            if (user!['deletedAt'] != null)
              ListTile(
                title: const Text('Ngày khóa'),
                subtitle: Text(user!['deletedAt'] ?? '-'),
              ),
          ],
        ),
      ),
    );
  }
}
