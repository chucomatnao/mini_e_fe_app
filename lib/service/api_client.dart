import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../providers/auth_provider.dart'; // THÊM IMPORT NÀY ĐỂ SỬ DỤNG AuthProvider.navigatorKey

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  late CookieJar _cookieJar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage("${dir.path}/.cookies/"));

    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
      validateStatus: (status) => status! < 500,
    ));

    _dio.interceptors.add(CookieManager(_cookieJar));

    // Interceptor: Thêm Bearer token + Refresh khi 401
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
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry request gốc
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
            // Refresh fail → logout
            await _logoutAndRedirect();
          }
        }
        handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<bool> _refreshToken() async {
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

  Future<void> _logoutAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    // Xóa cookie
    await _cookieJar.deleteAll();

    // Navigate to login (bây giờ AuthProvider đã được import, không lỗi nữa)
    AuthProvider.navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}