# Mini E-Commerce Frontend App - Cấu Trúc Dự Án

## 📋 Tổng Quan
**Mini E-Commerce Frontend** là một ứng dụng mobile/web Flutter cho phép người dùng mua bán sản phẩm, quản lý cửa hàng, và xử lý thanh toán. Ứng dụng hỗ trợ ba vai trò: **Khách hàng (User)**, **Người bán (Seller)**, **Quản trị viên (Admin)**.

---

## 📁 Cấu Trúc Thư Mục Hiện Tại

```
mini_e_fe_app/
├── lib/                               # Source code chính
│   ├── main.dart                      # Điểm vào ứng dụng (MaterialApp, Routes, MultiProvider)
│   ├── models/                        # Lớp mô hình dữ liệu (Data Models)
│   │   ├── address_model.dart         # Mô hình địa chỉ giao hàng
│   │   ├── cart_model.dart            # Mô hình giỏ hàng & items
│   │   ├── category_model.dart        # Mô hình danh mục sản phẩm
│   │   ├── order_model.dart           # Mô hình đơn hàng
│   │   ├── product_model.dart         # Mô hình sản phẩm (images, variants, options)
│   │   ├── review_model.dart          # Mô hình đánh giá sản phẩm
│   │   ├── shop_model.dart            # Mô hình cửa hàng
│   │   ├── user_model.dart            # Mô hình người dùng (USER/SELLER/ADMIN)
│   │   └── vietnam_units.dart         # Danh sách tỉnh/quận/phường Việt Nam
│   ├── providers/                     # State Management (Provider Pattern - ChangeNotifier)
│   │   ├── address_provider.dart      # Quản lý danh sách địa chỉ (CRUD)
│   │   ├── auth_provider.dart         # Xác thực (login, register, logout, token)
│   │   ├── cart_provider.dart         # Giỏ hàng (add, update, remove, checkout)
│   │   ├── category_provider.dart     # Danh mục sản phẩm
│   │   ├── order_provider.dart        # Đơn hàng (create, fetch, update status)
│   │   ├── product_provider.dart      # Sản phẩm (fetch, create, edit, variants)
│   │   ├── review_provider.dart       # Đánh giá sản phẩm (create, fetch)
│   │   ├── shop_provider.dart         # Cửa hàng (register, update, approve)
│   │   └── user_provider.dart         # Thông tin người dùng (fetch, update profile)
│   ├── screens/                       # Giao diện người dùng (UI Screens)
│   │   ├── auths/                     # Màn hình xác thực
│   │   │   ├── login_screen.dart      # Đăng nhập
│   │   │   ├── register_screen.dart   # Đăng ký
│   │   │   ├── forgot_password_screen.dart    # Quên mật khẩu
│   │   │   ├── reset_otp_screen.dart  # Reset password với OTP
│   │   │   ├── verify_account_screen.dart     # Xác minh email
│   │   │   └── logout_screen.dart     # Xác nhận logout
│   │   ├── products/                  # Quản lý sản phẩm (Seller)
│   │   │   ├── add_product_screen.dart        # Tạo sản phẩm mới
│   │   │   ├── edit_product_screen.dart       # Chỉnh sửa sản phẩm
│   │   │   ├── add_variant_screen.dart        # Thêm biến thể (Màu, Size)
│   │   │   └── product_detail_screen.dart     # Chi tiết sản phẩm + chọn variant
│   │   ├── shops/                     # Quản lý cửa hàng
│   │   │   ├── shop_register_screen.dart      # Đăng ký cửa hàng
│   │   │   ├── shop_management_screen.dart    # Quản lý cửa hàng (thông tin + sản phẩm)
│   │   │   ├── seller_product_list_screen.dart # Danh sách sản phẩm của shop
│   │   │   ├── shop_list_screen.dart  # Danh sách tất cả cửa hàng (khách xem)
│   │   │   └── shop_detail_screen.dart # Chi tiết cửa hàng & sản phẩm
│   │   ├── carts/                     # Giỏ hàng
│   │   │   └── cart_screen.dart       # Xem & quản lý giỏ hàng
│   │   ├── orders_payments/           # Đơn hàng & thanh toán
│   │   │   ├── checkout_screen.dart   # Kiểm tra đơn hàng trước thanh toán
│   │   │   ├── my_orders_screen.dart  # Danh sách đơn hàng của user
│   │   │   ├── payment_qr_screen.dart # Hiển thị mã QR thanh toán
│   │   │   └── payment_result_screen.dart     # Kết quả thanh toán
│   │   ├── address/                   # Quản lý địa chỉ giao hàng
│   │   │   ├── address_list_screen.dart       # Danh sách địa chỉ
│   │   │   └── add_address_screen.dart        # Thêm/chỉnh sửa địa chỉ
│   │   ├── users/                     # Thông tin cá nhân
│   │   │   ├── personal_info_screen.dart      # Xem thông tin cá nhân
│   │   │   └── edit_personal_info_screen.dart # Chỉnh sửa thông tin
│   │   ├── admins/                    # Bảng điều khiển quản trị
│   │   │   ├── admin_home_screen.dart # Trang chủ admin (thống kê)
│   │   │   ├── admin_dashboard_screen.dart    # Dashboard chi tiết
│   │   │   ├── admin_shops_screen.dart # Danh sách cửa hàng (phê duyệt)
│   │   │   ├── admin_shop_approval_screen.dart # Phê duyệt cửa hàng
│   │   │   ├── admin_users_screen.dart # Danh sách người dùng
│   │   │   └── admin_user_detail_screen.dart  # Chi tiết người dùng
│   │   ├── home_screen.dart           # Trang chủ (danh sách sản phẩm, tìm kiếm)
│   │   ├── main_tab_container.dart    # Container chính (4 tabs: Home, Shop, Cart, Profile)
│   │   └── profile_screen.dart        # Thông tin & menu cá nhân
│   ├── service/                       # Dịch vụ API & logic chia sẻ
│   │   ├── api_client.dart            # Cấu hình Dio HTTP client (baseURL, interceptor, auth)
│   │   ├── auth_service.dart          # Xử lý API auth (login, register, logout, refresh token)
│   │   ├── product_service.dart       # Xử lý API sản phẩm (fetch, create, update, delete)
│   │   ├── shop_service.dart          # Xử lý API cửa hàng (register, update, fetch)
│   │   ├── cart_service.dart          # Xử lý API giỏ hàng (add, update, remove)
│   │   ├── order_service.dart         # Xử lý API đơn hàng (create, fetch, update status)
│   │   ├── address_service.dart       # Xử lý API địa chỉ (CRUD)
│   │   ├── user_service.dart          # Xử lý API thông tin user (fetch, update profile)
│   │   ├── review_service.dart        # Xử lý API đánh giá sản phẩm (create, fetch)
│   │   ├── category_service.dart      # Xử lý API danh mục sản phẩm
│   │   └── admin_service.dart         # Xử lý API admin (duyệt shop, quản lý user)
│   ├── utils/                         # Hằng số & cấu hình
│   │   └── app_constants.dart         # Base URL API, Endpoint routes
│   └── widgets/                       # Widget tái sử dụng (Custom Widgets)
│       ├── product_card.dart          # Card hiển thị sản phẩm (ảnh, tên, giá)
│       ├── review_card.dart           # Card hiển thị đánh giá sản phẩm
│       ├── custom_button.dart         # Button tuỳ chỉnh (màu, độ rộng)
│       ├── loading_indicator.dart     # Indicator loading (spinner, skeleton)
│       ├── osm_location_picker.dart   # Widget chọn vị trí trên bản đồ OpenStreetMap
│       └── vietnam_address_selector.dart # Dropdown chọn tỉnh/quận/phường
├── android/                           # Code native Android (Kotlin/Java)
│   ├── app/                           # Ứng dụng Android chính
│   │   ├── build.gradle.kts           # Build config Android
│   │   └── src/                       # Source code native Android
│   ├── gradle/                        # Gradle wrapper & config
│   ├── build.gradle.kts               # Root build config
│   ├── gradlew & gradlew.bat          # Gradle scripts
│   └── local.properties               # Cấu hình SDK Android (local)
├── ios/                               # Code native iOS (Swift/Objective-C)
│   ├── Runner/                        # Ứng dụng iOS chính
│   │   ├── AppDelegate.swift          # Entry point iOS
│   │   ├── Info.plist                 # Cấu hình iOS app
│   │   ├── Assets.xcassets/           # Icon & ảnh iOS
│   │   └── GeneratedPluginRegistrant  # Plugin registrant
│   ├── Runner.xcodeproj/              # Xcode project
│   └── Runner.xcworkspace/            # Xcode workspace
├── web/                               # Code web (HTML/JavaScript)
│   ├── index.html                     # Entry HTML
│   ├── manifest.json                  # Web manifest
│   └── icons/                         # Icon web
├── build/                             # Thư mục build (generated - ignore)
│   ├── android/                       # Build output Android
│   ├── ios/                           # Build output iOS
│   ├── web/                           # Build output Web
│   └── flutter_assets/                # Assets Flutter compiled
├── test/                              # Unit & Widget tests
│   └── widget_test.dart               # Widget test mẫu
├── pubspec.yaml                       # Flutter dependencies & config
├── pubspec.lock                       # Lock file dependencies
├── analysis_options.yaml              # Lint rules
├── devtools_options.yaml              # DevTools config
├── README.md                          # Tài liệu dự án
└── .gitignore                         # Git ignore rules
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
| **api_client.dart** | Cấu hình Dio HTTP client (baseURL, interceptor, token header, error handling) |
| **auth_service.dart** | API auth: login, register, logout, refresh token, verify OTP, forgot password |
| **product_service.dart** | API sản phẩm: fetch list, fetch detail, create, update, delete, fetch variants |
| **shop_service.dart** | API cửa hàng: register, fetch detail, update info, fetch products, approve status |
| **cart_service.dart** | API giỏ hàng: fetch cart, add item, update quantity, remove item, clear cart |
| **order_service.dart** | API đơn hàng: create order, fetch orders, fetch order detail, update status, cancel |
| **address_service.dart** | API địa chỉ: fetch list, create, update, delete, set default address |
| **user_service.dart** | API user: fetch profile, update profile, upload avatar, change password |
| **review_service.dart** | API đánh giá: create review, fetch reviews, update review, delete review |
| **category_service.dart** | API danh mục: fetch categories, filter by category |
| **admin_service.dart** | API admin: fetch shops, approve/reject shop, fetch users, block/unlock user, statistics |

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

### **📋 Điều Kiện Tiên Quyết**

#### **1. Cài Đặt Flutter**
- **Flutter 3.7+**: [Tải tại đây](https://flutter.dev/docs/get-started/install)
- **Dart 3.0+**: (Tự động cài theo Flutter)
- **Git**: [Tải tại đây](https://git-scm.com/downloads)

#### **2. Cài Đặt Môi Trường Phát Triển**
**Chọn một trong các tùy chọn sau:**

**Option A: Android (Recommended)**
- Android Studio: [Tải tại đây](https://developer.android.com/studio)
- Android SDK 21+ (Target SDK 35+)
- Android Emulator hoặc Physical Device

**Option B: iOS (macOS only)**
- Xcode 12+
- CocoaPods: `sudo gem install cocoapods`

**Option C: Web (Đơn Giản Nhất)**
- Google Chrome hoặc Chromium

#### **3. Backend API**
- Backend API **PHẢI** chạy tại `http://localhost:3000/api`
- Clone backend repository và follow hướng dẫn của nó

---

### **🔧 Bước Cài Đặt Chi Tiết**

#### **Bước 1: Clone Project**
```bash
# Clone project từ repository
git clone https://github.com/your-repo/mini_e_fe_app.git
cd mini_e_fe_app
```

#### **Bước 2: Cài Đặt Dependencies**
```bash
# Tải tất cả dependencies
flutter pub get

# (Optional) Upgrade dependencies
flutter pub upgrade
```

#### **Bước 3: Kiểm Tra Cài Đặt**
```bash
# Kiểm tra toàn bộ môi trường
flutter doctor

# Output mong muốn:
# ✓ Flutter (3.7.0 trở lên)
# ✓ Dart (3.0 trở lên)
# ✓ Android Studio + SDK (nếu chạy Android)
# ✓ Xcode (nếu chạy iOS)
```

#### **Bước 4: Cấu Hình Backend URL**

**File**: `lib/utils/app_constants.dart`

```dart
class AppConstants {
  // Thay đổi tùy theo môi trường:
  
  // Nếu chạy trên Web/Physical Device:
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Nếu chạy trên Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Nếu chạy trên Physical Device (cùng mạng với backend):
  // static const String baseUrl = 'http://192.168.1.100:3000/api'; // Thay IP phù hợp
}
```

---

### **▶️ Chạy Application**

#### **1. Chạy trên Android**
```bash
# Khởi động Android Emulator trước (hoặc kết nối Physical Device)
flutter emulators --launch Pixel_4_API_31  # (tùy chọn)

# Chạy ứng dụng
flutter run

# Hoặc chạy trên device cụ thể
flutter run -d <device_id>

# Liệt kê các thiết bị có sẵn:
flutter devices
```

#### **2. Chạy trên iOS**
```bash
# Chạy trên iOS Simulator
flutter run -d simulator

# Hoặc chạy trên Physical Device
flutter run -d <device_id>
```

#### **3. Chạy trên Web**
```bash
# Chạy trên trình duyệt Chrome
flutter run -d chrome

# Hoặc Firefox
flutter run -d firefox

# Hoặc Microsoft Edge
flutter run -d edge
```

#### **4. Chạy ở Mode Development**
```bash
# Debug mode (có hot reload)
flutter run

# Release mode (tối ưu hiệu suất)
flutter run --release

# Profile mode (phân tích hiệu suất)
flutter run --profile
```

---

### **🔌 Cấu Hình Kết Nối Backend**

#### **Trường Hợp 1: Backend Chạy Cục Bộ (Localhost)**
```
Backend: http://localhost:3000/api
Frontend URL: http://localhost:3000/api  ✓
```

#### **Trường Hợp 2: Chạy trên Android Emulator**
```
Backend: http://localhost:3000/api
Frontend URL: http://10.0.2.2:3000/api  ✓
(10.0.2.2 là IP đặc biệt của host từ emulator)
```

#### **Trường Hợp 3: Chạy trên Physical Device (Cùng Mạng)**
```
Tìm IP của máy chạy backend:
- Windows: ipconfig → IPv4 Address (ví dụ: 192.168.1.100)
- Mac/Linux: ifconfig → inet addr

Frontend URL: http://192.168.1.100:3000/api  ✓
```

#### **Trường Hợp 4: Backend Đã Deploy (Cloud)**
```
Backend: https://api.example.com
Frontend URL: https://api.example.com  ✓
```

---

### **✅ Kiểm Tra Sau Khi Chạy**

1. **Ứng dụng khởi động thành công**
   - Màn hình login xuất hiện

2. **Kiểm tra kết nối backend**
   - Thử đăng ký tài khoản mới
   - Nếu không kết nối được, kiểm tra:
     - Backend có đang chạy không
     - URL trong `app_constants.dart` có chính xác không
     - Firewall/VPN có chặn port 3000 không

3. **Kiểm tra dữ liệu ảnh**
   - Ảnh sản phẩm có hiển thị không
   - Nếu không, kiểm tra backend trả đúng URL hay không

---

### **🐛 Khắc Phục Sự Cố Thường Gặp**

| Vấn Đề | Nguyên Nhân | Cách Khắc Phục |
|--------|-----------|------------------|
| **App không kết nối backend** | URL sai / Backend không chạy | Kiểm tra `app_constants.dart` + start backend |
| **Lỗi "connection refused"** | Backend chưa khởi động | Chạy backend trước: `npm start` hoặc `docker-compose up` |
| **Ảnh không hiển thị** | URL tương đối / Domain không resolve | Backend phải trả full absolute URL (Cloudinary) |
| **Lỗi "Port 3000 đang sử dụng"** | Port bị chiếm dụng | `lsof -i :3000` → kill process, hoặc đổi port |
| **Hot reload không hoạt động** | Thay đổi model/provider | Restart app: `r` + Enter trong terminal |
| **Lỗi dependencies | pubspec.yaml outdated | `flutter pub get` + `flutter pub upgrade` |
| **iOS build lỗi** | Pod files outdated | `cd ios && pod deintegrate && pod install && cd ..` |

---

### **📱 Chạy Ứng Dụng Lần Đầu - Quy Trình Đầy Đủ**

```bash
# 1. Clone project
git clone https://github.com/your-repo/mini_e_fe_app.git
cd mini_e_fe_app

# 2. Cài dependencies
flutter pub get

# 3. Kiểm tra setup
flutter doctor

# 4. Khởi động Backend (terminal khác)
cd ../mini_e_backend  # (hoặc folder backend của bạn)
npm install && npm start

# 5. Cấu hình URL (nếu cần)
# Edit: lib/utils/app_constants.dart
# - Localhost: http://localhost:3000/api
# - Android Emulator: http://10.0.2.2:3000/api
# - Physical Device: http://192.168.1.100:3000/api

# 6. Chạy app (chọn 1)
flutter run                  # Android/Web/iOS (auto-detect)
flutter run -d chrome        # Web
flutter run -d simulator     # iOS Simulator
flutter run --release        # Release mode (iOS/Android)

# 7. Đăng ký tài khoản test
# Email: test@example.com
# Password: Test@123
```

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

---

## 💻 Công Cụ & Tiện Ích Phát Triển

### **Extensions VS Code Khuyến Nghị**
- **Dart**: Built-in
- **Flutter**: Official Flutter extension
- **Pubspec Assist**: Quản lý dependencies
- **Error Lens**: Hiển thị error inline
- **Prettier**: Code formatter

### **Lệnh Thường Dùng**
```bash
# Kiểm tra lỗi
flutter analyze

# Format code
flutter format lib/

# Chạy test
flutter test

# Tạo icon app
flutter pub run flutter_launcher_icons:main

# Tạo splash screen
flutter pub run flutter_native_splash:create

# Build APK (Android)
flutter build apk --release

# Build AAB (Android App Bundle)
flutter build appbundle --release

# Build IPA (iOS)
flutter build ios --release

# Build Web
flutter build web --release
```

---



**Cập nhật lần cuối**: 27/12/2025
