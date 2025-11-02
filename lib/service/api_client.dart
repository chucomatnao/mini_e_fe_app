import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../providers/auth_provider.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  CookieJar? _cookieJar;

  Future<void> init() async {
    if (kIsWeb) {
      // ⚠️ Web: KHÔNG dùng CookieManager
      _cookieJar = CookieJar(); // tạm để dùng local
      print('Running on Web — CookieManager disabled');
    } else {
      // ✅ Mobile/Desktop: Dùng CookieManager + PersistCookieJar
      final dir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(storage: FileStorage("${dir.path}/.cookies/"));
    }

    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
      validateStatus: (status) => status! < 500,
    ));

    // ✅ Chỉ thêm CookieManager nếu KHÔNG phải Web
    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // ✅ Interceptor: Bearer token + Refresh khi 401
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('DEBUG: [REQUEST] ${options.method} → ${options.uri}');
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          print('DEBUG: 401 → Thử refresh token...');
          try {
            final refreshed = await refreshToken();
            if (refreshed) {
              final cloneReq = await _dio.request(
                e.requestOptions.path,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                ),
              );
              return handler.resolve(cloneReq);
            }
          } catch (_) {
            await logoutAndRedirect();
          }
        }
        handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<bool> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final newAccessToken = data['access_token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newAccessToken);
        print('DEBUG: Refresh token success → new access_token');
        return true;
      }
      return false;
    } catch (e) {
      print('DEBUG: Refresh failed: $e');
      return false;
    }
  }

  Future<void> logoutAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await _cookieJar?.deleteAll();
    AuthProvider.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
