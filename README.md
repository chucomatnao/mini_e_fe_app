# 🛍️ MINI E-COMMERCE APP — README HOÀN CHỈNH (CẬP NHẬT 03/11/2025)

---

## 📖 TỔNG QUAN ỨNG DỤNG

**Tên ứng dụng**: Mini E-commerce  
**Nền tảng**: Flutter (Web/Mobile) + NestJS (Backend) + MySQL (Database)  
**Mục đích**: Ứng dụng thương mại điện tử **đầy đủ tính năng**: Đăng ký, Đăng nhập, OTP, Quản lý hồ sơ, Quản lý shop, Sản phẩm, Giỏ hàng, Đơn hàng, Đánh giá.  
**Người phát triển**: [Bùi Đình Khải]  
**Cập nhật mới nhất**: `03/11/2025`

---

## 📂 CẤU TRÚC THƯ MỤC (CHUẨN XÁC 100%)

frontend/
└── lib/
├── models/
│ ├── user_model.dart
│ ├── product_model.dart
│ ├── shop_model.dart
│ ├── order_model.dart
│ ├── cart_item_model.dart
│ └── review_model.dart
│
├── providers/
│ ├── auth_provider.dart
│ ├── user_provider.dart
│ ├── product_provider.dart
│ ├── cart_provider.dart
│ ├── order_provider.dart
│ └── shop_provider.dart
│
├── screens/
│ ├── login_screen.dart
│ ├── register_screen.dart
│ ├── verify_account_screen.dart
│ ├── forgot_password_screen.dart
│ ├── reset_otp_screen.dart
│ ├── home_screen.dart
│ ├── profile_screen.dart
│ ├── personal_info_screen.dart
│ ├── shop_management_screen.dart
│ ├── shop_register_screen.dart
│ ├── cart_screen.dart
│ ├── checkout_screen.dart
│ ├── product_detail_screen.dart
│ └── review_screen.dart
│
├── service/
│ ├── api_client.dart
│ ├── auth_service.dart
│ ├── user_service.dart
│ ├── product_service.dart
│ ├── order_service.dart
│ ├── cart_service.dart
│ └── shop_service.dart
│
├── utils/
│ └── app_constants.dart
│
├── widgets/
│ ├── custom_button.dart
│ ├── product_card.dart
│ ├── review_card.dart
│ └── loading_indicator.dart
│
└── main.dart

yaml
Sao chép mã

---

## 🚀 CẬP NHẬT MỚI NHẤT (03/11/2025)

| Thành phần | Tình trạng | Ghi chú |
|-------------|------------|---------|
| **Profile & Personal Info** | ✅ Hoàn thiện | Giữ session, sửa reload, không bị logout |
| **CookieManager Web** | ✅ Đã fix | Tự động disable trên Web |
| **AuthProvider** | ✅ Tối ưu | Giữ token sau reload, load user từ cache |
| **UserProvider** | ✅ Fix loop | Chặn gọi lặp vô hạn `/users/me` |
| **main.dart** | ✅ Chuẩn hoá | Khởi tạo tuần tự `ApiClient → AuthProvider` |
| **api_client.dart** | ✅ Update | Không thêm CookieManager khi `kIsWeb = true` |
| **/api/users/me** | ✅ Hoạt động ổn định | Load user sau reload, không logout |
| **PATCH /api/users/:id** | ✅ Sẵn sàng | Dùng cho cập nhật hồ sơ |
| **Profile UI** | ✅ Giữ nguyên giao diện cũ | Menu đầy đủ: Thông tin cá nhân, Shop, Voucher, Đăng xuất |
| **Personal Info UI** | ✅ Giữ nút quay lại | Reload không bị logout |

---

## 💡 LUỒNG HOẠT ĐỘNG CHÍNH

### 🔑 **Đăng nhập / Đăng ký / OTP**
```dart
AuthProvider.login(email, password)
↓
AuthService.login()
↓
POST /api/auth/login
↓
Lưu accessToken vào SharedPreferences
↓
Tự động gọi /api/users/me → load user
👤 Cập nhật thông tin cá nhân (Profile)
dart
Sao chép mã
PersonalInfoScreen → UserProvider.updateProfile()
↓
PATCH /api/users/:id
↓
UserModel.fromJson(data['data'])
↓
SnackBar("Cập nhật thành công!")
🧾 Reload Trang Web
dart
Sao chép mã
main.dart → AuthProvider.init()
↓
SharedPreferences.load('accessToken')
↓
Nếu có token → gọi /api/users/me
↓
User giữ nguyên → không bị logout
🔗 API ENDPOINTS (BACKEND)
Method	Endpoint	Mô tả
POST	/api/auth/register	Đăng ký
POST	/api/auth/login	Đăng nhập
POST	/api/auth/request-verify	Gửi OTP xác thực
POST	/api/auth/verify-account	Xác minh tài khoản
POST	/api/auth/forgot-password	Quên mật khẩu
POST	/api/auth/reset-password	Đặt lại mật khẩu
GET	/api/users/me	Lấy thông tin người dùng hiện tại
PATCH	/api/users/:id	Cập nhật hồ sơ
GET	/api/products	Danh sách sản phẩm
POST	/api/cart/add	Thêm sản phẩm vào giỏ
POST	/api/orders/create	Tạo đơn hàng mới
GET	/api/shops	Danh sách shop
POST	/api/shops/register	Đăng ký shop mới

⚙️ CẤU HÌNH VÀ CHẠY ỨNG DỤNG
🔸 Backend (NestJS)
bash
Sao chép mã
cd backend
npm install
cp .env.example .env
npm run start:dev
# API chạy tại: http://localhost:3000/api
🔹 Frontend (Flutter)
bash
Sao chép mã
cd frontend
flutter pub get
flutter run -d chrome
# hoặc
flutter run -d windows
🧠 LƯU Ý VÀ FIX LỖI THƯỜNG GẶP
Lỗi	Nguyên nhân	Cách khắc phục
Don't use the manager in Web environments	Dùng CookieManager trên web	Đã fix: disable tự động trong api_client.dart
Reload bị logout	AuthProvider chưa load token xong	Đã fix: chờ init() hoàn tất
Spam /api/users/me	fetchMe() gọi liên tục	Đã fix: thêm _hasFetched flag
Mất nút quay lại ở Personal Info	Reload làm mất stack Navigator	Đã fix: AppBar.leading luôn có nút Back
Auto logout khi lỗi network	Exception xử lý sai	Đã fix trong auth_provider.dart

🧩 FILE QUAN TRỌNG
File	Mục đích
lib/main.dart	Khởi tạo app, provider, route
lib/service/api_client.dart	Cấu hình Dio, baseUrl, disable CookieManager web
lib/providers/auth_provider.dart	Giữ token, auto-load user
lib/providers/user_provider.dart	Fetch và update profile
lib/screens/profile_screen.dart	Giao diện Hồ sơ, menu chức năng
lib/screens/personal_info_screen.dart	Trang chỉnh sửa thông tin
lib/utils/app_constants.dart	Base URL, endpoint /api
lib/service/user_service.dart	Gọi API GET /me, PATCH /:id

🧾 DANH SÁCH TÍNH NĂNG ĐÃ HOÀN THÀNH
✅ Đăng ký, Đăng nhập, Xác minh OTP
✅ Lưu token bằng SharedPreferences
✅ Gọi /api/users/me khi reload
✅ Cập nhật hồ sơ (name, phone, birthday, gender)
✅ Tự động hiển thị SnackBar khi thành công / lỗi
✅ Giữ giao diện Profile + Personal Info hoàn chỉnh
✅ Hoạt động mượt trên Web và Mobile
✅ Bảo mật JWT qua Header Authorization
✅ Không còn lỗi lặp request hoặc logout khi refresh

🌟 ĐỊNH HƯỚNG PHÁT TRIỂN TIẾP
Mục tiêu	Mô tả
Upload ảnh đại diện	Dùng multipart/form-data
Quản lý đơn hàng	Thêm /api/orders/me
Tích hợp thanh toán	Stripe / VNPay
Dark mode	Cho toàn bộ app
GraphQL hỗ trợ song song	REST + GraphQL
PWA build	Tối ưu hóa bản Web

🧑‍💻 TÁC GIẢ
Bùi Đình Khải
📧 bkhaidinh@gmail.com
💼 Mini E Project — 2025