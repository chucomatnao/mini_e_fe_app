import 'dart:convert';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? birthday;
  final String? gender; // 'MALE' | 'FEMALE' | 'OTHER'
  final String? role; // 'USER' | 'ADMIN'
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.birthday,
    this.gender,
    this.role,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // ════════════════════════════════════════════════════════════════════════
  //                          FROM JSON
  // ════════════════════════════════════════════════════════════════════════
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      birthday: json['birthday']?.toString(),
      gender: json['gender']?.toString(),
      role: json['role']?.toString(),
      isVerified: json['isVerified'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.tryParse(json['deletedAt']) : null,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          TO JSON
  // ════════════════════════════════════════════════════════════════════════
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthday': birthday,
      'gender': gender,
      'role': role,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          THÊM: STATIC LISTFROM (SỬA LỖI)
  // ════════════════════════════════════════════════════════════════════════
  /// Parse List<dynamic> → List<UserModel>
  static List<UserModel> listFrom(dynamic jsonList) {
    if (jsonList is! List) return <UserModel>[];
    return jsonList
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ════════════════════════════════════════════════════════════════════════
  //                          COPY WITH (TIỆN CHO UPDATE)
  // ════════════════════════════════════════════════════════════════════════
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthday,
    String? gender,
    String? role,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}