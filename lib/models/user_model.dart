class UserModel {
  final String id;
  final String username;
  final String email;
  final bool isVerified;

  UserModel({required this.id, required this.username, required this.email, required this.isVerified});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}