class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? birthday;
  final String? gender;
  final String? role;
  final bool? isVerified;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.birthday,
    this.gender,
    this.role,
    this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthday: json['birthday'],
      gender: json['gender'],
      role: json['role'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}