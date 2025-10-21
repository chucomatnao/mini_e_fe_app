// File chứa các hằng số chung như URL và endpoint để dễ quản lý
class AppConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String registerEndpoint = '/api/auth/register'; // Endpoint đăng ký
  static const String loginEndpoint = '/api/auth/login'; // Endpoint đăng nhập
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password'; // Endpoint quên mật khẩu
  static const String logoutEndpoint = '/api/auth/logout'; // Endpoint đăng xuất
  static const String requestVerifyEndpoint = '/api/auth/request-verify'; // Endpoint yêu cầu OTP
  static const String verifyAccountEndpoint = '/api/auth/verify-account'; // Endpoint xác minh OTP
  static const String resetPasswordEndpoint = '/api/auth/reset-password';
}