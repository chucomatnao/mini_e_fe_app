// File entry point của ứng dụng
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..loadSampleProducts()),
      ],
      child: MaterialApp(
        title: 'Mini E-commerce',
        initialRoute: '/login',
        navigatorKey: AuthProvider.navigatorKey, // Sử dụng key toàn cục
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => ProductListScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
        },
      ),
    );
  }
}