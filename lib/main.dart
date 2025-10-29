import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_account_screen.dart';
import 'screens/reset_otp_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shop_management_screen.dart';
import 'screens/shop_register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(), // Không dùng const
        '/home': (context) => HomeScreen(),         // Không dùng const
        '/forgot-password': (context) => ForgotPasswordScreen(), // Không dùng const
        '/verify-account': (context) => const VerifyAccountScreen(),
        '/reset-otp': (context) => ResetOtpScreen(), // Không dùng const
        '/profile': (context) => const ProfileScreen(),
        '/shop-management': (context) => const ShopManagementScreen(),
        '/shop-register': (context) => const ShopRegisterScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}