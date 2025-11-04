import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // THÊM debugPrint
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../providers/auth_provider.dart';

class ApiClient {
  // --------------------------------------------------------------
  // Singleton
  // --------------------------------------------------------------
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  CookieJar? _cookieJar;

  // --------------------------------------------------------------
  // Init
  // --------------------------------------------------------------
  Future<void> init() async {
    // CookieJar (persist on mobile, in‑memory on web)
    if (kIsWeb) {
      _cookieJar = CookieJar();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(
          storage: FileStorage("${dir.path}/.cookies/"));
    }

    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
      validateStatus: (s) => s! < 500,
    ));

    // Cookie manager (mobile only)
    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // --------------------------------------------------------------
    // Interceptor: Bearer + Auto‑Refresh
    // --------------------------------------------------------------
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('[REQUEST] ${options.method} ${options.uri}');
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          debugPrint('401 → Refresh token...');
          final refreshed = await refreshToken();
          if (refreshed) {
            // Re‑execute original request
            final clone = await _dio.fetch(e.requestOptions);
            return handler.resolve(clone);
          } else {
            await logoutAndRedirect();
          }
        }
        handler.next(e);
      },
    ));
  }

  // --------------------------------------------------------------
  // Public helpers (được dùng trong mọi service)
  // --------------------------------------------------------------
  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken}) async {
    return await _dio.get<T>(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  Future<Response<T>> post<T>(String path,
      {dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken}) async {
    return await _dio.post<T>(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  Future<Response<T>> patch<T>(String path,
      {dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken}) async {
    return await _dio.patch<T>(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  Future<Response<T>> delete<T>(String path,
      {dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken}) async {
    return await _dio.delete<T>(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  // --------------------------------------------------------------
  // Refresh token
  // --------------------------------------------------------------
  Future<bool> refreshToken() async {
    try {
      final resp = await _dio.post('/auth/refresh');
      if (resp.statusCode == 200) {
        final newToken = resp.data['data']['access_token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newToken);
        debugPrint('Refresh token OK');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Refresh token failed: $e');
      return false;
    }
  }

  // --------------------------------------------------------------
  // Logout + redirect
  // --------------------------------------------------------------
  Future<void> logoutAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await _cookieJar?.deleteAll();
    AuthProvider.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (r) => false);
  }
}