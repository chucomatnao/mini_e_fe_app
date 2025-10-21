class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final bool? isVerified;  // Đảm bảo type bool

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.isVerified,
  });

  // SỬA: PARSE JSON ĐÚNG CẤU TRÚC BACKEND
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG: fromJson raw: $json');  // Log để debug

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      // SỬA: LẤY isVerified TỪ ĐÚNG VỊ TRÍ
      isVerified: json['isVerified'] ?? false,  // Từ user object
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
    };
  }
}