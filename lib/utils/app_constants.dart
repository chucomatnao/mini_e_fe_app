// File chứa các hằng số chung như URL và endpoint để dễ quản lý
class AppConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String logoutEndpoint = '/api/auth/logout'; // Thêm endpoint logout

}