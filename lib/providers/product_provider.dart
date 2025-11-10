import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../utils/app_constants.dart';   // ← DÙNG BASEURL & ENDPOINT
import 'auth_provider.dart';           // ← LẤY TOKEN

/// ---------------------------------------------------------------------------
/// PRODUCT PROVIDER – QUẢN LÝ SẢN PHẨM & GỌI API
/// ĐÃ CẬP NHẬT:
/// • Dùng AppConstants.baseUrl
/// • Dùng ProductApi cho mọi endpoint
/// • Tự động lấy token từ AuthProvider
/// • Bắt 401 → tự động logout
/// • Log debug chi tiết
/// ---------------------------------------------------------------------------
class ProductProvider with ChangeNotifier {
  // ====================== DIO CLIENT (DÙNG AppConstants) ======================
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl, // ← TỪ APP_CONSTANTS
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // ====================== TRẠNG THÁI ======================
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ====================== CONSTRUCTOR ======================
  ProductProvider() {

  }



  // ========================================================================
  // 1. LẤY TOKEN TỪ AUTH PROVIDER
  // ========================================================================
  Future<String> _getToken() async {
    final context = AuthProvider.navigatorKey.currentContext;
    if (context == null) {
      throw Exception('Ứng dụng chưa khởi tạo xong');
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;

    if (token == null || token.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    return token;
  }

  // ========================================================================
  // 2. LẤY DANH SÁCH SẢN PHẨM
  // ========================================================================
  Future<void> fetchProducts({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final token = await _getToken();

      final response = await _dio.get(
        ProductApi.products, // ← DÙNG ENDPOINT TỪ ProductApi
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> rawList = response.data['data'] ?? [];
      _products = rawList.map((json) => ProductModel.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = _handleDioError(e);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi không xác định: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========================================================================
  // 3. TẠO SẢN PHẨM MỚI
  // ========================================================================
  Future<ProductModel?> createProduct({
    required String title,
    required double price,
    int? stock,
    String? description,
    String? slug,
    List<File>? images,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();

      final data = <String, dynamic>{
        'title': title,
        'price': price,
        if (stock != null) 'stock': stock,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
      };

      final formData = FormData.fromMap(data);

      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final file = images[i];
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: 'image_$i.jpg',
            ),
          ));
        }
      }

      final response = await _dio.post(
        ProductApi.products, // ← DÙNG ENDPOINT
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final newProduct = ProductModel.fromJson(response.data['data']);
      _products.insert(0, newProduct);

      _isLoading = false;
      notifyListeners();
      return newProduct;
    } on DioException catch (e) {
      _error = _handleDioError(e);
    } catch (e) {
      _error = 'Lỗi tạo sản phẩm: $e';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ========================================================================
  // 4. TẠO BIẾN THỂ TỰ ĐỘNG
  // ========================================================================
  Future<List<dynamic>?> generateVariants(
      int productId,
      List<Map<String, dynamic>> options, {
        String mode = 'replace',
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      final dto = {'options': options, 'mode': mode};

      final response = await _dio.post(
        ProductApi.generateVariants(productId), // ← DÙNG ENDPOINT
        data: dto,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _isLoading = false;
      notifyListeners();
      return response.data['data'];
    } on DioException catch (e) {
      _error = _handleDioError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ========================================================================
  // 5. LẤY DANH SÁCH BIẾN THỂ
  // ========================================================================
  Future<List<dynamic>?> listVariants(int productId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        ProductApi.variants(productId), // ← DÙNG ENDPOINT
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } on DioException catch (e) {
      _error = _handleDioError(e);
      notifyListeners();
      return null;
    }
  }

  // ========================================================================
  // 6. CẬP NHẬT MỘT BIẾN THỂ
  // ========================================================================
  Future<bool> updateVariant(
      int productId,
      int variantId,
      Map<String, dynamic> dto,
      ) async {
    try {
      final token = await _getToken();
      await _dio.patch(
        ProductApi.variant(productId, variantId), // ← DÙNG ENDPOINT
        data: dto,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      notifyListeners();
      return false;
    }
  }

  // ========================================================================
  // 7. LẤY CHI TIẾT 1 SẢN PHẨM
  // ========================================================================
  Future<ProductModel?> fetchProductDetail(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        ProductApi.byId(id), // ← DÙNG ENDPOINT
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _error = _handleDioError(e);
      notifyListeners();
      return null;
    }
  }

  // ========================================================================
  // 8. XỬ LÝ LỖI DIO (BẮT 401 → LOGOUT)
  // ========================================================================
  String _handleDioError(DioException e) {
    print('Dio Error: ${e.type} | Status: ${e.response?.statusCode}');
    print('URL: ${e.requestOptions.uri}');
    print('Response: ${e.response?.data}');

    // BẮT 401 → TỰ ĐỘNG LOGOUT
    if (e.response?.statusCode == 401) {
      final context = AuthProvider.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).logout();
      }
      return 'Phiên đăng nhập hết hạn. Đang đăng xuất...';
    }

    if (e.response != null) {
      final message = e.response?.data['message'];
      return message?.toString() ?? 'Lỗi server: ${e.response?.statusCode}';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối timeout. Vui lòng thử lại.';
    }

    return 'Không thể kết nối đến server. Kiểm tra mạng.';
  }

  // ========================================================================
  // 9. REFRESH & CLEAR
  // ========================================================================
  Future<void> refresh() => fetchProducts(showLoading: false);

  void clearError() {
    _error = null;
    notifyListeners();
  }
}