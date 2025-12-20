import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../models/cart_model.dart';

class CartService {
  // --------------------------------------------------------
  // 1. LOGIC LẤY TOKEN (Đã sửa cho khớp với AuthProvider)
  // --------------------------------------------------------
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    // SỬA: Đổi từ 'accessToken' thành 'access_token' để khớp với AuthProvider
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      // Ném lỗi này để CartProvider hoặc UI bắt được và xử lý logout
      throw Exception('Unauthorized');
    }
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper tạo URL
  String _getUrl(String endpoint) {
    return '${AppConstants.baseUrl}$endpoint';
  }

  // --------------------------------------------------------
  // 2. CÁC HÀM GỌI API GIỎ HÀNG
  // --------------------------------------------------------

  // Lấy giỏ hàng
  Future<CartData?> getCart() async {
    try {
      final url = Uri.parse(_getUrl('/cart'));
      final headers = await _getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final res = CartResponse.fromJson(body);
        return res.data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized'); // Hết phiên đăng nhập
      } else {
        throw Exception('Lỗi tải giỏ hàng: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Thêm vào giỏ
  Future<CartData?> addToCart({required int productId, int? variantId, int quantity = 1}) async {
    final url = Uri.parse(_getUrl('/cart/items'));
    final headers = await _getHeaders();
    final body = jsonEncode({
      'productId': productId,
      'variantId': variantId,
      'quantity': quantity,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CartResponse.fromJson(jsonDecode(response.body));
      return res.data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Lỗi thêm vào giỏ');
    }
  }

  // Cập nhật số lượng
  Future<CartData?> updateItemQuantity(int itemId, int quantity) async {
    final url = Uri.parse(_getUrl('/cart/items/$itemId'));
    final headers = await _getHeaders();
    final body = jsonEncode({'quantity': quantity});

    final response = await http.patch(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final res = CartResponse.fromJson(jsonDecode(response.body));
      return res.data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Lỗi cập nhật giỏ hàng');
    }
  }

  // Xóa sản phẩm
  Future<CartData?> removeItem(int itemId) async {
    final url = Uri.parse(_getUrl('/cart/items/$itemId'));
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      final res = CartResponse.fromJson(jsonDecode(response.body));
      return res.data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Lỗi xóa sản phẩm');
    }
  }
}