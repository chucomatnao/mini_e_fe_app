# Cấu Trúc Dự Án Mini E-Commerce Frontend

## 📋 Tổng Quan
Đây là một ứng dụng Flutter cho nền tảng thương mại điện tử nhỏ (Mini E-Commerce) với hỗ trợ cho cả người mua và người bán.

**Ngôn ngữ**: Dart  
**Framework**: Flutter  
**State Management**: Provider  
**Supported Platforms**: Android, iOS, Web, Windows, Linux, macOS  

---

## 📁 Cấu Trúc Thư Mục Chi Tiết

### 📍 Thư Mục Gốc (Root Level)

```
mini_e_fe_app/
├── 📄 pubspec.yaml                    # File cấu hình Flutter chính
│                                       # - Khai báo dependencies (packages)
│                                       # - Assets (hình ảnh, font, dữ liệu)
│                                       # - Cấu hình tên ứng dụng
│
├── 📄 pubspec.lock                    # Lock file - version chính xác của packages
│
├── 📄 analysis_options.yaml           # Cấu hình Dart Analyzer (lint rules)
│                                       # - Kiểm tra code style
│                                       # - Cảnh báo lỗi tiềm tàng
│
├── 📄 devtools_options.yaml           # Cấu hình DevTools debugging
│
├── 📄 mini_e_fe_app.iml               # File cấu hình IDE (IntelliJ/Android Studio)
│
├── 📄 README.md                       # Tài liệu dự án, hướng dẫn setup
│
├── 📄 PROJECT_STRUCTURE.md            # File này - tài liệu cấu trúc dự án
│
├── � PROJECT_STRUCTURE.md            # File này - tài liệu cấu trúc dự án
│
├── 📂 lib/                            # ⭐ Thư mục chính chứa toàn bộ source code Dart
│   │                                   # Là nơi viết logic chính của ứng dụng
│   │
│   ├── 📄 main.dart                   # 🚀 Entry point (điểm vào) của ứng dụng
│   │                                   # - Cấu hình MaterialApp
│   │                                   # - Setup Providers toàn cục
│   │                                   # - Cấu hình routing, theme
│   │
│   ├── 📂 models/                     # 📊 Các model dữ liệu (Data Models)
│   │                                   # Định nghĩa cấu trúc dữ liệu cho app
│   │   ├── 📄 user_model.dart         # Model người dùng
│   │   │                               # - Các trường: id, username, email, phone, avatar
│   │   │                               # - Hàm: toJson(), fromJson() để chuyển đổi
│   │   │
│   │   ├── 📄 product_model.dart      # Model sản phẩm
│   │   │                               # - Các trường: id, name, description, price, image
│   │   │                               # - Trạng thái: available, out_of_stock
│   │   │
│   │   ├── 📄 cart_model.dart         # Model giỏ hàng
│   │   │                               # - Items: danh sách sản phẩm trong giỏ
│   │   │                               # - Hàm tính: tổng giá, số lượng
│   │   │
│   │   ├── 📄 order_model.dart        # Model đơn hàng
│   │   │                               # - Các trường: id, user_id, items, status, date
│   │   │                               # - Status: pending, confirmed, shipped, delivered
│   │   │
│   │   ├── 📄 shop_model.dart         # Model cửa hàng
│   │   │                               # - Các trường: id, name, owner_id, description
│   │   │                               # - Status: pending, approved, rejected
│   │   │
│   │   ├── 📄 review_model.dart       # Model đánh giá/bình luận
│   │   │                               # - Các trường: id, rating (1-5), comment, user, product
│   │   │
│   │   ├── 📄 address_model.dart      # Model địa chỉ
│   │   │                               # - Các trường: street, ward, district, province, country
│   │   │
│   │   └── 📄 vietnam_units.dart      # Dữ liệu tỉnh/thành phố Việt Nam
│   │                                   # - Danh sách tỉnh, quận/huyện, phường/xã
│   │
│   ├── 📂 providers/                  # 🔄 State Management (Provider Pattern)
│   │                                   # Quản lý trạng thái toàn cầu của ứng dụng
│   │                                   # Kết nối UI với Services
│   │   ├── 📄 auth_provider.dart      # Quản lý xác thực người dùng
│   │   │                               # - State: user info, token, is_logged_in
│   │   │                               # - Methods: login(), register(), logout(), updateProfile()
│   │   │
│   │   ├── 📄 user_provider.dart      # Quản lý dữ liệu người dùng hiện tại
│   │   │                               # - State: user profile, settings
│   │   │                               # - Methods: fetchUserInfo(), updateInfo()
│   │   │
│   │   ├── 📄 product_provider.dart   # Quản lý danh sách sản phẩm
│   │   │                               # - State: products list, filters, sort
│   │   │                               # - Methods: fetchProducts(), search(), filter()
│   │   │
│   │   ├── 📄 cart_provider.dart      # Quản lý giỏ hàng
│   │   │                               # - State: cart items, total price
│   │   │                               # - Methods: addToCart(), removeFromCart(), updateQuantity()
│   │   │
│   │   ├── 📄 order_provider.dart     # Quản lý lịch sử đơn hàng
│   │   │                               # - State: orders list, order details
│   │   │                               # - Methods: fetchOrders(), createOrder(), cancelOrder()
│   │   │
│   │   ├── 📄 shop_provider.dart      # Quản lý thông tin cửa hàng
│   │   │                               # - State: user's shop info, products list
│   │   │                               # - Methods: registerShop(), updateShop(), getMyShop()
│   │   │
│   │   ├── 📄 review_provider.dart    # Quản lý đánh giá sản phẩm
│   │   │                               # - State: reviews list, ratings
│   │   │                               # - Methods: fetchReviews(), submitReview()
│   │   │
│   │   └── 📄 address_provider.dart   # Quản lý địa chỉ giao hàng
│   │                                   # - State: addresses list, selected address
│   │                                   # - Methods: addAddress(), updateAddress(), deleteAddress()
│   │
│   ├── 📂 service/                    # 🌐 Các Service API (Backend Communication)
│   │                                   # Giao tiếp với backend API, xử lý HTTP requests
│   │   ├── 📄 api_client.dart         # HTTP Client cơ sở
│   │   │                               # - Cấu hình base URL, headers, timeout
│   │   │                               # - Xử lý request/response interceptors
│   │   │                               # - Xử lý lỗi chung
│   │   │
│   │   ├── 📄 auth_service.dart       # API xác thực
│   │   │                               # - login(email, password) → token
│   │   │                               # - register(info) → user + token
│   │   │                               # - logout() → xóa token
│   │   │                               # - forgotPassword(email) → send email reset
│   │   │
│   │   ├── 📄 user_service.dart       # API quản lý người dùng
│   │   │                               # - getProfile() → user info
│   │   │                               # - updateProfile(data) → cập nhật hồ sơ
│   │   │                               # - changePassword(old, new) → đổi mật khẩu
│   │   │
│   │   ├── 📄 product_service.dart    # API sản phẩm
│   │   │                               # - getProducts(filters) → danh sách
│   │   │                               # - searchProducts(query) → tìm kiếm
│   │   │                               # - getProductDetail(id) → chi tiết 1 sản phẩm
│   │   │
│   │   ├── 📄 cart_service.dart       # API giỏ hàng
│   │   │                               # - addToCart(product_id, quantity)
│   │   │                               # - removeFromCart(product_id)
│   │   │                               # - updateCartItem(product_id, quantity)
│   │   │
│   │   ├── 📄 order_service.dart      # API đơn hàng
│   │   │                               # - createOrder(items, address) → tạo đơn
│   │   │                               # - getOrders() → danh sách đơn hàng
│   │   │                               # - getOrderDetail(id) → chi tiết đơn hàng
│   │   │                               # - cancelOrder(id) → hủy đơn
│   │   │
│   │   ├── 📄 shop_service.dart       # API cửa hàng
│   │   │                               # - registerShop(name, description) → đăng ký
│   │   │                               # - getMyShop() → lấy cửa hàng của user
│   │   │                               # - updateShop(data) → cập nhật thông tin
│   │   │                               # - getShops() → danh sách cửa hàng
│   │   │
│   │   ├── 📄 review_service.dart     # API đánh giá
│   │   │                               # - submitReview(product_id, rating, comment)
│   │   │                               # - getProductReviews(product_id) → đánh giá của sản phẩm
│   │   │
│   │   └── 📄 address_service.dart    # API địa chỉ
│   │                                   # - getProvinces() → danh sách tỉnh
│   │                                   # - getDistricts(province_id) → danh sách quận
│   │                                   # - getWards(district_id) → danh sách phường
│   │
│   ├── 📂 screens/                    # 🖥️ Các màn hình UI (Screens)
│   │                                   # Nơi hiển thị giao diện người dùng
│   │   │
│   │   ├── 📄 main_tab_container.dart # 🏠 Màn hình container chính
│   │   │                               # - BottomNavigationBar với 4-5 tab
│   │   │                               # - Home (trang chủ)
│   │   │                               # - Cart (giỏ hàng)
│   │   │                               # - Shop (quản lý cửa hàng nếu là seller)
│   │   │                               # - Orders (đơn hàng)
│   │   │                               # - Profile (hồ sơ)
│   │   │
│   │   ├── 📄 home_screen.dart        # 🏠 Trang chủ chính
│   │   │                               # - Banner/carousel hình ảnh
│   │   │                               # - Danh sách danh mục sản phẩm
│   │   │                               # - Grid danh sách sản phẩm
│   │   │                               # - Thanh tìm kiếm
│   │   │
│   │   ├── 📄 profile_screen.dart     # 👤 Hồ sơ người dùng
│   │   │                               # - Hiển thị thông tin cá nhân
│   │   │                               # - Menu: Chỉnh sửa hồ sơ, Địa chỉ, Cài đặt, Đăng xuất
│   │   │
│   │   ├── 📄 checkout_screen.dart    # 💳 Màn hình thanh toán
│   │   │                               # - Xem lại danh sách sản phẩm
│   │   │                               # - Chọn địa chỉ giao hàng
│   │   │                               # - Chọn phương thức thanh toán
│   │   │                               # - Xác nhận và tạo đơn hàng
│   │   │
│   │   ├── 📂 auths/                  # 🔐 Màn hình xác thực/đăng nhập
│   │   │   ├── 📄 login_screen.dart           # Đăng nhập
│   │   │   │                                   # - Form email + password
│   │   │   │                                   # - Link "Quên mật khẩu" + "Đăng ký"
│   │   │   │
│   │   │   ├── 📄 register_screen.dart        # Đăng ký tài khoản
│   │   │   │                                   # - Form: email, password, name, phone
│   │   │   │                                   # - Validate input
│   │   │   │
│   │   │   ├── 📄 forgot_password_screen.dart # Quên mật khẩu
│   │   │   │                                   # - Nhập email → gửi link reset
│   │   │   │
│   │   │   ├── 📄 reset_otp_screen.dart       # Xác minh OTP/Code
│   │   │   │                                   # - Nhập OTP từ email
│   │   │   │                                   # - Đặt lại mật khẩu mới
│   │   │   │
│   │   │   ├── 📄 verify_account_screen.dart  # Xác minh email
│   │   │   │                                   # - Xác minh email đăng ký
│   │   │   │                                   # - Gửi lại mã xác minh
│   │   │   │
│   │   │   └── 📄 logout_screen.dart          # Đăng xuất
│   │   │                                       # - Confirm logout dialog
│   │   │
│   │   ├── 📂 carts/                  # 🛒 Màn hình giỏ hàng
│   │   │   └── 📄 cart_screen.dart           # Giỏ hàng chi tiết
│   │   │                                       # - Danh sách items trong giỏ
│   │   │                                       # - Cập nhật số lượng, xóa items
│   │   │                                       # - Tính tổng giá
│   │   │                                       # - Nút "Thanh toán"
│   │   │
│   │   ├── 📂 products/               # 🏷️ Màn hình quản lý sản phẩm
│   │   │   ├── 📄 product_detail_screen.dart    # Chi tiết sản phẩm
│   │   │   │                                       # - Hình ảnh sản phẩm (carousel)
│   │   │   │                                       # - Tên, giá, mô tả chi tiết
│   │   │   │                                       # - Đánh giá & bình luận
│   │   │   │                                       # - Nút "Thêm vào giỏ" & "Mua ngay"
│   │   │   │
│   │   │   ├── 📄 add_product_screen.dart       # Thêm sản phẩm mới (Seller)
│   │   │   │                                       # - Form: tên, giá, mô tả
│   │   │   │                                       # - Upload hình ảnh
│   │   │   │                                       # - Chọn danh mục
│   │   │   │
│   │   │   ├── 📄 edit_product_screen.dart      # Chỉnh sửa sản phẩm (Seller)
│   │   │   │                                       # - Giống add_product nhưng pre-fill dữ liệu cũ
│   │   │   │
│   │   │   └── 📄 add_variant_screen.dart       # Thêm phiên bản sản phẩm
│   │   │                                           # - Size, màu sắc, v.v.
│   │   │                                           # - Giá khác nhau cho mỗi phiên bản
│   │   │
│   │   ├── 📂 shops/                  # 🏪 Màn hình quản lý cửa hàng
│   │   │   ├── 📄 shop_list_screen.dart            # Danh sách cửa hàng
│   │   │   │                                           # - Grid/List các cửa hàng
│   │   │   │                                           # - Tìm kiếm cửa hàng
│   │   │   │
│   │   │   ├── 📄 shop_detail_screen.dart          # Chi tiết cửa hàng
│   │   │   │                                           # - Thông tin cửa hàng
│   │   │   │                                           # - Danh sách sản phẩm của cửa hàng
│   │   │   │                                           # - Đánh giá cửa hàng
│   │   │   │
│   │   │   ├── 📄 shop_register_screen.dart        # Đăng ký cửa hàng
│   │   │   │                                           # - Form: tên cửa hàng, mô tả, logo
│   │   │   │                                           # - Chế độ: chào đơn đăng ký
│   │   │   │
│   │   │   ├── 📄 shop_management_screen.dart      # Quản lý cửa hàng của chính mình (Seller)
│   │   │   │                                           # - Cập nhật thông tin cửa hàng
│   │   │   │                                           # - Xem bán hàng, đơn hàng
│   │   │   │                                           # - Quản lý sản phẩm
│   │   │   │
│   │   │   └── 📄 seller_product_list_screen.dart  # Danh sách sản phẩm của người bán
│   │   │                                               # - CRUD sản phẩm
│   │   │                                               # - Bật/tắt bán sản phẩm
│   │   │
│   │   ├── 📂 users/                  # 👥 Màn hình quản lý hồ sơ người dùng
│   │   │   ├── 📄 personal_info_screen.dart       # Xem thông tin cá nhân
│   │   │   │                                       # - Tên, email, phone, avatar
│   │   │   │                                       # - Nút "Chỉnh sửa"
│   │   │   │
│   │   │   └── 📄 edit_personal_info_screen.dart  # Chỉnh sửa thông tin cá nhân
│   │   │                                           # - Form cập nhật thông tin
│   │   │                                           # - Upload avatar mới
│   │   │
│   │   └── 📂 admins/                 # 🛡️ Màn hình quản trị viên (Admin)
│   │       ├── 📄 admin_dashboard_screen.dart        # Bảng điều khiển admin
│   │       │                                           # - Thống kê: tổng users, shops, orders
│   │       │                                           # - Biểu đồ doanh số
│   │       │                                           # - Hoạt động gần đây
│   │       │
│   │       ├── 📄 admin_home_screen.dart             # Trang chủ admin
│   │       │                                           # - Menu nhanh: Quản lý users, shops, orders
│   │       │
│   │       ├── 📄 admin_users_screen.dart            # Quản lý người dùng
│   │       │                                           # - Danh sách toàn bộ users
│   │       │                                           # - Search, filter, sort
│   │       │                                           # - Xóa/vô hiệu hóa user
│   │       │
│   │       ├── 📄 admin_user_detail_screen.dart      # Chi tiết người dùng (Admin view)
│   │       │                                           # - Thông tin cá nhân
│   │       │                                           # - Lịch sử đơn hàng
│   │       │                                           # - Các hành động: ban, unlock
│   │       │
│   │       ├── 📄 admin_shops_screen.dart            # Quản lý cửa hàng
│   │       │                                           # - Danh sách toàn bộ shops
│   │       │                                           # - Status: pending, approved, rejected
│   │       │
│   │       └── 📄 admin_shop_approval_screen.dart    # Duyệt/từ chối cửa hàng
│   │                                                   # - Xem chi tiết đơn đăng ký
│   │                                                   # - Nút approve/reject
│   │                                                   # - Ghi chú lý do từ chối
│   │
│   ├── 📂 widgets/                    # 🧩 Widget tái sử dụng (Reusable Components)
│   │                                   # Các component nhỏ dùng ở nhiều chỗ
│   │   ├── 📄 custom_button.dart       # Nút bấm tùy chỉnh
│   │   │                               # - Các kiểu: primary, secondary, outlined
│   │   │                               # - Loading state
│   │   │
│   │   ├── 📄 product_card.dart        # Card hiển thị sản phẩm
│   │   │                               # - Hình ảnh, tên, giá, rating
│   │   │                               # - Nút "Thêm vào giỏ"
│   │   │
│   │   ├── 📄 review_card.dart         # Card hiển thị đánh giá
│   │   │                               # - Avatar user, tên, sao rating
│   │   │                               # - Nội dung comment
│   │   │
│   │   ├── 📄 loading_indicator.dart   # Chỉ báo loading
│   │   │                               # - Spinner animation
│   │   │
│   │   ├── 📄 shop_card.dart           # Card hiển thị cửa hàng
│   │   │                               # - Logo, tên, rating
│   │   │
│   │   ├── 📄 search_bar.dart          # Thanh tìm kiếm
│   │   │                               # - Input field + icon search
│   │   │
│   │   └── 📄 category_chip.dart       # Chip danh mục
│   │                                   # - Filter theo danh mục
│   │
│   └── 📂 utils/                      # 🛠️ Các hàm tiện ích & Hằng số
│                                       # Code dùng chung cho cả app
│       ├── 📄 app_constants.dart       # Hằng số ứng dụng
│       │                               # - Màu sắc (colors)
│       │                               # - Kiểu chữ (fonts, sizes)
│       │                               # - API endpoints URLs
│       │                               # - Giá trị mặc định
│       │
│       ├── 📄 validators.dart          # Các hàm validate
│       │                               # - validateEmail()
│       │                               # - validatePassword()
│       │                               # - validatePhone()
│       │
│       ├── 📄 helper_functions.dart    # Hàm helper chung
│       │                               # - formatPrice() → định dạng tiền
│       │                               # - formatDate() → định dạng ngày
│       │                               # - showSnackbar() → thông báo
│       │
│       ├── 📄 app_theme.dart           # Cấu hình theme ứng dụng
│       │                               # - lightTheme, darkTheme
│       │                               # - TextStyle, ButtonStyle
│       │
│       └── 📄 extensions.dart          # Mở rộng (Extensions)
│                                       # - Hàm mở rộng cho String, DateTime, etc.
│


├── 📂 android/                        # 🤖 Code Android Native (Kotlin/Java)
│                                       # Cấu hình dành riêng cho Android
│   ├── 📄 build.gradle.kts            # Cấu hình build chính
│   │                                   # - buildTools version, SDK version
│   │                                   # - compileSdk, targetSdk
│   │
│   ├── 📄 local.properties            # Cấu hình local (không commit lên git)
│   │                                   # - sdk.dir = đường dẫn Android SDK
│   │
│   ├── 📄 gradle.properties           # Thuộc tính gradle
│   │                                   # - Cấu hình memory, network timeout
│   │
│   ├── 📄 gradlew                     # Gradle wrapper script (Linux/Mac)
│   │                                   # - Chạy: ./gradlew build
│   │
│   ├── 📄 gradlew.bat                 # Gradle wrapper script (Windows)
│   │                                   # - Chạy: gradlew.bat build
│   │
│   ├── 📄 settings.gradle.kts         # Cấu hình settings gradle
│   │                                   # - Include app module
│   │
│   └── 📂 app/                        # Module app chính
│       ├── 📄 build.gradle.kts        # Cấu hình build app
│       │                               # - Dependencies Android
│       │                               # - Signed config, build types
│       │
│       └── 📂 src/                    # Source code Android
│           ├── 📂 main/               # Resources chính
│           │   ├── 📂 java/           # Kotlin/Java code
│           │   └── 📂 res/            # Android resources
│           │
│           ├── 📂 debug/              # Debug resources
│           └── 📂 release/            # Release resources
│
├── 📂 ios/                            # 🍎 Code iOS Native (Swift/Objective-C)
│                                       # Cấu hình dành riêng cho iOS
│   ├── 📂 Runner/                     # Target ứng dụng chính
│   │   ├── 📄 AppDelegate.swift       # Entry point iOS
│   │   │                               # - Cấu hình app lifecycle
│   │   │                               # - Plugin setup
│   │   │
│   │   ├── 📄 Info.plist              # Cấu hình ứng dụng iOS
│   │   │                               # - App name, version, permissions
│   │   │                               # - URL schemes, permissions
│   │   │
│   │   ├── 📄 GeneratedPluginRegistrant.h  # Plugin registration header
│   │   ├── 📄 GeneratedPluginRegistrant.m  # Plugin registration implementation
│   │   │
│   │   ├── 📄 Runner-Bridging-Header.h     # Swift-ObjC bridge
│   │   │
│   │   └── 📂 Assets.xcassets/        # Assets iOS (icons, images)
│   │       └── AppIcon.appiconset/    # App icons
│   │
│   ├── 📂 Flutter/                    # Cấu hình Flutter cho iOS
│   │   ├── 📄 AppFrameworkInfo.plist  # Framework info
│   │   ├── 📄 Debug.xcconfig          # Debug config
│   │   ├── 📄 Release.xcconfig        # Release config
│   │   ├── 📄 Generated.xcconfig      # Auto-generated config
│   │   └── 📄 flutter_export_environment.sh  # Export environment
│   │
│   ├── 📂 Runner.xcodeproj/           # Project file Xcode
│   │   ├── 📄 project.pbxproj         # Project configuration
│   │   └── 📂 xcshareddata/           # Shared data
│   │
│   ├── 📂 Runner.xcworkspace/         # Workspace Xcode
│   │   ├── 📄 contents.xcworkspacedata
│   │   └── 📂 xcshareddata/
│   │
│   └── 📂 RunnerTests/                # Unit tests iOS
│       └── 📄 RunnerTests.swift       # Test cases
│
├── 📂 web/                            # 🌐 Code Web (HTML, CSS, JavaScript)
│                                       # Cấu hình web deployment
│   ├── 📄 index.html                  # HTML chính
│   │                                   # - Bootstrap Flutter web app
│   │                                   # - Script loading
│   │
│   ├── 📄 manifest.json               # Web App Manifest
│   │                                   # - App name, icons, theme color
│   │                                   # - Install prompt
│   │
│   └── 📂 icons/                      # Icons cho web/PWA
│       └── Icon-192.png               # App icon 192x192
│       └── Icon-512.png               # App icon 512x512
│
├── 📂 linux/                          # 🐧 Code Linux Native
│                                       # Cấu hình Linux desktop
│   ├── 📄 CMakeLists.txt              # Build configuration (CMake)
│   │
│   └── 📂 flutter/                    # Cấu hình Flutter
│       └── 📄 generated_plugins.cmake # Plugin generation
│
├── 📂 windows/                        # 🪟 Code Windows Native
│                                       # Cấu hình Windows desktop
│   ├── 📄 CMakeLists.txt              # Build configuration (CMake)
│   │
│   └── 📂 flutter/                    # Cấu hình Flutter
│       └── 📄 generated_plugins.cmake # Plugin generation
│
├── 📂 macos/                          # 🍎 Code macOS Native
│                                       # Cấu hình macOS desktop
│   ├── 📄 CMakeLists.txt              # Build configuration
│   │
│   ├── 📂 Runner.xcworkspace/         # Workspace Xcode
│   │
│   └── 📂 Runner.xcodeproj/           # Project Xcode
│
├── 📂 build/                          # 📦 Thư mục build (Auto-generated)
│                                       # Được tạo sau khi chạy flutter build
│                                       # ⚠️ Không commit lên git (đã trong .gitignore)
│   ├── 📄 last_build_run.json         # Thông tin build cuối cùng
│   │
│   ├── 📂 app/                        # Build output Android
│   │   ├── 📂 generated/              # Generated files
│   │   ├── 📂 intermediates/          # Intermediate build files
│   │   ├── 📂 kotlin/                 # Kotlin compilation output
│   │   ├── 📂 outputs/                # APK/AAB output
│   │   └── 📂 tmp/                    # Temporary files
│   │
│   ├── 📂 flutter_assets/             # Assets được compile
│   │   ├── 📄 AssetManifest.json      # Manifest assets
│   │   ├── 📄 AssetManifest.bin.json  # Binary format manifest
│   │   ├── 📄 FontManifest.json       # Fonts manifest
│   │   ├── 📄 NOTICES                 # License notices
│   │   ├── 📂 fonts/                  # Fonts được copy
│   │   ├── 📂 packages/               # Package assets
│   │   └── 📂 shaders/                # Shader files
│   │
│   ├── 📂 native_assets/              # Native assets
│   │   └── 📂 android/                # Android native libs
│   │
│   ├── 📂 path_provider_android/      # Plugin: path_provider (Android)
│   ├── 📂 shared_preferences_android/ # Plugin: shared_preferences (Android)
│   ├── 📂 sqflite_android/            # Plugin: sqflite (Android)
│   │
│   ├── 📂 ddf2ccd97f02dd6385adc137b52558c6/  # Build stamps
│   │   ├── 📄 _composite.stamp
│   │   ├── 📄 gen_dart_plugin_registrant.stamp
│   │   └── 📄 gen_localizations.stamp
│   │
│   └── 📂 [các platform khác]/        # Build output cho từng platform
│
└── 📂 test/                           # 🧪 Thư mục test (Unit & Widget Tests)
                                        # Chứa các test case cho ứng dụng
    └── 📄 widget_test.dart            # Widget testing example
                                        # - Test Flutter widgets
                                        # - Simulate user interactions
```

---

## 🔄 Architecture Pattern - Model View Provider (MVP)

```
┌─────────────────────────────────────────┐
│        UI (Screens & Widgets)           │
│  (main_tab_container, product_detail)   │
└────────────────┬────────────────────────┘
                 │ listen & notify
                 ↓
┌─────────────────────────────────────────┐
│   Providers (State Management)          │
│ (product_provider, cart_provider, etc)  │
└────────────────┬────────────────────────┘
                 │ call methods
                 ↓
┌─────────────────────────────────────────┐
│      Services (API Communication)       │
│  (product_service, auth_service, etc)   │
└────────────────┬────────────────────────┘
                 │ HTTP requests
                 ↓
┌─────────────────────────────────────────┐
│          Backend API Server             │
│    (Node.js, Django, Laravel, etc)      │
└─────────────────────────────────────────┘
```

---

## 📊 Flow Dữ Liệu Điển Hình

### Ví dụ: Lấy danh sách sản phẩm

1. **UI (home_screen.dart)** gọi `productProvider.fetchProducts()`
2. **Provider (product_provider.dart)** gọi `productService.getProducts()`
3. **Service (product_service.dart)** gửi HTTP GET request → Backend
4. **Backend** trả về danh sách sản phẩm (JSON)
5. **Service** parse JSON thành `List<Product>` models
6. **Provider** cập nhật state, notify listeners
7. **UI** rebuild với dữ liệu mới → Hiển thị ProductCard widgets

---

## 🚀 Cách Sử Dụng Các Thư Mục

### Thêm Tính Năng Mới
```
1. Tạo Model → lib/models/feature_model.dart
2. Tạo Service → lib/service/feature_service.dart
3. Tạo Provider → lib/providers/feature_provider.dart
4. Tạo Screen → lib/screens/feature_feature_screen.dart
5. Tạo Widgets → lib/widgets/feature_card.dart (nếu cần)
6. Cập nhật Constants → lib/utils/app_constants.dart
```

### Cấu Trúc Naming Convention
- **Screens**: `{feature}_screen.dart` → `product_detail_screen.dart`
- **Providers**: `{feature}_provider.dart` → `product_provider.dart`
- **Services**: `{feature}_service.dart` → `product_service.dart`
- **Models**: `{feature}_model.dart` → `product_model.dart`
- **Widgets**: `{feature}_card.dart` → `product_card.dart`

---

## 📝 Dependencies Chính (pubspec.yaml)

| Package | Chức Năng |
|---------|---------|
| `provider` | State management |
| `http` hoặc `dio` | API calls |
| `shared_preferences` | Local storage (simple) |
| `sqflite` | Local database |
| `path_provider` | File paths |
| `image_picker` | Select images |
| `cached_network_image` | Cache images |
| `intl` | Localization & formatting |

---

## 🔐 Tính Năng Bảo Mật Được Áp Dụng

- ✅ Token-based authentication (JWT)
- ✅ Secure storage cho tokens (secure_storage)
- ✅ HTTPS enforced
- ✅ Input validation & sanitization
- ✅ SQL injection prevention (models + ORM)
- ✅ CORS configured on backend

---

## 📱 Responsive Design

- ✅ Adaptive UI dựa trên screen size
- ✅ Landscape & Portrait support
- ✅ Mobile-first approach
- ✅ Web responsive layout

---

**Cập nhật lúc**: December 25, 2025  
**Phiên bản**: 2.0  
**Trạng thái**: Hoàn chỉnh ✅


