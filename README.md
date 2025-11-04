TỔNG QUAN ỨNG DỤNG
Tên ứng dụng: Mini E-commerce
Nền tảng: Flutter (Web/Mobile) + NestJS (Backend) + MySQL
Mục đích: Ứng dụng thương mại điện tử đầy đủ tính năng với phân quyền rõ ràng:

USER: Mua sắm, quản lý shop cá nhân
ADMIN: Duyệt shop, quản trị hệ thống

Người phát triển: Bùi Đình Khải
Cập nhật mới nhất: 05/11/2025

CẤU TRÚC THƯ MỤC (CẬP NHẬT CHUẨN 100%)
bashfrontend/
└── lib/
├── models/                          # MÔ HÌNH DỮ LIỆU (Data Models)
│   ├── user_model.dart              # User: id, name, email, role, isVerified
│   ├── product_model.dart           # Product: id, name, price, shopId
│   ├── shop_model.dart              # Shop: id, name, slug, status, stats
│   ├── order_model.dart             # Order: id, total, status, items
│   ├── cart_item_model.dart         # CartItem: productId, quantity
│   └── review_model.dart            # Review: rating, comment, userId
│
├── providers/                       # TRẠNG THÁI & LOGIC BUSINESS (State Management)
│   ├── auth_provider.dart           # Đăng nhập, token, auto-login theo role
│   ├── user_provider.dart           # Lấy/cập nhật profile user
│   ├── product_provider.dart        # Danh sách sản phẩm, chi tiết
│   ├── cart_provider.dart           # Giỏ hàng: add/remove/update
│   ├── order_provider.dart          # Đơn hàng: tạo, theo dõi
│   └── shop_provider.dart           # Shop: đăng ký, quản lý, duyệt
│
├── screens/                         # MÀN HÌNH UI (Screens)
│   ├── login_screen.dart            # Form đăng nhập
│   ├── register_screen.dart         # Form đăng ký
│   ├── verify_account_screen.dart   # Nhập OTP xác thực
│   ├── forgot_password_screen.dart  # Quên mật khẩu
│   ├── reset_otp_screen.dart        # Đặt lại mật khẩu
│   ├── home_screen.dart             # Trang chủ: sản phẩm nổi bật
│   ├── profile_screen.dart          # Hồ sơ: menu chức năng
│   ├── personal_info_screen.dart    # Chỉnh sửa thông tin cá nhân
│   ├── shop_management_screen.dart  # Quản lý shop cá nhân
│   ├── shop_register_screen.dart    # Đăng ký shop mới
│   ├── cart_screen.dart             # Giỏ hàng
│   ├── checkout_screen.dart         # Thanh toán
│   ├── product_detail_screen.dart   # Chi tiết sản phẩm
│   ├── review_screen.dart           # Đánh giá sản phẩm
│   │
│   ├── admin_home_screen.dart           ← MỚI: Admin Panel chính
│   ├── admin_shop_approval_screen.dart  ← MỚI: Duyệt shop PENDING
│   ├── main_tab_container.dart          ← MỚI: TabBar động theo role
│   └── shop_list_screen.dart            ← MỚI: Danh sách shop công khai
│
├── service/                         # GỌI API (HTTP Services)
│   ├── api_client.dart              # Dio config, interceptor, refresh token
│   ├── auth_service.dart            # POST /auth/login, register, OTP
│   ├── user_service.dart            # GET/PATCH /users/me
│   ├── product_service.dart         # GET /products
│   ├── order_service.dart           # POST /orders
│   ├── cart_service.dart            # POST /cart/add
│   └── shop_service.dart            # POST /shops/register, GET /shops
│
├── utils/                           # TIỆN ÍCH (Utils)
│   └── app_constants.dart           # Base URL, endpoints (UsersApi, ShopsApi)
│
├── widgets/                         # COMPONENT UI TÁI SỬ DỤNG
│   ├── custom_button.dart           # Nút tùy chỉnh
│   ├── product_card.dart            # Card sản phẩm
│   ├── review_card.dart             # Card đánh giá
│   └── loading_indicator.dart       # Spinner loading
│
└── main.dart                        # ENTRY POINT: Providers, Routes

CẬP NHẬT MỚI NHẤT (05/11/2025)


















































Thành phầnTình trạngGhi chúPhân quyền ADMIN / USERHoàn thiệnTự động điều hướng theo roleADMIN PANELHoàn thiệnadmin_home_screen.dart + TabBarDuyệt Shop (PENDING → ACTIVE)Hoàn thiệnadmin_shop_approval_screen.dartDanh sách Shop công khaiHoàn thiệnshop_list_screen.dartTabBar chính (MainTabContainer)Hoàn thiệnGiao diện chung cho cả USER & ADMINĐăng xuất từ ADMINHoàn thiệnNút logout + xác nhậnAuto-login theo roleHoàn thiệninit() kiểm tra role?.toUpperCase()Backend trả roleHoàn thiện/api/auth/login trả role: "ADMIN"

FILE MỚI & CHỨC NĂNG CHI TIẾT

1. admin_home_screen.dart
   Mục đích: Màn hình chính của ADMIN
   Chức năng:

Hiển thị "ADMIN PANEL"
Nút "Duyệt Shop" → chuyển đến admin_shop_approval_screen
Nút "Đăng xuất" ở AppBar
Xác nhận trước khi logout

dartIconButton(
icon: Icon(Icons.logout),
onPressed: () => showDialog → authProvider.logout()
)

2. admin_shop_approval_screen.dart
   Mục đích: ADMIN duyệt shop chờ phê duyệt
   Chức năng:

Gọi GET /api/shops?status=PENDING
Hiển thị danh sách shop PENDING
Nút "Duyệt" → PATCH /api/shops/:id → status: ACTIVE
Tự động refresh danh sách sau khi duyệt

dartShopService().update(shop.id, {'status': 'ACTIVE'})

3. main_tab_container.dart
   Mục đích: Giao diện chung cho cả USER và ADMIN
   Chức năng:

TabBar + TabBarView
Tự động hiển thị tab phù hợp theo role

USER: Home, Shop, Cart, Profile
ADMIN: Tổng quan, Duyệt Shop



dartConsumer<AuthProvider>(
builder: (ctx, auth, _) {
final isAdmin = auth.user?.role?.toUpperCase() == 'ADMIN';
return isAdmin ? AdminTabs() : UserTabs();
}
)

4. shop_list_screen.dart
   Mục đích: Hiển thị danh sách shop công khai
   Chức năng:

Gọi GET /api/shops
Hiển thị tất cả shop (không cần đăng nhập)
Click shop → ShopDetailScreen
Hỗ trợ phân trang, tìm kiếm


LUỒNG HOẠT ĐỘNG CHÍNH (CẬP NHẬT)
1. Đăng nhập → Phân quyền tự động
   dartAuthProvider.login()
   ↓
   Lưu accessToken vào SharedPreferences
   ↓
   _user.role == 'ADMIN' → /admin-home
   _user.role != 'ADMIN' → /home
2. Khởi động app → Auto-login theo role
   dartmain.dart → AuthProvider.init()
   ↓
   SharedPreferences.get('access_token')
   ↓
   UserProvider.fetchMe()
   ↓
   _user.role?.toUpperCase() == 'ADMIN'
   → pushReplacementNamed('/admin-home')
   → pushReplacementNamed('/home')
3. ADMIN duyệt shop
   dartadmin_shop_approval_screen.dart
   ↓
   ShopProvider.fetchShops(status: 'PENDING')
   ↓
   Hiển thị danh sách
   ↓
   Click "Duyệt" → ShopService.update(id, {status: 'ACTIVE'})
   ↓
   SnackBar + Refresh danh sách
4. Người bán thấy shop được duyệt
   dartshop_management_screen.dart
   ↓
   ShopProvider.loadMyShop()
   ↓
   status == 'ACTIVE' → Hiển thị "Hoạt động"

API ENDPOINTS (BACKEND — ĐÃ HOÀN THIỆN)









































MethodEndpointMô tảQuyềnPOST/api/auth/loginĐăng nhập, trả rolePublicGET/api/shops?status=PENDINGLấy shop chờ duyệtADMINPATCH/api/shops/:idCập nhật trạng tháiADMINGET/api/shopsDanh sách shop công khaiPublicPOST/api/shops/registerĐăng ký shopUSER

DANH SÁCH TÍNH NĂNG ĐÃ HOÀN THÀNH

Đăng ký, Đăng nhập, OTP, Quên mật khẩu
Phân quyền ADMIN / USER
ADMIN PANEL với duyệt shop
Danh sách shop công khai
Đăng ký shop → chờ duyệt → được duyệt
Đăng xuất an toàn từ ADMIN
Auto-login theo role
Hoạt động mượt trên Web & Mobile


ĐỊNH HƯỚNG PHÁT TRIỂN TIẾP





























Mục tiêuMô tảUpload logo/cover shopDùng S3 + presigned URLXem sản phẩm của shopGET /api/shops/:id/productsThống kê doanh thu ADMINDashboard với biểu đồChặn đăng sản phẩm nếu shop chưa ACTIVEKiểm tra shop.statusGửi email khi duyệt shopEmailService.sendApproval()