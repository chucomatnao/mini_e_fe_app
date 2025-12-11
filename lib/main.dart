// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/cart_provider.dart';

// Services
import 'service/api_client.dart';
import 'service/shop_service.dart';

// Models
import 'models/shop_model.dart';
import 'models/product_model.dart'; // ← THÊM: CHO PRODUCT DETAIL
import 'models/cart_model.dart';

// Screens
import 'screens/admins/admin_shops_screen.dart';
import 'screens/admins/admin_users_screen.dart';
import 'screens/admins/admin_shop_approval_screen.dart';
import 'screens/admins/admin_home_screen.dart';
import 'screens/auths/login_screen.dart';
import 'screens/auths/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auths/forgot_password_screen.dart';
import 'screens/auths/verify_account_screen.dart';
import 'screens/auths/reset_otp_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shops/shop_management_screen.dart';
import 'screens/shops/shop_register_screen.dart';
import 'screens/users/personal_info_screen.dart';
import 'screens/shops/shop_list_screen.dart';
import 'screens/shops/shop_detail_screen.dart';
import 'screens/products/product_detail_screen.dart';
import 'screens/products/add_product_screen.dart';
import 'screens/products//add_variant_screen.dart'; // (Tùy chọn)
import 'screens/carts/cart_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().init();

  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider(service: ShopService())),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // SAU KHI KHỞI TẠO ỨNG DỤNG → TỰ ĐỘNG TẢI SẢN PHẨM CHO TRANG CHỦ (chỉ ACTIVE)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await authProvider.init();

    final context = AuthProvider.navigatorKey.currentContext;
    if (context != null) {
      // ĐÃ SỬA: Dùng fetchPublicProducts() thay vì fetchProducts()
      Provider.of<ProductProvider>(context, listen: false)
          .fetchPublicProducts();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AuthProvider.navigatorKey,
      title: 'Mini E-commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        // === AUTH & USER ===
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) {
          // Tự động tải sản phẩm công khai (chỉ ACTIVE) khi vào trang chủ
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ProductProvider>(context, listen: false)
                .fetchPublicProducts(); // ĐÃ SỬA
          });
          return const HomeScreen();
        },
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify-account': (context) => const VerifyAccountScreen(),
        '/reset-otp': (context) => ResetOtpScreen(),
        '/profile': (context) => const ProfileScreen(),

        // === SHOP ===
        '/shop-management': (context) => const ShopManagementScreen(),
        '/shop-register': (context) => const ShopRegisterScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/shops': (context) => const ShopListScreen(),

        // === ADMIN ===
        '/admin-home': (context) => AdminHomeScreen(),
        '/admin/shops': (context) => AdminShopsScreen(),
        '/admin/users': (context) => AdminUsersScreen(),
        '/admin-shop-approval': (context) => AdminShopApprovalScreen(),

        // === SHOP DETAIL ===
        '/shop-detail': (context) {
          final shop = ModalRoute.of(context)!.settings.arguments as ShopModel;
          return ShopDetailScreen(shop: shop);
        },

        // === PRODUCT ===
        '/product-detail': (context) {
          final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
          return ProductDetailScreen(product: product);
        },
        '/add-product': (context) => const AddProductScreen(),
        '/add-variant': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final productId = args['productId'] as int;
          return AddVariantScreen(productId: productId);
        },

        // === CART ===
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}