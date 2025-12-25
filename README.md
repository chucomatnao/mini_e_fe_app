# Mini E-Commerce Frontend App - Cấu Trúc Dự Án

## 📋 Tổng Quan
**Mini E-Commerce Frontend** là một ứng dụng mobile/web Flutter cho phép người dùng mua bán sản phẩm, quản lý cửa hàng, và xử lý thanh toán. Ứng dụng hỗ trợ ba vai trò: **Khách hàng (User)**, **Người bán (Seller)**, **Quản trị viên (Admin)**.

---

## 📁 Cấu Trúc Thư Mục Chi Tiết

```
lib/
├── main.dart                          # Điểm vào của ứng dụng (app initialization, routes, providers)
├── models/                            # Lớp mô hình dữ liệu (Model)
├── providers/                         # State management (Provider pattern)
├── screens/                           # Giao diện người dùng (UI Screens)
├── service/                           # Dịch vụ API và xử lý logic chia sẻ
├── utils/                             # Hằng số, config, helper functions
└── widgets/                           # Widget tái sử dụng (Custom Widget)
```

---

## 📦 Chi Tiết Từng Thư Mục

### **1. `lib/main.dart`**
- **Chức năng**: Điểm vào chính của ứng dụng
- **Nội dung**:
  - Import tất cả Provider (Auth, Product, Shop, Cart, Order, Address, User)
  - Cấu hình routes (named routes `/login`, `/home`, `/product-detail`, `/cart`, v.v.)
  - Setup MultiProvider để quản lý state toàn app
  - Khởi tạo Material App với theme và navigation
  - Xử lý persistent login (kiểm tra token từ SharedPreferences)

---

### **2. `lib/models/` - Lớp Mô Hình Dữ Liệu**

| File | Chức Năng |
|------|----------|
| **product_model.dart** | Mô hình sản phẩm: `id, title, price, imageUrl, images[], optionSchema[], variants[]` |
| **shop_model.dart** | Mô hình cửa hàng: `id, name, description, logoUrl, coverUrl, owner` |
| **user_model.dart** | Mô hình người dùng: `id, email, name, phone, avatar, role (USER/SELLER/ADMIN)` |
| **cart_model.dart** | Mô hình giỏ hàng: `id, userId, items[], totalPrice` |
| **order_model.dart** | Mô hình đơn hàng: `id, userId, items[], status, paymentStatus, address, totalPrice` |
| **address_model.dart** | Mô hình địa chỉ: `id, userId, recipientName, phone, address, ward, district, province` |
| **review_model.dart** | Mô hình đánh giá sản phẩm: `id, productId, userId, rating, comment, createdAt` |
| **vietnam_units.dart** | Danh sách tỉnh/thành phố, quận/huyện, phường/xã của Việt Nam (để chọn địa chỉ) |

**Lưu ý chiếu trọng**:
- Mỗi Model có factory method `fromJson()` để parse JSON từ backend
- `ProductModel` có logic chọn ảnh đại diện (`imageUrl`) từ danh sách `images[]`
- `VariantItem` (lớp con trong ProductModel) mô hình biến thể sản phẩm (Màu, Size, v.v.)

---

### **3. `lib/providers/` - State Management**

| File | Chức Năng |
|------|----------|
| **auth_provider.dart** | Quản lý xác thực (login, register, logout, token, current user) |
| **product_provider.dart** | Quản lý danh sách & chi tiết sản phẩm (fetch, create, update, delete, variant management) |
| **shop_provider.dart** | Quản lý cửa hàng của user (register, fetch detail, update, approve) |
| **cart_provider.dart** | Quản lý giỏ hàng (add item, update quantity, remove, checkout) |
| **order_provider.dart** | Quản lý đơn hàng (create, fetch list, detail, update status) |
| **address_provider.dart** | Quản lý danh sách địa chỉ giao hàng |
| **user_provider.dart** | Quản lý thông tin người dùng (fetch, update profile) |
| **review_provider.dart** | Quản lý đánh giá sản phẩm |

**Đặc điểm**:
- Mỗi Provider extends `ChangeNotifier`
- Gọi API thông qua `Dio` HTTP client
- Lưu dữ liệu cục bộ + thông báo cho UI khi có thay đổi (`.notifyListeners()`)
- Xử lý error và token expiration

---

### **4. `lib/screens/` - Giao Diện Người Dùng**

#### **4.1 Màn Hình Chung**
| File | Chức Năng |
|------|----------|
| **home_screen.dart** | Trang chủ: danh sách sản phẩm, tìm kiếm, filter |
| **main_tab_container.dart** | Container chính (Navigation bar) với 4 tab: Home, Shop, Cart, Profile |
| **profile_screen.dart** | Thông tin cá nhân user, logout, link tới cấu hình chi tiết |

#### **4.2 `auths/` - Xác Thực**
| File | Chức Năng |
|------|----------|
| **login_screen.dart** | Đăng nhập bằng email + password |
| **register_screen.dart** | Đăng ký tài khoản mới |
| **forgot_password_screen.dart** | Yêu cầu reset password (nhập email) |
| **reset_otp_screen.dart** | Nhập OTP và password mới |
| **verify_account_screen.dart** | Xác minh email sau đăng ký |
| **logout_screen.dart** | Xác nhận + thực hiện logout |

#### **4.3 `products/` - Quản Lý Sản Phẩm (Seller)**
| File | Chức Năng |
|------|----------|
| **add_product_screen.dart** | Tạo sản phẩm mới: chọn ảnh, nhập thông tin (title, price, description) |
| **edit_product_screen.dart** | Chỉnh sửa sản phẩm hiện tại |
| **add_variant_screen.dart** | Thêm biến thể (Màu, Size, v.v.) cho sản phẩm |
| **product_detail_screen.dart** | Chi tiết sản phẩm: carousel ảnh, giá, tồn kho, chọn biến thể, thêm vào giỏ |

**Lưu ý**: khi tạo sản phẩm → chuyển sang `add_variant_screen` để thêm biến thể.

#### **4.4 `shops/` - Quản Lý Cửa Hàng**
| File | Chức Năng |
|------|----------|
| **shop_register_screen.dart** | Đăng ký mở cửa hàng mới (nhập tên, mô tả, logo, cover) |
| **shop_management_screen.dart** | Quản lý cửa hàng: cập nhật thông tin, xem danh sách sản phẩm |
| **seller_product_list_screen.dart** | Danh sách sản phẩm của shop hiện tại (chỉnh sửa, xóa, bật/tắt hiển thị) |
| **shop_list_screen.dart** | Danh sách tất cả cửa hàng (khách hàng xem) |
| **shop_detail_screen.dart** | Chi tiết cửa hàng (logo, cover, mô tả, danh sách sản phẩm của shop) |

#### **4.5 `carts/` - Giỏ Hàng**
| File | Chức Năng |
|------|----------|
| **cart_screen.dart** | Xem giỏ hàng: danh sách items, số lượng, tổng tiền, checkout |

#### **4.6 `oders_payments/` - Đơn Hàng & Thanh Toán**
| File | Chức Năng |
|------|----------|
| **checkout_screen.dart** | Kiểm tra đơn hàng trước khi thanh toán: địa chỉ giao, phương thức thanh toán |
| **my_orders_screen.dart** | Danh sách đơn hàng của user (đang xử lý, đã giao, hủy) |
| **payment_qr_screen.dart** | Hiển thị mã QR / thông tin thanh toán |
| **payment_result_screen.dart** | Kết quả thanh toán (thành công / thất bại) |

#### **4.7 `address/` - Quản Lý Địa Chỉ**
| File | Chức Năng |
|------|----------|
| **address_list_screen.dart** | Danh sách địa chỉ giao hàng (chỉnh sửa, xóa, đặt mặc định) |
| **add_address_screen.dart** | Thêm/chỉnh sửa địa chỉ: chọn tỉnh/quận/phường, nhập tên người, SĐT |

#### **4.8 `users/` - Quản Lý Thông Tin Cá Nhân**
| File | Chức Năng |
|------|----------|
| **personal_info_screen.dart** | Xem thông tin cá nhân (email, tên, avatar) |
| **edit_personal_info_screen.dart** | Chỉnh sửa thông tin (tên, avatar, SĐT) |

#### **4.9 `admins/` - Bảng Điều Khiển Quản Trị**
| File | Chức Năng |
|------|----------|
| **admin_home_screen.dart** | Trang chủ admin: tổng quan thống kê |
| **admin_dashboard_screen.dart** | Dashboard chi tiết (doanh thu, user, đơn hàng) |
| **admin_shops_screen.dart** | Danh sách cửa hàng (duyệt duyệt, phê duyệt) |
| **admin_shop_approval_screen.dart** | Màn hình phê duyệt/từ chối cửa hàng mới |
| **admin_users_screen.dart** | Danh sách người dùng (block, unlock) |
| **admin_user_detail_screen.dart** | Chi tiết người dùng (thông tin, lịch sử đơn hàng) |

---

### **5. `lib/service/` - Dịch Vụ API & Logic Chia Sẻ**

| File | Chức Năng |
|------|----------|
| **api_client.dart** | Cấu hình `Dio` HTTP client, base URL, interceptor (token, error handling) |
| **shop_service.dart** | Logic dùng chung cho cửa hàng (validation, utility functions) |

---

### **6. `lib/utils/` - Hằng Số & Cấu Hình**

| File | Chức Năng |
|------|----------|
| **app_constants.dart** | Định nghĩa base URL API, các endpoint routes (AuthApi, ProductApi, ShopApi, OrderApi, v.v.) |

**Ví dụ**:
```dart
class AppConstants {
  static const String baseUrl = 'http://localhost:3000/api';  // Thay 10.0.2.2 nếu dùng Android emulator
}
class ProductApi {
  static const String products = '/products';
  static String byId(int id) => '/products/$id';
  static String variants(int productId) => '/products/$productId/variants';
}
```

---

### **7. `lib/widgets/` - Widget Tái Sử Dụng (Custom Widget)**

| File | Chức Năng |
|------|----------|
| **product_card.dart** | Card hiển thị sản phẩm (ảnh, tên, giá, tồn kho) - dùng trong danh sách |
| **review_card.dart** | Card hiển thị đánh giá sản phẩm (rating, comment, user) |
| **custom_button.dart** | Button tuỳ chỉnh (màu, độ rộng, font) |
| **loading_indicator.dart** | Indicator loading (spinner, skeleton) |
| **osm_location_picker.dart** | Widget chọn vị trí trên bản đồ OpenStreetMap (dùng cho địa chỉ) |
| **vietnam_address_selector.dart** | Dropdown chọn tỉnh/quận/phường Việt Nam |

---

## 🔑 Luồng Chính (Key Flows)

### **1. Đăng Ký & Đăng Nhập**
```
RegisterScreen → AuthProvider.register() → API → Local token save → navigate /home
LoginScreen → AuthProvider.login() → API → Local token save → navigate /home
```

### **2. Tạo Sản Phẩm (Seller)**
```
AddProductScreen (chọn ảnh + nhập info)
  → ProductProvider.createProduct(images, title, price, ...)
  → Backend upload ảnh (Cloudinary) + lưu DB
  → Response trả ProductModel (với images URLs)
  → Chuyển AddVariantScreen
  → ProductProvider.createVariant()
  → Backend tạo biến thể
  → SellerProductListScreen (refresh danh sách)
```

### **3. Mua Sản Phẩm (Customer)**
```
HomeScreen (duyệt sản phẩm)
  → ProductDetailScreen (chọn biến thể, số lượng)
  → CartProvider.addToCart()
  → CartScreen (xem giỏ)
  → CheckoutScreen (chọn địa chỉ, thanh toán)
  → OrderProvider.createOrder()
  → PaymentQRScreen (thanh toán)
  → PaymentResultScreen (kết quả)
```

---

## 🛠️ Công Nghệ & Thư Viện

| Thư Viện | Phiên Bản | Dùng Cho |
|----------|-----------|---------|
| flutter | 3.7+ | Framework chính |
| provider | 6.1+ | State management |
| dio | 5.9+ | HTTP requests |
| cached_network_image | 3.3+ | Hiển thị & cache ảnh |
| image_picker | 1.1+ | Chọn ảnh từ device |
| shared_preferences | 2.3+ | Lưu token locally |
| flutter_map | 6.1+ | Bản đồ OpenStreetMap |
| intl | 0.19+ | Định dạng ngày/tiền tệ |

---

## 🚀 Hướng Dẫn Chạy

### **Điều Kiện Tiên Quyết**
- Flutter 3.7+
- Dart 3.0+
- Android SDK hoặc Xcode (iOS)
- Backend API chạy trên `http://localhost:3000/api` (hoặc cấu hình lại `AppConstants.baseUrl`)

### **Cài Đặt & Chạy**
```bash
# Clone project
git clone <repo>
cd mini_e_fe_app

# Cài dependencies
flutter pub get

# Chạy app (Android)
flutter run

# Chạy app (iOS)
flutter run -d <device_id>

# Chạy app (Web)
flutter run -d chrome
```

### **Lưu Ý Emulator**
- **Android Emulator**: Thay `AppConstants.baseUrl` thành `http://10.0.2.2:3000/api`
- **iOS Simulator**: `localhost` works
- **Physical Device**: Dùng IP máy dev (ví dụ `http://192.168.1.100:3000/api`)

---

## 📱 Các Vai Trò & Quyền Hạn

### **USER (Khách Hàng)**
- Xem danh sách sản phẩm, chi tiết sản phẩm
- Thêm vào giỏ hàng, checkout, thanh toán
- Xem đơn hàng của mình
- Đánh giá sản phẩm
- Quản lý địa chỉ giao hàng

### **SELLER (Người Bán)**
- Đăng ký cửa hàng (chờ admin duyệt)
- Tạo, chỉnh sửa, xóa sản phẩm
- Thêm biến thể sản phẩm
- Xem danh sách sản phẩm của shop mình
- Quản lý thông tin cửa hàng
- Xem đơn hàng từ khách

### **ADMIN (Quản Trị Viên)**
- Dashboard: tổng quan thống kê
- Duyệt phê duyệt cửa hàng mới
- Quản lý người dùng (block/unlock)
- Xem danh sách cửa hàng, đơn hàng toàn hệ thống

---

## 🐛 Vấn Đề Phổ Biến & Xử Lý

### **Ảnh Sản Phẩm Không Hiển Thị**
1. **Nguyên nhân**: Backend trả URL tương đối hoặc domain không resolve
2. **Khắc phục**:
   - Backend đảm bảo trả full absolute URL (từ Cloudinary)
   - FE dùng `CachedNetworkImage` với `errorWidget`
   - Kiểm tra network: DNS, firewall, VPN

### **Token Hết Hạn**
1. AuthProvider tự động refresh token hoặc redirect `/login`

### **Biến Thể Không Hiển Thị**
1. Kiểm tra `OptionSchema` và `Variants` được populate từ backend

---

## 📝 Ghi Chú Quan Trọng

- **Persistent Token**: Token được lưu trong SharedPreferences và sử dụng lại sau khi restart app
- **Provider State**: Tất cả provider là singleton trong app lifetime (không bị dispose ngoài ý muốn)
- **Image Caching**: `CachedNetworkImage` tự động cache ảnh locally
- **Error Handling**: Các provider catch DioException và hiển thị thông báo user-friendly
- **Navigation**: Dùng named routes trong `main.dart` thay vì direct navigation

---

## 🔗 Các Endpoint API Chính

| Endpoint | Method | Chức Năng |
|----------|--------|----------|
| `/auth/login` | POST | Đăng nhập |
| `/auth/register` | POST | Đăng ký |
| `/products` | GET/POST | Danh sách / Tạo sản phẩm |
| `/products/:id` | GET/PATCH/DELETE | Chi tiết / Cập nhật / Xóa |
| `/products/:id/variants` | GET/POST | Danh sách / Tạo biến thể |
| `/shops` | GET | Danh sách cửa hàng |
| `/shops/register` | POST | Đăng ký cửa hàng |
| `/cart` | GET/POST | Lấy / Thêm vào giỏ |
| `/orders` | GET/POST | Danh sách / Tạo đơn hàng |
| `/addresses` | GET/POST | Danh sách / Thêm địa chỉ |

---

**Cập nhật lần cuối**: 26/12/2025
