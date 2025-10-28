import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/verify_account_screen.dart';
import 'screens/reset_otp_screen.dart';
import 'screens/profile_screen.dart'; // Thêm ProfileScreen

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AuthProvider.navigatorKey,
      title: 'Mini E-commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify-account': (context) => VerifyAccountScreen(),
        '/reset-otp': (context) => ResetOtpScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}