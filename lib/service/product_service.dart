// lib/service/product_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../service/api_client.dart'; // Đảm bảo đường dẫn đúng tới file api_client.dart bạn mới tạo
import '../utils/app_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _api;

  // Constructor nhận ApiClient từ bên ngoài (để dùng chung Token)
  ProductService(this._api);

  // ===========================================================================
  // 1. PUBLIC: Lấy danh sách sản phẩm
  // ===========================================================================
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    int? shopId,
    int? categoryId,
    String? sortBy = 'createdAt',
    String? sortOrder = 'DESC',
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (shopId != null) 'shopId': shopId,
        if (categoryId != null) 'categoryId': categoryId,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final response = await _api.get(
        ProductApi.products,
        queryParameters: query,
      );

      final List<dynamic> items = response.data['data']['items'];
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi tải sản phẩm: $e');
    }
  }

  // ===========================================================================
  // 2. CHI TIẾT SẢN PHẨM
  // ===========================================================================
  Future<ProductModel> getProductById(int productId) async {
    try {
      final response = await _api.get(ProductApi.byId(productId));
      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Không tìm thấy sản phẩm: $e');
    }
  }

  // ===========================================================================
  // 3. SELLER: Tạo sản phẩm mới (Hỗ trợ Upload File ảnh trực tiếp)
  // ===========================================================================
  Future<ProductModel> createProduct({
    required int shopId,
    required String title,
    required String slug,
    String? description,
    required double price,
    double? compareAtPrice,
    required int stock,
    String status = 'DRAFT',
    List<File>? images, // Thay List<String> imageUrls thành List<File>
    Map<String, dynamic>? optionSchema,
  }) async {
    try {
      final formData = FormData();

      // Thêm các trường text
      formData.fields.addAll([
        MapEntry('shopId', shopId.toString()),
        MapEntry('title', title),
        MapEntry('slug', slug),
        MapEntry('price', price.toString()),
        MapEntry('stock', stock.toString()),
        MapEntry('status', status),
      ]);

      if (description != null) formData.fields.add(MapEntry('description', description));
      if (compareAtPrice != null) formData.fields.add(MapEntry('compareAtPrice', compareAtPrice.toString()));

      // Xử lý optionSchema (nếu backend nhận JSON string)
      // Nếu backend nhận object lồng nhau trong FormData thì cần cách xử lý khác,
      // nhưng thường gửi dạng chuỗi JSON là an toàn nhất với FormData.
      // Tuy nhiên, nếu API generateVariants làm việc riêng thì chỗ này có thể bỏ qua optionSchema
      // tùy thuộc vào logic backend của bạn.

      // Xử lý Ảnh (Multiple Files)
      if (images != null && images.isNotEmpty) {
        for (var file in images) {
          String fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'images', // Key này phải khớp với upload middleware của backend (vd: upload.array('images'))
            await MultipartFile.fromFile(file.path, filename: fileName),
          ));
        }
      }

      final response = await _api.post(
        ProductApi.products,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Tạo sản phẩm thất bại: $e');
    }
  }

  // ===========================================================================
  // 4. SELLER / ADMIN: Cập nhật sản phẩm
  // ===========================================================================
  Future<ProductModel> updateProduct(
      int productId, {
        String? title,
        String? slug,
        String? description,
        double? price,
        double? compareAtPrice,
        int? stock,
        String? status,
        List<File>? newImages, // Ảnh mới muốn thêm
        List<String>? keepImageUrls, // Danh sách URL ảnh cũ muốn giữ lại (nếu logic backend hỗ trợ)
      }) async {
    try {
      final formData = FormData();

      if (title != null) formData.fields.add(MapEntry('title', title));
      if (slug != null) formData.fields.add(MapEntry('slug', slug));
      if (description != null) formData.fields.add(MapEntry('description', description));
      if (price != null) formData.fields.add(MapEntry('price', price.toString()));
      if (compareAtPrice != null) formData.fields.add(MapEntry('compareAtPrice', compareAtPrice.toString()));
      if (stock != null) formData.fields.add(MapEntry('stock', stock.toString()));
      if (status != null) formData.fields.add(MapEntry('status', status));

      // Upload ảnh mới
      if (newImages != null && newImages.isNotEmpty) {
        for (var file in newImages) {
          String fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ));
        }
      }

      final response = await _api.patch(
        ProductApi.byId(productId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return ProductModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Cập nhật thất bại: $e');
    }
  }

  // ===========================================================================
  // 5. QUẢN LÝ BIẾN THỂ (VARIANTS) - PHẦN MỚI THÊM QUAN TRỌNG
  // ===========================================================================

  // Lấy danh sách biến thể
  Future<List<dynamic>> getVariants(int productId) async {
    try {
      final response = await _api.get(ProductApi.variants(productId));
      // Trả về list raw json hoặc map sang Model nếu bạn có VariantModel
      return response.data['data'];
    } catch (e) {
      throw Exception('Lỗi lấy biến thể: $e');
    }
  }

  // Sinh biến thể tự động (Generate)
  Future<List<dynamic>> generateVariants(int productId, Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        ProductApi.generateVariants(productId),
        data: data, // { "options": [...], "mode": "replace" }
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Lỗi sinh biến thể: $e');
    }
  }

  // Tạo 1 biến thể thủ công
  Future<dynamic> createVariant(int productId, Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        ProductApi.variants(productId),
        data: data,
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Lỗi tạo biến thể: $e');
    }
  }

  // Cập nhật 1 biến thể
  Future<bool> updateVariant(int productId, int variantId, Map<String, dynamic> data) async {
    try {
      await _api.patch(
        ProductApi.variant(productId, variantId),
        data: data,
      );
      return true;
    } catch (e) {
      throw Exception('Lỗi cập nhật biến thể: $e');
    }
  }

  // Xóa 1 biến thể
  Future<bool> deleteVariant(int productId, int variantId) async {
    try {
      await _api.delete(ProductApi.variant(productId, variantId));
      return true;
    } catch (e) {
      throw Exception('Lỗi xóa biến thể: $e');
    }
  }

  // ===========================================================================
  // 6. XÓA MỀM & KHÔI PHỤC SẢN PHẨM (ADMIN)
  // ===========================================================================
  Future<void> deleteProduct(int productId) async {
    try {
      await _api.delete(ProductApi.byId(productId));
    } catch (e) {
      throw Exception('Xóa sản phẩm thất bại: $e');
    }
  }

  Future<List<ProductModel>> getDeletedProducts({int limit = 50}) async {
    try {
      final response = await _api.get(
        '${ProductApi.products}/deleted', // Đảm bảo URL khớp backend
        queryParameters: {'limit': limit},
      );
      final List<dynamic> items = response.data['data']['items'];
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi tải sản phẩm đã xóa: $e');
    }
  }

  Future<void> restoreProduct(int productId) async {
    try {
      await _api.post('${ProductApi.byId(productId)}/restore'); // Hoặc patch tùy backend
    } catch (e) {
      throw Exception('Khôi phục thất bại: $e');
    }
  }
}