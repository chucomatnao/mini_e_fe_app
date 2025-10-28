class AppConstants {
  static const String baseUrl = 'http://localhost:3000';

  // AUTH
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String requestVerifyEndpoint = '/api/auth/request-verify';
  static const String verifyAccountEndpoint = '/api/auth/verify-account';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';

  // USER – CÓ /api
  static const String updateUserEndpoint = '/api/users'; // PATCH /api/users/:id
  static const String getCurrentUserEndpoint = '/api/users/me'; // GET (nếu có)
}