# Cấu Trúc Dự Án Mini E-Commerce Frontend

## 📋 Tổng Quan
Đây là một ứng dụng Flutter cho nền tảng thương mại điện tử nhỏ (Mini E-Commerce) với hỗ trợ cho cả người mua và người bán.

---

## 📁 Cấu Trúc Thư Mục Chi Tiết
mini_e_fe_app/
├── 📄 pubspec.yaml                    # File cấu hình Flutter (dependencies, assets)
├── 📄 analysis_options.yaml           # Cấu hình phân tích code lint
├── 📄 devtools_options.yaml          # Cấu hình DevTools
├── 📄 mini_e_fe_app.iml             # File cấu hình IDE
├── 📄 README.md                       # Tài liệu về dự án
│
├── 📂 lib/                            # Thư mục chính chứa code Dart
│   │
│   ├── 📄 main.dart                   # File entry point của ứng dụng, cấu hình ứng dụng chính
│   │
│   ├── 📂 models/                     # Các model dữ liệu (Data Models)
│   │   ├── 📄 user_model.dart         # Model thông tin người dùng (id, name, email, phone)
│   │   ├── 📄 product_model.dart      # Model sản phẩm (id, name, price, description, image)
│   │   ├── 📄 cart_model.dart         # Model giỏ hàng (items, quantities, total price)
│   │   ├── 📄 order_model.dart        # Model đơn hàng (id, products, status, date)
│   │   ├── 📄 shop_model.dart         # Model cửa hàng (id, name, owner, description)
│   │   └── 📄 review_model.dart       # Model đánh giá (rating, comment, user, product)
│   │
│   ├── 📂 providers/                  # State Management (Provider Pattern)
│   │   ├── 📄 auth_provider.dart      # Quản lý trạng thái xác thực (login, logout, register)
│   │   ├── 📄 user_provider.dart      # Quản lý dữ liệu người dùng
│   │   ├── 📄 product_provider.dart   # Quản lý danh sách sản phẩm, lọc, tìm kiếm
│   │   ├── 📄 cart_provider.dart      # Quản lý giỏ hàng (add, remove, update items)
│   │   ├── 📄 order_provider.dart     # Quản lý lịch sử đơn hàng
│   │   ├── 📄 shop_provider.dart      # Quản lý thông tin cửa hàng
│   │   └── 📄 review_provider.dart    # Quản lý đánh giá sản phẩm
│   │
│   ├── 📂 service/                    # Các service API (Communication with Backend)
│   │   ├── 📄 api_client.dart         # HTTP Client cơ sở, cấu hình request/response
│   │   ├── 📄 auth_service.dart       # API xác thực (login, register, forgot password)
│   │   ├── 📄 user_service.dart       # API quản lý người dùng (profile, update info)
│   │   ├── 📄 product_service.dart    # API sản phẩm (fetch, search, filter)
│   │   ├── 📄 cart_service.dart       # API giỏ hàng (add, remove, update)
│   │   ├── 📄 order_service.dart      # API đơn hàng (create, fetch history)
│   │   ├── 📄 shop_service.dart       # API cửa hàng (register, manage, view)
│   │   └── 📄 review_service.dart     # API đánh giá (submit, fetch reviews)
│   │
│   ├── 📂 screens/                    # Các màn hình (UI Screens)
│   │   │
│   │   ├── 📄 main_tab_container.dart # Màn hình chứa tab chính (home, cart, profile, admin)
│   │   ├── 📄 home_screen.dart        # Màn hình trang chủ (danh sách sản phẩm, banner)
│   │   ├── 📄 profile_screen.dart     # Màn hình hồ sơ người dùng
│   │   ├── 📄 checkout_screen.dart    # Màn hình thanh toán, xác nhận đơn hàng
│   │   │
│   │   ├── 📂 auths/                  # Màn hình xác thực
│   │   │   ├── 📄 login_screen.dart           # Đăng nhập
│   │   │   ├── 📄 register_screen.dart        # Đăng ký tài khoản
│   │   │   ├── 📄 logout_screen.dart          # Đăng xuất
│   │   │   ├── 📄 forgot_password_screen.dart # Quên mật khẩu
│   │   │   ├── 📄 reset_otp_screen.dart       # Xác minh OTP để đặt lại mật khẩu
│   │   │   └── 📄 verify_account_screen.dart  # Xác minh tài khoản
│   │   │
│   │   ├── 📂 carts/                  # Màn hình giỏ hàng
│   │   │   └── 📄 cart_screen.dart           # Hiển thị giỏ hàng, cập nhật số lượng
│   │   │
│   │   ├── 📂 products/               # Màn hình quản lý sản phẩm
│   │   │   ├── 📄 product_detail_screen.dart    # Chi tiết sản phẩm, đánh giá
│   │   │   ├── 📄 add_product_screen.dart       # Thêm sản phẩm mới (cho người bán)
│   │   │   ├── 📄 edit_product_screen.dart      # Chỉnh sửa thông tin sản phẩm
│   │   │   └── 📄 add_variant_screen.dart       # Thêm phiên bản/biến thể sản phẩm
│   │   │
│   │   ├── 📂 shops/                  # Màn hình quản lý cửa hàng
│   │   │   ├── 📄 shop_list_screen.dart            # Danh sách cửa hàng
│   │   │   ├── 📄 shop_detail_screen.dart          # Chi tiết cửa hàng
│   │   │   ├── 📄 shop_register_screen.dart        # Đăng ký cửa hàng mới
│   │   │   ├── 📄 shop_management_screen.dart      # Quản lý cửa hàng của chính mình
│   │   │   └── 📄 seller_product_list_screen.dart  # Danh sách sản phẩm của người bán
│   │   │
│   │   ├── 📂 users/                  # Màn hình quản lý hồ sơ người dùng
│   │   │   ├── 📄 personal_info_screen.dart       # Xem thông tin cá nhân
│   │   │   └── 📄 edit_personal_info_screen.dart  # Chỉnh sửa thông tin cá nhân
│   │   │
│   │   └── 📂 admins/                 # Màn hình quản trị viên
│   │       ├── 📄 admin_dashboard_screen.dart        # Bảng điều khiển admin (thống kê)
│   │       ├── 📄 admin_home_screen.dart             # Trang chủ admin
│   │       ├── 📄 admin_users_screen.dart            # Quản lý người dùng
│   │       ├── 📄 admin_user_detail_screen.dart      # Chi tiết người dùng (admin)
│   │       ├── 📄 admin_shops_screen.dart            # Quản lý cửa hàng
│   │       └── 📄 admin_shop_approval_screen.dart    # Duyệt/từ chối cửa hàng
│   │
│   ├── 📂 widgets/                    # Các widget tái sử dụng (Reusable Components)
│   │   ├── 📄 custom_button.dart       # Nút bấm tùy chỉnh
│   │   ├── 📄 product_card.dart        # Card hiển thị sản phẩm (hình, giá, rating)
│   │   ├── 📄 review_card.dart         # Card hiển thị đánh giá (sao, comment)
│   │   └── 📄 loading_indicator.dart   # Chỉ báo tải dữ liệu
│   │
│   └── 📂 utils/                      # Các hàm tiện ích (Utilities)
│       └── 📄 app_constants.dart       # Hằng số ứng dụng (colors, fonts, API endpoints)
│
├── 📂 android/                        # Code Android Native (Kotlin/Java)
│   ├── 📄 build.gradle.kts            # Cấu hình build Android
│   ├── 📄 local.properties            # Cấu hình SDK location (local)
│   ├── 📄 gradle.properties           # Thuộc tính gradle
│   ├── 📄 gradlew                     # Gradle wrapper (Linux/Mac)
│   ├── 📄 gradlew.bat                 # Gradle wrapper (Windows)
│   ├── 📄 settings.gradle.kts         # Cấu hình settings gradle
│   └── 📂 app/
│       ├── 📄 build.gradle.kts        # Cấu hình build app
│       └── 📂 src/                    # Source code Android
│
├── 📂 ios/                            # Code iOS Native (Swift/Objective-C)
│   ├── 📂 Runner/                     # Ứng dụng chính
│   │   ├── 📄 AppDelegate.swift       # Entry point iOS app
│   │   ├── 📄 Info.plist              # Cấu hình ứng dụng iOS
│   │   ├── 📄 GeneratedPluginRegistrant.h/.m  # Plugin registration
│   │   └── 📂 Assets.xcassets/        # Assets iOS (icons, images)
│   ├── 📂 Flutter/                    # Cấu hình Flutter cho iOS
│   └── 📂 Runner.xcworkspace/         # Workspace Xcode
│
├── 📂 web/                            # Code Web (HTML, CSS, JS)
│   ├── 📄 index.html                  # HTML chính
│   ├── 📄 manifest.json               # Web app manifest
│   └── 📂 icons/                      # Icons cho web
│
├── 📂 linux/                          # Code Linux Native
│   ├── 📄 CMakeLists.txt              # Build configuration
│   └── 📂 flutter/                    # Cấu hình Flutter
│
├── 📂 windows/                        # Code Windows Native
│   ├── 📄 CMakeLists.txt              # Build configuration
│   └── 📂 flutter/                    # Cấu hình Flutter
│
├── 📂 macos/                          # Code macOS Native
│   ├── 📄 CMakeLists.txt              # Build configuration
│   └── 📂 Runner.xcworkspace/         # Workspace Xcode
│
├── 📂 build/                          # Thư mục build (tự động tạo)
│   ├── 📄 last_build_run.json         # Thông tin build cuối cùng
│   ├── 📂 app/                        # Build output Android
│   ├── 📂 flutter_assets/             # Assets được compile
│   └── 📂 native_assets/              # Native assets
│
└── 📂 test/                           # Test files
    └── 📄 widget_test.dart            # Widget testing
text---

## 🎯 Chức Năng Chính của Các Phần

### **Models (lib/models/)**
Định nghĩa cấu trúc dữ liệu cho toàn ứng dụng

### **Providers (lib/providers/)**
Quản lý state toàn cục bằng Provider pattern
- Tương tác giữa UI và services
- Cung cấp dữ liệu cho widgets

### **Services (lib/service/)**
Giao tiếp với backend API
- Xử lý HTTP requests/responses
- Xử lý errors và exceptions

### **Screens (lib/screens/)**
Các trang giao diện người dùng
- Sử dụng providers để lấy dữ liệu
- Hiển thị widgets

### **Widgets (lib/widgets/)**
Các component tái sử dụng
- Giảm code duplication
- Dễ bảo trì và cập nhật

### **Utils (lib/utils/)**
Hàm tiện ích và hằng số
- Constants màu, font, API endpoints
- Helper functions

---

## 📱 Tính Năng Chính

### Cho Người Mua (Customer)
- ✅ Đăng ký/Đăng nhập
- ✅ Duyệt sản phẩm & tìm kiếm
- ✅ Xem chi tiết sản phẩm
- ✅ Đánh giá sản phẩm
- ✅ Thêm vào giỏ hàng
- ✅ Thanh toán & tạo đơn hàng
- ✅ Xem lịch sử đơn hàng
- ✅ Quản lý hồ sơ cá nhân

### Cho Người Bán (Seller)
- ✅ Đăng ký cửa hàng
- ✅ Quản lý sản phẩm (thêm, sửa, xóa)
- ✅ Quản lý biến thể sản phẩm
- ✅ Xem đơn hàng
- ✅ Quản lý cửa hàng

### Cho Quản Trị Viên (Admin)
- ✅ Dashboard thống kê
- ✅ Quản lý người dùng
- ✅ Quản lý cửa hàng
- ✅ Duyệt/Từ chối cửa hàng mới
- ✅ Xem chi tiết người dùng