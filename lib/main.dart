// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/shop_provider.dart';

// Services
import 'service/api_client.dart';
import 'service/shop_service.dart';

// Models
import 'models/shop_model.dart'; // THÊM DÒNG NÀY (fix lỗi 1)

// Screens
import 'screens/admin_shop_approval_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_account_screen.dart';
import 'screens/reset_otp_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shop_management_screen.dart';
import 'screens/shop_register_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/shop_list_screen.dart';
import 'screens/shop_detail_screen.dart';

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

        // FIX LỖI 2: Dùng named parameter 'service'
        ChangeNotifierProvider(
          create: (_) => ShopProvider(service: ShopService()),
        ),
      ],
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await authProvider.init();
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
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify-account': (context) => const VerifyAccountScreen(),
        '/reset-otp': (context) => ResetOtpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/shop-management': (context) => const ShopManagementScreen(),
        '/shop-register': (context) => const ShopRegisterScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),

        '/shops': (context) => const ShopListScreen(),
        '/admin-home': (context) => AdminHomeScreen(),
        '/admin-shop-approval': (context) => AdminShopApprovalScreen(),

        // FIX LỖI 1: Dùng ShopModel (đã import)
        '/shop-detail': (context) {
          final shop = ModalRoute.of(context)!.settings.arguments as ShopModel;
          return ShopDetailScreen(shop: shop);
        },
      },
    );
  }
}