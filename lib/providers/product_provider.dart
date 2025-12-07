// lib/providers/product_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../utils/app_constants.dart';

import 'auth_provider.dart';

/// ---------------------------------------------------------------------------
/// PRODUCT PROVIDER – QUẢN LÝ SẢN PHẨM & GỌI API
/// ĐÃ CẬP NHẬT:
/// • Hỗ trợ upload ảnh Mobile (File) + Web (Uint8List)
/// • THÊM: deleteProduct() – XÓA THẬT
/// • THÊM: updateProduct() – CHỈNH SỬA THẬT
/// ---------------------------------------------------------------------------
class ProductProvider with ChangeNotifier {
  // ====================== DIO CLIENT ======================
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
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
    // Có thể thêm interceptor nếu cần
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
  // 2. LẤY DANH SÁCH SẢN PHẨM (PAGINATION)
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
        ProductApi.products,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('DEBUG: Response data: ${response.data}');

      dynamic data = response.data['data'];
      List<dynamic> rawList;

      if (data is Map) {
        rawList = data['items'] ?? [];
        print('DEBUG: Extracted items from pagination: ${rawList.length}');
      } else if (data is List) {
        rawList = data;
      } else {
        rawList = [];
      }

      final List<ProductModel> parsedProducts = [];
      for (final item in rawList) {
        try {
          if (item is Map<String, dynamic>) {
            parsedProducts.add(ProductModel.fromJson(item));
          }
        } catch (parseError) {
          print('DEBUG: Parse error for item $item: $parseError');
        }
      }

      _products = parsedProducts;
      print('DEBUG: Parsed products count: ${_products.length}');

      _isLoading = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = _handleDioError(e);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('DEBUG: Unexpected error in fetchProducts: $e');
      _error = 'Lỗi không mong muốn: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========================================================================
  // 3. TẠO SẢN PHẨM MỚI – HỖ TRỢ MOBILE + WEB
  // ========================================================================
  Future<ProductModel?> createProduct({
    required String title,
    required double price,
    int? stock,
    String? description,
    String? slug,
    List<File>? images,
    List<Uint8List>? imageBytes,
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

      if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
        for (int i = 0; i < imageBytes.length; i++) {
          final bytes = imageBytes[i];
          formData.files.add(MapEntry(
            'images',
            MultipartFile.fromBytes(
              bytes,
              filename: 'image_$i.jpg',
            ),
          ));
        }
        print('DEBUG: Uploading ${imageBytes.length} images via Web (Uint8List)');
      } else if (images != null && images.isNotEmpty) {
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
        print('DEBUG: Uploading ${images.length} images via Mobile (File)');
      }

      final response = await _dio.post(
        ProductApi.products,
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );

      final newProduct = ProductModel.fromJson(response.data['data']);
      _products.insert(0, newProduct);

      _isLoading = false;
      notifyListeners();
      return newProduct;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      print('Dio Error in createProduct: ${e.response?.data}');
    } catch (e) {
      _error = 'Lỗi tạo sản phẩm: $e';
      print('Error in createProduct: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // ========================================================================
// 4. CẬP NHẬT SẢN PHẨM – HOÀN HẢO, CHẠY NGON VỚI BACKEND HIỆN TẠI
// ========================================================================
  Future<bool> updateProduct({
    required int productId,
    required String title,
    required double price,
    int? stock,
    String? description,
    String? slug,
    List<File>? images,
    List<Uint8List>? imageBytes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();

      // Xác định có ảnh mới không
      final hasNewImages = (kIsWeb && imageBytes?.isNotEmpty == true) ||
          (!kIsWeb && images?.isNotEmpty == true);

      if (!hasNewImages) {
        // GỬI JSON (không có ảnh) – HOẠT ĐỘNG BÌNH THƯỜNG
        final jsonBody = <String, dynamic>{
          'title': title,
          'price': price,
          if (stock != null) 'stock': stock,
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
        };

        print('DEBUG: Sending JSON update: $jsonBody');

        final response = await _dio.patch(
          ProductApi.byId(productId),
          data: jsonBody,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
        );

        final updatedProduct = ProductModel.fromJson(response.data['data']);
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) _products[index] = updatedProduct;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // GỬI FORM-DATA (có ảnh) – ĐÃ SỬA ĐÚNG 100% CHO BACKEND "KÉN CỬA"
        final formData = FormData();

        // QUAN TRỌNG: Dùng cách add fields kiểu cũ (backend bạn chỉ nhận được khi dùng cách này)
        formData.fields
          ..add(MapEntry('title', title))
          ..add(MapEntry('price', price.toString()))
          ..addAll([
            if (stock != null) MapEntry('stock', stock.toString()),
            if (description != null && description.trim().isNotEmpty)
              MapEntry('description', description.trim()),
            if (slug != null && slug.trim().isNotEmpty)
              MapEntry('slug', slug.trim()),
          ]);

        // Thêm ảnh – đúng tên field 'images'
        if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
          for (var i = 0; i < imageBytes.length; i++) {
            formData.files.add(MapEntry(
              'images',
              MultipartFile.fromBytes(
                imageBytes[i],
                filename: 'image_$i.jpg',
              ),
            ));
          }
        }

        if (!kIsWeb && images != null && images.isNotEmpty) {
          for (var i = 0; i < images.length; i++) {
            formData.files.add(MapEntry(
              'images',
              await MultipartFile.fromFile(
                images[i].path,
                filename: 'image_$i.jpg',
              ),
            ));
          }
        }

        print('DEBUG: Sending FormData với ${formData.files.length} ảnh');
        print('DEBUG: Fields: ${formData.fields.map((e) => '${e.key}: ${e.value}')}');

        final response = await _dio.patch(
          ProductApi.byId(productId),
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              // BẮT BUỘC KHÔNG ĐƯỢC ĐỂ DIO TỰ SET CONTENT-TYPE KHI DÙNG formData.fields.add()
              // → Nếu để trống thì Dio sẽ gửi đúng boundary → backend nhận được
            },
          ),
        );

        final updatedProduct = ProductModel.fromJson(response.data['data']);
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) _products[index] = updatedProduct;

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = _handleDioError(e);
      print('Dio Error in updateProduct: ${e.response?.data}');
      print('Request data: ${e.requestOptions.data}');
    } catch (e) {
      _error = 'Lỗi cập nhật: $e';
      print('Error in updateProduct: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ========================================================================
  // 5. TẠO BIẾN THỂ TỰ ĐỘNG
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
        ProductApi.generateVariants(productId),
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
  // 6. LẤY DANH SÁCH BIẾN THỂ
  // ========================================================================
  Future<List<dynamic>?> listVariants(int productId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        ProductApi.variants(productId),
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
  // 7. CẬP NHẬT MỘT BIẾN THỂ
  // ========================================================================
  Future<bool> updateVariant(
      int productId,
      int variantId,
      Map<String, dynamic> dto,
      ) async {
    try {
      final token = await _getToken();
      await _dio.patch(
        ProductApi.variant(productId, variantId),
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
  // 8. LẤY CHI TIẾT 1 SẢN PHẨM
  // ========================================================================
  Future<ProductModel?> fetchProductDetail(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        ProductApi.byId(id),
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
  // 9. XÓA SẢN PHẨM
  // ========================================================================
  Future<bool> deleteProduct(int productId) async {
    try {
      final token = await _getToken();

      await _dio.delete(
        ProductApi.byId(productId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _products.removeWhere((p) => p.id == productId);
      notifyListeners();

      print('DEBUG: Đã xóa sản phẩm ID=$productId');
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      print('Dio Error in deleteProduct: ${e.response?.data}');
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Lỗi xóa sản phẩm: $e';
      print('Error in deleteProduct: $e');
      notifyListeners();
      return false;
    }
  }

  // ========================================================================
  // 10. XỬ LÝ LỖI DIO (BẮT 401 → LOGOUT)
  // ========================================================================
  String _handleDioError(DioException e) {
    print('Dio Error: ${e.type} | Status: ${e.response?.statusCode}');
    print('URL: ${e.requestOptions.uri}');
    print('Response: ${e.response?.data}');

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
  // 11. REFRESH & CLEAR
  // ========================================================================
  Future<void> refresh() => fetchProducts(showLoading: false);
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========================================================================
  //  12. XÓA MỘT BIẾN THỂ (DELETE)
  // Khớp với: ProductApi.variant(productId, variantId)
  // ========================================================================
  Future<bool> deleteVariant(int productId, int variantId) async {
    try {
      final token = await _getToken();

      // Gọi API DELETE /products/{id}/variants/{variantId}
      await _dio.delete(
        ProductApi.variant(productId, variantId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('DEBUG: Đã xóa variant ID=$variantId thành công');
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      print('Dio Error deleteVariant: ${e.response?.data}');
      notifyListeners();
      return false;
    } catch (e) {
      print('Error deleteVariant: $e');
      return false;
    }
  }

  // ========================================================================
  // 13. TẠO MỘT BIẾN THỂ THỦ CÔNG (CREATE SINGLE)
  // Khớp với: ProductApi.variants(productId)
  // ========================================================================
  Future<dynamic> createVariant(int productId, Map<String, dynamic> dto) async {
    try {
      final token = await _getToken();

      // Gọi API POST /products/{id}/variants
      // Dùng endpoint danh sách (variants) với method POST để tạo mới 1 item
      final response = await _dio.post(
        ProductApi.variants(productId),
        data: dto,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('DEBUG: Tạo variant thủ công thành công: ${response.data}');
      notifyListeners();

      // Trả về data của variant mới tạo (để UI cập nhật ID mới vào list)
      // Giả sử backend trả về: { "data": { "id": 123, "name": "..." }, ... }
      return response.data['data'];
    } on DioException catch (e) {
      _error = _handleDioError(e);
      print('Dio Error createVariant: ${e.response?.data}');
      notifyListeners();
      return null;
    } catch (e) {
      print('Error createVariant: $e');
      return null;
    }
  }

  // ========================================================================
// 14. CẬP NHẬT CHỈ TRẠNG THÁI SẢN PHẨM (DRAFT ↔ ACTIVE)
// ========================================================================
  Future<bool> updateProductStatus({
    required int productId,
    required String status,
  }) async {
    try {
      final token = await _getToken();

      final response = await _dio.patch(
        ProductApi.byId(productId),
        data: {'status': status},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      final updatedProduct = ProductModel.fromJson(response.data['data']);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }

      print('DEBUG: Đã cập nhật trạng thái sản phẩm $productId → $status');
      return true;
    } on DioException catch (e) {
      _error = _handleDioError(e);
      print('Dio Error updateProductStatus: ${e.response?.data}');
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Lỗi cập nhật trạng thái: $e';
      print('Error updateProductStatus: $e');
      notifyListeners();
      return false;
    }
  }

// ========================================================================
// 15. ĐẢO TRẠNG THÁI TỰ ĐỘNG
// ========================================================================
  Future<bool> toggleProductStatus(int productId) async {
    final product = _products.firstWhere(
          (p) => p.id == productId,
      orElse: () => ProductModel(id: productId, title: '', price: 0, imageUrl: '', shopId: 0),
    );

    final newStatus = product.status == 'ACTIVE' ? 'DRAFT' : 'ACTIVE';
    return await updateProductStatus(productId: productId, status: newStatus);
  }

}