# **MINI E-COMMERCE APP - README HOÀN CHỈNH**

---

## **📱 TỔNG QUAN ỨNG DỤNG**

**🚀 Tên App**: **Mini E-commerce**  
**📱 Platform**: **Flutter (Mobile)** + **NestJS (Backend)** + **MySQL (Database)**  
**🎯 Mục đích**: Ứng dụng thương mại điện tử hoàn chỉnh với đầy đủ chức năng **Auth**, **Products**, **Cart**, **Orders**  
**👨‍💻 Developer**: [Tên bạn]  
**📅 Ngày tạo**: 21/10/2025

---

## **🏗️ CẤU TRÚC THƯ MỤC CHI TIẾT**

```
mini-ecommerce/
│
├── 📁 frontend/                          # Flutter Mobile App
│   ├── 📁 lib/
│   │   ├── 📁 models/                    # Data Models
│   │   │   ├── user_model.dart           # User data structure
│   │   │   ├── product_model.dart        # Product data structure
│   │   │   ├── cart_model.dart           # Cart item structure
│   │   │   └── order_model.dart          # Order structure
│   │   │
│   │   ├── 📁 providers/                 # State Management (Provider)
│   │   │   ├── auth_provider.dart        # Authentication logic
│   │   │   ├── cart_provider.dart        # Shopping cart logic
│   │   │   ├── product_provider.dart     # Products management
│   │   │   └── order_provider.dart       # Orders management
│   │   │
│   │   ├── 📁 screens/                   # UI Screens
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart     # Login UI
│   │   │   │   ├── register_screen.dart  # Register UI
│   │   │   │   ├── verify_screen.dart    # OTP Verify UI
│   │   │   │   └── reset_otp_screen.dart # Reset Password UI
│   │   │   ├── home_screen.dart          # Main Home screen
│   │   │   ├── product_list_screen.dart  # Products list
│   │   │   ├── cart_screen.dart          # Shopping cart
│   │   │   └── order_screen.dart         # Orders history
│   │   │
│   │   ├── 📁 services/                  # API Services
│   │   │   ├── auth_service.dart         # Auth API calls
│   │   │   ├── product_service.dart      # Products API
│   │   │   ├── cart_service.dart         # Cart API
│   │   │   └── order_service.dart        # Orders API
│   │   │
│   │   ├── 📁 utils/                     # Utilities
│   │   │   ├── app_constants.dart        # API endpoints
│   │   │   └── validators.dart           # Form validation
│   │   │
│   │   └── main.dart                     # App entry point
│   │
│   ├── 📁 android/                       # Android config
│   ├── 📁 ios/                           # iOS config
│   └── pubspec.yaml                      # Dependencies
│
├── 📁 backend/                           # NestJS API Server
│   ├── 📁 src/
│   │   ├── 📁 modules/                   # Feature Modules
│   │   │   ├── 📁 auth/                  # Authentication Module
│   │   │   │   ├── auth.controller.ts    # API endpoints
│   │   │   │   ├── auth.service.ts       # Business logic
│   │   │   │   ├── auth.module.ts        # Module config
│   │   │   │   ├── dto/                  # Data Transfer Objects
│   │   │   │   └── guards/               # JWT Guards
│   │   │   │
│   │   │   ├── 📁 products/              # Products Module
│   │   │   ├── 📁 cart/                  # Cart Module
│   │   │   ├── 📁 orders/                # Orders Module
│   │   │   └── 📁 email/                 # Email Service
│   │   │       ├── email.service.ts      # SMTP Email
│   │   │       └── templates/            # Email HTML
│   │   │
│   │   ├── 📁 common/                    # Shared Utilities
│   │   │   ├── decorators/               # Custom decorators
│   │   │   ├── guards/                   # Auth guards
│   │   │   └── pipes/                    # Data pipes
│   │   │
│   │   ├── 📁 database/                  # DB Config
│   │   │   ├── entities/                 # TypeORM entities
│   │   │   └── migrations/               # DB migrations
│   │   │
│   │   ├── app.module.ts                 # Root module
│   │   └── main.ts                       # Server entry
│   │
│   ├── 📁 .env                           # Environment variables
│   ├── 📁 nest-cli.json                  # Nest CLI config
│   └── package.json                      # Backend dependencies
│
└── 📄 README.md                          # Documentation này
```

---

## **📋 MỤC ĐÍCH TỪNG FILE QUAN TRỌNG**

### **FRONTEND (Flutter)**

| **File** | **Mục đích** | **Chi tiết** |
|----------|--------------|--------------|
| `user_model.dart` | Định nghĩa cấu trúc User | `id, name, email, isVerified` |
| `auth_provider.dart` | Quản lý Auth state | Login, Register, Verify, Reset Password |
| `auth_service.dart` | Gọi API Auth | HTTP requests + token management |
| `login_screen.dart` | UI màn hình đăng nhập | Form + validation |
| `verify_screen.dart` | UI nhập OTP | 6-digit input + timer |
| `reset_otp_screen.dart` | UI reset password | OTP + new password form |
| `app_constants.dart` | Cấu hình API URLs | Base URL + endpoints |
| `main.dart` | Entry point | Provider setup + routing |

### **BACKEND (NestJS)**

| **File** | **Mục đích** | **Chi tiết** |
|----------|--------------|--------------|
| `auth.controller.ts` | API endpoints | `/login`, `/register`, `/verify` |
| `auth.service.ts` | Business logic | JWT, bcrypt, OTP generation |
| `email.service.ts` | Gửi email OTP | Nodemailer + Gmail SMTP |
| `user.entity.ts` | Database schema | TypeORM entity |
| `.env` | Config secrets | JWT secret, SMTP, DB |
| `app.module.ts` | Root module | Import tất cả modules |

---

## **🔄 LUỒNG CHẠY HOÀN CHỈNH CỦA APP**

### **1. KHỞI ĐỘNG APP**
```
main.dart
  ↓
Provider<AuthProvider> + MaterialApp(routes)
  ↓
Splash Screen (2s) → Login Screen
```

### **2. LUỒNG ĐĂNG KÝ (REGISTER FLOW)**
```
1. REGISTER SCREEN
   ↓ [Nhập name, email, password]
2. auth_provider.register()
   ↓
3. auth_service.register() → POST /auth/register
   ↓ [Status 201]
4. AUTO LOGIN: auth_provider.login()
   ↓
5. auth_service.login() → POST /auth/login
   ↓ [Lấy access_token]
6. isVerified = false → requestVerify()
   ↓
7. auth_service.requestVerify() → POST /auth/request-verify
   ↓ [Gửi email OTP]
8. PUSH → VERIFY SCREEN
   ↓ [Nhập OTP]
9. auth_provider.verifyAccount()
   ↓
10. auth_service.verifyAccount() → POST /auth/verify-account
    ↓ [isVerified = true]
11. PUSH → HOME + "Xin chào [tên]!"
```

### **3. LUỒNG ĐĂNG NHẬP (LOGIN FLOW)**
```
1. LOGIN SCREEN
   ↓ [Nhập email, password]
2. auth_provider.login()
   ↓
3. auth_service.login() → POST /auth/login
   ↓
4. if(isVerified == true)
   ↓
5. PUSH → HOME + "Xin chào [tên]!"
   ↓
6. else → requestVerify() → VERIFY SCREEN
```

### **4. LUỒNG QUÊN MẬT KHẨU (RESET PASSWORD FLOW)**
```
1. FORGOT PASSWORD SCREEN
   ↓ [Nhập email]
2. auth_provider.forgotPassword()
   ↓
3. auth_service.forgotPassword() → POST /auth/forgot-password
   ↓ [Gửi email OTP]
4. PUSH → RESET_OTP SCREEN
   ↓ [Nhập OTP + New Password]
5. auth_provider.resetPassword()
   ↓
6. auth_service.resetPassword() → POST /auth/reset-password
   ↓ [Cập nhật password]
7. PUSH → LOGIN SCREEN
```

### **5. LUỒNG MUA HÀNG (E-COMMERCE FLOW)**
```
HOME → Products List → Add to Cart
  ↓
CART SCREEN → Checkout → Create Order
  ↓
ORDER SCREEN → Order History
```

### **6. LOGOUT**
```
HOME → Menu → Logout
  ↓
auth_provider.logout()
  ↓
Clear token + PUSH → LOGIN
```

---

## **⚙️ CẤU HÌNH & CHẠY APP**

### **BACKEND (NestJS)**
```bash
cd backend
npm install
cp .env.example .env  # Cấu hình Gmail App Password
npm run start:dev     # http://localhost:3000
```

### **FRONTEND (Flutter)**
```bash
cd frontend
flutter pub get
flutter run           # Android/iOS
```

### **DATABASE (MySQL)**
```sql
CREATE DATABASE mini_ecommerce;
# Chạy migrations: npm run typeorm migration:run
```

---

## **📧 EMAIL CONFIG (QUAN TRỌNG)**

**.env (Backend)**:
```env
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your_email@gmail.com
MAIL_PASS=your_app_password    # Gmail App Password (16 ký tự)
```

**Tạo App Password**:
1. Gmail → Settings → Security → 2-Step Verification → App Passwords
2. Chọn "Mail" → Generate → Copy 16 ký tự

---

## **🔒 BẢNG DATABASE (MySQL)**

```sql
-- Users
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  is_verified BOOLEAN DEFAULT FALSE,
  otp VARCHAR(255),
  time_otp DATETIME,
  created_at TIMESTAMP
);

-- Products
CREATE TABLE products (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),
  price DECIMAL(10,2),
  image VARCHAR(500),
  description TEXT
);
```

---

## **📊 API ENDPOINTS**

| **Method** | **Endpoint** | **Mô tả** |
|------------|--------------|-----------|
| `POST` | `/auth/register` | Đăng ký |
| `POST` | `/auth/login` | Đăng nhập |
| `POST` | `/auth/request-verify` | Gửi OTP |
| `POST` | `/auth/verify-account` | Xác minh OTP |
| `POST` | `/auth/forgot-password` | Quên mật khẩu |
| `POST` | `/auth/reset-password` | Đổi mật khẩu |
| `GET` | `/products` | Danh sách sản phẩm |
| `POST` | `/cart/add` | Thêm vào giỏ |
| `POST` | `/orders/create` | Tạo đơn hàng |

---

## **🛠️ TROUBLESHOOTING**

### **Email không gửi được**
1. Kiểm tra `.env` → `MAIL_PASS` (App Password)
2. Test SMTP: `telnet smtp.gmail.com 587`

### **Lỗi 401 Unauthorized**
1. Token hết hạn → Auto refresh
2. Kiểm tra `SharedPreferences` có `access_token`

### **OTP không verify**
1. Kiểm tra cooldown 60s
2. Xóa `otp/time_otp` trong DB (dev)

---

## **🚀 FEATURES HOÀN THÀNH**

- [x] **Authentication**: Register/Login/Verify/Reset Password
- [x] **Email OTP**: Gmail SMTP integration
- [x] **JWT Tokens**: Access/Refresh tokens
- [x] **Products**: CRUD operations
- [x] **Shopping Cart**: Add/Remove/Update
- [x] **Orders**: Create/View history
- [x] **State Management**: Provider pattern
- [x] **Responsive UI**: Material Design

---

## **📝 GHI CHÚ PHÁT TRIỂN**

1. **Security**: JWT + Bcrypt + OTP validation
2. **Performance**: Lazy loading products + Pagination
3. **Offline**: Local storage cart (có thể thêm)
4. **Push Notifications**: Firebase (tương lai)

**⏱️ Thời gian phát triển**: **2 tuần**  
**💾 Dung lượng**: **~50MB** (APK)  
**⭐ Rating mục tiêu**: **4.8/5**

---



**Copy nội dung này vào `README.md` và commit! 🚀**