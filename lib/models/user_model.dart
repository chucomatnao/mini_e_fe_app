// File chứa model cho dữ liệu người dùng từ API
class UserModel {
  final String id;
  final String name; // Tên người dùng từ register DTO
  final String email;
  final String role; // Vai trò người dùng (từ backend)
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  // Hàm chuyển từ JSON sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json; // Xử lý trường hợp backend trả {success: true, data: user}
    return UserModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'USER',
      isVerified: data['isVerified'] ?? false,
    );
  }
}