// utils/app_constants.dart
class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

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

// SHOP API – MỚI THÊM (giữ nguyên cấu trúc cũ)
class ShopsApi {
  // Public
  static const String shops = '/shops';                    // GET: danh sách + query
  static const String checkName = '/shops/check-name';      // GET: ?name=...

  // Authenticated
  static const String register = '/shops/register';         // POST: đăng ký shop
  static const String myShop = '/shops/me';                 // GET: shop của mình

  // Owner / Admin
  static String byId(String id) => '/shops/$id';             // PATCH, DELETE
}

// ============================================================================
// PRODUCT API – TÁCH RIÊNG CHO DỄ QUẢN LÝ
// ============================================================================
class ProductApi {
  // Public
  static const String products = '/products';                    // GET: danh sách + query
  static const String search = '/products/search';               // GET: ?q=...

  // Authenticated
  static String byId(int id) => '/products/$id';                 // GET: chi tiết
  static String variants(int productId) => '/products/$productId/variants'; // GET: danh sách variants
  static String generateVariants(int productId) => '/products/$productId/variants/generate'; // POST
  static String variant(int productId, int variantId) => '/products/$productId/variants/$variantId'; // PATCH, DELETE
}
class CartApi {
  static const String myCart = '/cart';
  static const String items = '/cart/items';
}
// ============================================================================
// ADDRESS API
// ============================================================================
class AddressApi {
  // Base endpoint: /addresses
  static const String base = '/addresses';

  // GET: Danh sách, POST: Tạo mới
  static const String list = '/addresses';

  // PATCH: Cập nhật, DELETE: Xóa
  static String byId(int id) => '/addresses/$id';

  // PATCH: Đặt làm mặc định
  static String setDefault(int id) => '/addresses/$id/set-default';
}
// Oder API
class OrderApi {
  static const String preview = '/orders/preview'; // POST
  static const String create = '/orders';          // POST
  static const String mine = '/orders';            // GET List
  static String detail(String id) => '/orders/$id'; // GET Detail
}
// Payment API
class PaymentApi {
  // Backend trả về URL để QR, nhưng trạng thái check qua Order hoặc Session
  // Ở đây mình check status qua order detail hoặc list
}