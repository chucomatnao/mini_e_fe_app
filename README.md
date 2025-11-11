README.md – CẬP NHẬT CHUẨN 100% (11/11/2025, 22:47)
Tên app: ShopFlutter – Ứng dụng Bán hàng Flutter (VN)
Phiên bản: v1.0.0
Cập nhật bởi: User (VN) – 22:47, 11/11/2025

markdown# ShopFlutter – Ứng dụng Bán hàng Flutter (VN)

Ứng dụng **bán hàng đa năng** dành cho **người mua (buyer)**, **người bán (seller)** và **quản trị viên (admin)**.  
Hỗ trợ: **quản lý shop**, **sản phẩm**, **biến thể (variants)**, **giỏ hàng**, **đơn hàng**, **đánh giá**, **phân quyền theo role**.

> **Tình trạng**: Đã hoàn thiện **hiển thị biến thể**, **mua nhanh**, **quản lý shop 3 nút**, **admin panel**, **đăng ký shop + duyệt**.

---

## Tính năng chính

| Role | Tính năng |
|------|---------|
| **User (Buyer)** | Đăng nhập, mua hàng, thêm giỏ, thanh toán, đánh giá sản phẩm |
| **Seller** | Đăng ký shop, quản lý sản phẩm, biến thể, xem đơn hàng |
| **Admin** | Duyệt shop, quản lý người dùng, xem thống kê |
| **Chung** | Đăng nhập/đăng ký, xác thực OTP, quên mật khẩu |

---

## CẤU TRÚC THƯ MỤC (CẬP NHẬT CHUẨN 100%)
lib/
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
│   ├── review_card.dart             # Card đánh giá
│   └── loading_indicator.dart       # Spinner loading
├──main.dart

## Công nghệ & Thư viện (Cập nhật 11/11/2025)

| Loại | Tên | Phiên bản | Mục đích |
|------|-----|---------|--------|
| **Ngôn ngữ** | Dart | `3.5+` | Core |
| **Framework** | Flutter | `3.24+` | UI Cross-platform |
| **Quản lý trạng thái** | `provider` | `6.1.2` | State management |
| **Gọi API** | `dio` | `5.7.0` | HTTP Client + Interceptor |
| **Chọn ảnh** | `image_picker` | `1.1.2` | Upload avatar, logo |
| **Lưu trữ local** | `shared_preferences` | `2.3.2` | Token, user info |
| **Xử lý ảnh mạng** | `Image.network` | Built-in | Hiển thị ảnh từ URL |
| **UI Components** | `material.dart` | Built-in | Card, Chip, Button, Dialog |
| **Quản lý route** | `Navigator 2.0` | Built-in | `pushNamed` + arguments |

> **Backend**: NestJS + TypeORM (giả định) – trả `optionSchema` → parse thành `variants`

---

## API Backend (NestJS – giả định)

| Endpoint | Method | Mô tả |
|--------|--------|------|
| `POST /auth/login` | POST | Đăng nhập |
| `POST /auth/register` | POST | Đăng ký |
| `GET /products` | GET | Danh sách sản phẩm |
| `GET /products/:id` | GET | Chi tiết sản phẩm |
| `POST /products` | POST | Tạo sản phẩm (có `optionSchema`) |
| `GET /shops/me` | GET | Lấy shop của user |
| `POST /shops/register` | POST | Đăng ký shop mới |
| `GET /shops?status=PENDING` | GET | Admin duyệt shop |

---

## Cách chạy

```bash
# 1. Clone repo
git clone https://github.com/yourname/shopflutter.git
cd shopflutter

# 2. Cài dependencies
flutter pub get

# 3. Chạy app
flutter run