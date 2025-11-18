// lib/screens/admins/admin_users_screen.dart

import 'package:flutter/material.dart';
import '../../service/api_client.dart';
import '../../utils/app_constants.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> allUsers = []; // dữ liệu gốc trả về từ API cho trang hiện tại
  List<dynamic> users = []; // dữ liệu hiển thị (sau lọc client-side)
  bool isLoading = true;
  bool showDeleted = false;
  String searchQuery = '';

  // phân trang
  int page = 1;
  int limit = 20;
  int total = 0;
  int pageCount = 1;

  // bộ lọc role (client-side)
  String selectedRole = 'ALL'; // ALL / ADMIN / SELLER / USER

  // trạng thái đang thao tác trên 1 user (để disable nút khi thao tác)
  Set<int> busyUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final api = ApiClient();
      final endpoint = showDeleted ? UsersApi.deletedAll : UsersApi.users;

      final response = await api.get(
        endpoint,
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (searchQuery.isNotEmpty) 'search': searchQuery,
          // NOTE: chúng ta không gửi role => lọc client-side
        },
      );

      final data = response.data['data'];
      final items = data['items'] as List<dynamic>? ?? [];
      final meta = data['meta'] as Map<String, dynamic>? ?? {};

      setState(() {
        allUsers = items;
        total = meta['total'] ?? 0;
        pageCount = meta['pageCount'] ?? 1;
        // áp dụng lọc client-side theo role
        _applyRoleFilter();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applyRoleFilter() {
    if (selectedRole == 'ALL') {
      users = List.from(allUsers);
    } else {
      users = allUsers.where((u) => (u['role'] ?? '').toString() == selectedRole).toList();
    }
  }

  Future<void> _changeRole(int userId, String newRole) async {
    setState(() => busyUserIds.add(userId));
    try {
      await ApiClient().patch(
        UsersApi.byId(userId.toString()),
        data: {'role': newRole},
      );
      // cập nhật local (nếu user có trong allUsers)
      final idx = allUsers.indexWhere((e) => e['id'] == userId);
      if (idx != -1) {
        allUsers[idx]['role'] = newRole;
        _applyRoleFilter();
      } else {
        // reload nếu không tìm thấy
        await _loadUsers();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi vai trò thành $newRole'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đổi vai trò: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => busyUserIds.remove(userId));
    }
  }

  Future<void> _toggleBlock(int userId, bool currentlyDeleted) async {
    setState(() => busyUserIds.add(userId));
    try {
      if (currentlyDeleted) {
        await ApiClient().post(UsersApi.restore(userId.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã mở khóa tài khoản'), backgroundColor: Colors.green),
        );
      } else {
        await ApiClient().delete(UsersApi.byId(userId.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã khóa tài khoản'), backgroundColor: Colors.orange),
        );
      }
      // refresh lại trang hiện tại
      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => busyUserIds.remove(userId));
    }
  }

  void _onSearchSubmitted(String value) {
    searchQuery = value.trim();
    page = 1;
    _loadUsers();
  }

  void _onRoleChanged(String? newRole) {
    if (newRole == null) return;
    setState(() {
      selectedRole = newRole;
      _applyRoleFilter();
    });
  }

  void _goToDetail(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminUserDetailScreen(userId: userId)),
    ).then((_) {
      // khi quay về có thể refresh
      _loadUsers();
    });
  }

  void _prevPage() {
    if (page > 1) {
      setState(() => page -= 1);
      _loadUsers();
    }
  }

  void _nextPage() {
    if (page < pageCount) {
      setState(() => page += 1);
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(showDeleted ? Icons.lock_open : Icons.lock),
            color: Colors.white,
            tooltip: showDeleted ? 'Đang xem tài khoản đã khóa' : 'Xem tài khoản đã khóa',
            onPressed: () {
              setState(() {
                showDeleted = !showDeleted;
                page = 1;
              });
              _loadUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Role filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Search box expanded
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm tên, email, số điện thoại...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onSubmitted: _onSearchSubmitted,
                  ),
                ),

                const SizedBox(width: 12),

                // Role filter dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
                      DropdownMenuItem(value: 'USER', child: Text('USER')),
                      DropdownMenuItem(value: 'SELLER', child: Text('SELLER')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    ],
                    onChanged: _onRoleChanged,
                  ),
                ),
              ],
            ),
          ),

          // List / loading / empty
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : users.isEmpty
                ? Center(
              child: Text(
                showDeleted ? 'Không có tài khoản nào bị khóa' : 'Chưa có người dùng nào',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                final int uid = u['id'] as int;
                final bool isDeleted = u['deletedAt'] != null;
                final busy = busyUserIds.contains(uid);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: isDeleted ? Colors.grey[200] : null,
                  child: ListTile(
                    onTap: () => _goToDetail(uid),
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        (u['name'] != null && u['name'].toString().isNotEmpty)
                            ? u['name'][0].toString().toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(u['name'] ?? '---', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['email'] ?? ''),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                u['role'] ?? '',
                                style: TextStyle(
                                  color: u['role'] == 'ADMIN'
                                      ? Colors.deepPurple
                                      : u['role'] == 'SELLER'
                                      ? Colors.green
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.grey[200],
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
                            if (isDeleted)
                              Chip(
                                label: const Text('ĐÃ KHÓA', style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Quick lock/unlock icon
                          IconButton(
                            icon: busy
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Icon(isDeleted ? Icons.lock_open : Icons.lock),
                            color: isDeleted ? Colors.green : Colors.red,
                            tooltip: isDeleted ? 'Mở khóa' : 'Khóa',
                            onPressed: busy ? null : () => _toggleBlock(uid, isDeleted),
                          ),

                          // Change role menu (small)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'DETAIL') {
                                _goToDetail(uid);
                              } else if (value == 'ADMIN' || value == 'SELLER' || value == 'USER') {
                                await _changeRole(uid, value);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'DETAIL', child: Text('Xem chi tiết')),
                              const PopupMenuDivider(),
                              const PopupMenuItem(value: 'ADMIN', child: Text('Đặt làm ADMIN')),
                              const PopupMenuItem(value: 'SELLER', child: Text('Đặt làm SELLER')),
                              const PopupMenuItem(value: 'USER', child: Text('Đặt làm USER')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Pagination controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Text('Tổng: $total', style: const TextStyle(fontSize: 14)),
                const Spacer(),
                IconButton(
                  onPressed: page > 1 && !isLoading ? _prevPage : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Trang $page / $pageCount'),
                IconButton(
                  onPressed: page < pageCount && !isLoading ? _nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                ),
                const SizedBox(width: 8),
                // Dropdown chọn limit
                DropdownButton<int>(
                  value: limit,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10')),
                    DropdownMenuItem(value: 20, child: Text('20')),
                    DropdownMenuItem(value: 50, child: Text('50')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      limit = v;
                      page = 1;
                    });
                    _loadUsers();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
