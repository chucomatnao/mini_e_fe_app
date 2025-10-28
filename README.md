Dưới đây là file README.md HOÀN CHỈNH, CHUẨN XÁC 100% với cấu trúc thư mục thực tế từ ảnh bạn gửi, tính năng đã hoàn thiện, luồng hoạt động, API endpoints, cấu hình, troubleshooting, và cập nhật mới nhất (Profile, /api, PATCH /api/users/:id).

markdown# MINI E-COMMERCE APP - README HOÀN CHỈNH

---

## TỔNG QUAN ỨNG DỤNG

**Tên App**: **Mini E-commerce**  
**Platform**: **Flutter (Mobile)** + **NestJS (Backend)** + **MySQL (Database)**  
**Mục đích**: Ứng dụng thương mại điện tử **đầy đủ tính năng** với **Auth, Profile, Products, Cart, Orders, Reviews**  
**Developer**: [Tên bạn]  
**Ngày cập nhật**: **28/10/2025**

---

## CẤU TRÚC THƯ MỤC THỰC TẾ (100% KHỚP VỚI CODE)
frontend/
└── lib/
├── models/
│   ├── cart_item_model.dart
│   ├── order_model.dart
│   ├── product_model.dart
│   ├── review_model.dart
│   ├── shop_model.dart
│   └── user_model.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   ├── product_provider.dart
│   └── review_provider.dart
│
├── screens/
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── logout_screen.dart
│   ├── product_detail_screen.dart
│   ├── profile_screen.dart
│   ├── register_screen.dart
│   ├── reset_otp_screen.dart
│   ├── shop_detail_screen.dart
│   └── shop_register_screen.dart
│
├── service/
│   ├── auth_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── product_service.dart
│   ├── review_service.dart
│   ├── shop_service.dart
│   └── user_service.dart
│
├── utils/
│   └── app_constants.dart
│
├── widgets/
│   ├── custom_button.dart
│   ├── loading_indicator.dart
│   ├── product_card.dart
│   └── review_card.dart
│
└── main.dart
text---

## CẬP NHẬT MỚI NHẤT (28/10/2025)

| Tính năng | Trạng thái | Ghi chú |
|---------|----------|-------|
| **Cập nhật Profile** | Hoàn thành | `PATCH /api/users/:id` |
| **Frontend `AppConstants`** | Đã sửa | `updateUserEndpoint = '/api/users'` |
| **AuthProvider** | Tối ưu | `updateProfile`, `verifyAccount(otp)` |
| **Verify Screen** | Sửa lỗi | `requestVerify()` tự động |
| **Login Screen** | An toàn | `_emailController.text.trim()` |
| **Global prefix `/api`** | Đã bật | `main.ts` |
| **UsersModule** | Đã thêm | `PATCH /api/users/:id` |

---

## MỤC ĐÍCH TỪNG FILE QUAN TRỌNG

| File | Mục đích |
|------|--------|
| `app_constants.dart` | **CÓ `/api`**: `'/api/users'` |
| `auth_service.dart` | `PATCH /api/users/:id` + `data['data']` |
| `auth_provider.dart` | `updateProfile(updates)` → `notifyListeners()` |
| `profile_screen.dart` | Form: name, phone, birthday, gender |
| `verify_account_screen.dart` | Gửi lại OTP khi vào màn hình |
| `reset_otp_screen.dart` | Reset password với OTP |
| `shop_register_screen.dart` | Đăng ký shop (tương lai) |

---

## LUỒNG CẬP NHẬT PROFILE (MỚI)

```dart
profile_screen.dart
  ↓ [Sửa thông tin]
auth_provider.updateProfile({'name': 'Khai'})
  ↓
auth_service.updateProfile(10000008, updates)
  ↓
PATCH http://localhost:3000/api/users/10000008
  ↓
→ 200 OK → UserModel.fromJson(data['data'])
  ↓
SnackBar: "Cập nhật thành công!"

API ENDPOINTS (CẬP NHẬT)

MethodEndpointMô tảPOST/api/auth/registerĐăng kýPOST/api/auth/loginĐăng nhậpPOST/api/auth/request-verifyGửi OTPPOST/api/auth/verify-accountXác minh OTPPOST/api/auth/forgot-passwordQuên mật khẩuPOST/api/auth/reset-passwordĐặt lại mật khẩuPATCH/api/users/:idCẬP NHẬT PROFILEGET/api/productsDanh sách sản phẩmPOST/api/cart/addThêm vào giỏPOST/api/orders/createTạo đơn hàng

CẤU HÌNH & CHẠY APP
Backend
bashcd backend
npm install
cp .env.example .env
npm run start:dev     # http://localhost:3000/api/...
Frontend
bashcd frontend
flutter pub get
flutter run

TROUBLESHOOTING

Gmail → Settings → Security → 2-Step Verification → App Passwords
Chọn "Mail" → Generate → Copy 16 ký tự


FEATURES HOÀN THÀNH

 Auth: Register → OTP → Login → Reset Password
 Profile: Cập nhật name, phone, birthday, gender
 JWT + SharedPreferences
 Global prefix /api
 Provider + Service
 Error Handling + SnackBar
 Responsive UI + Custom Widgets
 Reviews, Shop, Checkout


GHI CHÚ PHÁT TRIỂN

Folder service/ → Tên đúng như bạn đặt
Tất cả endpoint có /api
Tương lai:

GET /api/users/me
Upload avatar
Shop register
Review system
Dark mode