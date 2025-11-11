README.md – CHUẨN 100% ĐỂ CLONE & CHẠY NGAY (11/11/2025, 23:03 +07)
Tên app: ShopFlutter – Ứng dụng Bán hàng Flutter (VN)
Cập nhật bởi: User (VN) – 23:03, 11/11/2025

markdown# ShopFlutter – Ứng dụng Bán hàng Flutter (VN)

Ứng dụng **bán hàng đa nền tảng** (Android, iOS, Web, Desktop) cho **người mua, người bán, admin**.  
Hỗ trợ: **đăng nhập**, **quản lý shop**, **sản phẩm + biến thể**, **giỏ hàng**, **mua ngay**, **đánh giá**, **admin duyệt shop**.

> **Phiên bản**: `v1.0.0`  
> **Cập nhật**: `23:03, 11/11/2025 (+07)`  
> **Tình trạng**: **Sẵn sàng clone & chạy** – không cần backend!

---

## Tính năng chính

| Người dùng | Tính năng |
|-----------|---------|
| **Buyer** | Xem sản phẩm, mua ngay, thêm giỏ, đánh giá |
| **Seller** | Đăng ký shop, quản lý sản phẩm, thêm biến thể |
| **Admin** | Duyệt shop, xem danh sách, quản lý người dùng |

---

## Yêu cầu hệ thống

| Yêu cầu | Phiên bản |
|--------|---------|
| **Flutter** | `3.24.0` trở lên |
| **Dart** | `3.5.0` trở lên |
| **Android Studio / VS Code** | Cài Flutter plugin |
| **Git** | Bắt buộc |

---

## Hướng dẫn chạy app (5 phút)

### Bước 1: Clone repo
```bash
git clone https://github.com/yourname/shopflutter.git
cd shopflutter
Bước 2: Cài dependencies
bashflutter pub get
Bước 3: Chạy app
bashflutter run
App sẽ tự động chạy trên Android Emulator, iOS Simulator, Web, hoặc thiết bị thật.

Cấu hình nhanh (nếu cần)
1. Backend API (Mock – không cần server thật)

App dùng mock data trong product_provider.dart → không cần backend.
Nếu muốn kết nối thật → sửa BASE_URL trong lib/utils/app_constants.dart:

dartconst String BASE_URL = 'https://your-api.com/api';
2. Chạy trên thiết bị thật

Bật USB Debugging (Android) hoặc Developer Mode (iOS).
Kết nối điện thoại → chạy:

bashflutter run
3. Chạy trên Web
bashflutter run -d chrome

Cấu trúc thư mục (chuẩn 100%)
textlib/
├── main.dart                        # Điểm vào app, khởi tạo Provider + Theme

├── models/                          # MÔ HÌNH DỮ LIỆU (Data Models)
│   ├── user_model.dart              # User: id, name, email, role, isVerified
│   ├── product_model.dart           # Product: id, title, price, imageUrl, stock, shopId, variants
│   ├── shop_model.dart              # Shop: id, name, slug, status, stats
│   ├── order_model.dart             # Order: id, total, status, items
│   ├── cart_item_model.dart         # CartItem: productId, quantity, variant
│   └── review_model.dart            # Review: rating, comment, userId, productId

├── providers/                       # TRẠNG THÁI & LOGIC BUSINESS (State Management)
│   ├── auth_provider.dart           # Đăng nhập, token, auto-login theo role
│   ├── user_provider.dart           # Lấy/cập nhật profile user
│   ├── product_provider.dart        # Danh sách sản phẩm, chi tiết, parse variants
│   ├── cart_provider.dart           # Giỏ hàng: add/remove/update, lưu local
│   ├── order_provider.dart          # Đơn hàng: tạo, theo dõi, hủy
│   └── shop_provider.dart           # Shop: đăng ký, quản lý, duyệt (admin)

├── screens/                         # MÀN HÌNH UI (Screens)
│   ├── login_screen.dart            # Form đăng nhập
│   ├── register_screen.dart         # Form đăng ký
│   ├── verify_account_screen.dart   # Nhập OTP xác thực
│   ├── forgot_password_screen.dart  # Quên mật khẩu
│   ├── reset_otp_screen.dart        # Đặt lại mật khẩu
│   ├── home_screen.dart             # Trang chủ: sản phẩm nổi bật + nút mua nhanh
│   ├── profile_screen.dart          # Hồ sơ: menu chức năng theo role
│   ├── personal_info_screen.dart    # Chỉnh sửa thông tin cá nhân
│   ├── shop_management_screen.dart  # Quản lý shop cá nhân (3 nút cùng hàng)
│   ├── shop_register_screen.dart    # Đăng ký shop mới
│   ├── cart_screen.dart             # Giỏ hàng
│   ├── checkout_screen.dart         # Thanh toán
│   ├── product_detail_screen.dart   # Chi tiết sản phẩm: variant, mua ngay
│   ├── review_screen.dart           # Đánh giá sản phẩm
│   │
│   ├── admin_home_screen.dart           # MỚI: Admin Panel chính
│   ├── admin_shop_approval_screen.dart  # MỚI: Duyệt shop PENDING
│   ├── main_tab_container.dart          # MỚI: TabBar động theo role
│   └── shop_list_screen.dart            # MỚI: Danh sách shop công khai

├── service/                         # GỌI API (HTTP Services)
│   ├── api_client.dart              # Dio config, interceptor, refresh token
│   ├── auth_service.dart            # POST /auth/login, register, OTP
│   ├── user_service.dart            # GET/PATCH /users/me
│   ├── product_service.dart         # GET /products, POST /products
│   ├── order_service.dart           # POST /orders
│   ├── cart_service.dart            # POST /cart/add
│   └── shop_service.dart            # POST /shops/register, GET /shops

├── utils/                           # TIỆN ÍCH (Utils)
│   └── app_constants.dart           # Base URL, endpoints (UsersApi, ShopsApi)

├── widgets/                         # COMPONENT UI TÁI SỬ DỤNG
│   ├── custom_button.dart           # Nút tùy chỉnh
│   ├── product_card.dart            # Card sản phẩm (có variant chip)
 Gian│   ├── review_card.dart             # Card đánh giá
│   └── loading_indicator.dart       # Spinner loading

Công nghệ & Thư viện

Thư việnPhiên bảnMục đíchflutter3.24+Frameworkprovider6.1.2Quản lý trạng tháidio5.7.0Gọi APIimage_picker1.1.2Chọn ảnhshared_preferences2.3.2Lưu token
Xem chi tiết trong pubspec.yaml

Lưu ý quan trọng

pubspec.lock và pubspec.yaml đã commit → đảm bảo version đồng bộ.
Không cần backend thật → dùng mock data.
Chạy được trên mọi nền tảng → Android, iOS, Web, Desktop.


Người đóng góp

Bạn – Fullstack Flutter + UX
Grok – AI Assistant (xAI)


Tương lai

 Kết nối backend thật (NestJS)
 Upload ảnh sản phẩm
 Giỏ hàng lưu local
 Push notification


Cập nhật lần cuối: 23:03, 11/11/2025 (+07)
Người cập nhật: User (VN)
Trạng thái: Sẵn sàng clone & chạy ngay!

Chỉ cần 3 lệnh → app chạy ngon lành!
bashgit clone https://github.com/yourname/shopflutter.git
cd shopflutter
flutter pub get && flutter run

Chúc bạn chạy app thành công!
Nếu lỗi → mở issue hoặc inbox mình nhé!