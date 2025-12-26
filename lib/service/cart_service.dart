import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../models/cart_model.dart';

class CartService {
  // --------------------------------------------------------
  // 1. LẤY TOKEN (đã khớp AuthProvider)
  // --------------------------------------------------------
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
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

  String _getUrl(String endpoint) => '${AppConstants.baseUrl}$endpoint';

  // --------------------------------------------------------
  // 2. API GIỎ HÀNG
  // --------------------------------------------------------

  // 🛒 Lấy giỏ hàng
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
        throw Exception('Unauthorized');
      } else {
        throw Exception('Lỗi tải giỏ hàng: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 🛒 Thêm sản phẩm vào giỏ
  Future<CartData?> addToCart({
    required int productId,
    int? variantId, // ✅ cho phép null
    int quantity = 1,
  }) async {
    final url = Uri.parse(_getUrl('/cart/items'));
    final headers = await _getHeaders();

    // ✅ chỉ thêm variantId nếu có giá trị
    final Map<String, dynamic> body = {
      'productId': productId,
      'quantity': quantity,
      if (variantId != null) 'variantId': variantId,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = CartResponse.fromJson(jsonDecode(response.body));
      return res.data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Lỗi thêm vào giỏ');
      } catch (_) {
        throw Exception('Lỗi thêm vào giỏ (${response.statusCode})');
      }
    }
  }

  // 🛒 Cập nhật số lượng
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
      throw Exception('Lỗi cập nhật giỏ hàng (${response.statusCode})');
    }
  }

  // 🛒 Xóa 1 sản phẩm
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
      throw Exception('Lỗi xóa sản phẩm (${response.statusCode})');
    }
  }

  // 🧹 Xóa sạch giỏ hàng
  Future<CartData?> clearCart() async {
    final url = Uri.parse(_getUrl('/cart'));
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      final res = CartResponse.fromJson(jsonDecode(response.body));
      return res.data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Lỗi làm sạch giỏ hàng (${response.statusCode})');
    }
  }
}
