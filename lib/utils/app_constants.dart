// File chứa các hằng số chung như URL và endpoint để dễ quản lý
class AppConstants {
  static const String baseUrl = 'http://localhost:3000'; // URL của backend NestJS, thay đổi nếu deploy
  static const String registerEndpoint = '/auth/register'; // Endpoint đăng ký
  static const String loginEndpoint = '/auth/login'; // Endpoint đăng nhập
  static const String forgotPasswordEndpoint = '/auth/forgot-password'; // Endpoint quên mật khẩu
}