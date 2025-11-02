// utils/app_constants.dart
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
}

// USERS API – KHÔNG có /api vì baseUrl đã có
class UsersApi {
  static const String users = '/users';
  static const String me = '/users/me';
  static const String deletedAll = '/users/deleted/all';

  static String byId(String id) => '/users/$id';
  static String restore(String id) => '/users/$id/restore';
  static String hardDelete(String id) => '/users/$id/hard';
}