class AppConstants {
  static const String baseUrl = 'http://localhost:3000/api';

  // AUTH
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String requestVerifyEndpoint = '/auth/request-verify';
  static const String verifyAccountEndpoint = '/auth/verify-account';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // USER – CÓ /api
  static const String updateUserEndpoint = '/api/users'; // PATCH /api/users/:id
  static const String getCurrentUserEndpoint = '/api/users/me'; // GET (nếu có)
}
// ========== USERS API ==========
class UsersApi {
  static const String _api = '/api';
  static const String users = '$_api/users';
  static const String me = '$_api/users/me';
  static const String deletedAll = '$_api/users/deleted/all';

  static String byId(String id) => '$_api/users/$id';
  static String restore(String id) => '$_api/users/$id/restore';
  static String hardDelete(String id) => '$_api/users/$id/hard';
}
