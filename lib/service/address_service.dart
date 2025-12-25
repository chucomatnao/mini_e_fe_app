import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';
import '../models/address_model.dart';

class AddressService {
  // Helper để tạo headers (có token)
  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // 1. Lấy danh sách địa chỉ
  // GET: /api/addresses
  Future<List<AddressModel>> fetchAddresses(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AddressApi.list}');

    final response = await http.get(url, headers: _headers(token));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List<dynamic> data = body['data'];
        return data.map((e) => AddressModel.fromJson(e)).toList();
      }
    }
    throw Exception('Không thể tải danh sách địa chỉ: ${response.statusCode}');
  }

  // 2. Thêm mới địa chỉ
  // POST: /api/addresses
  Future<void> createAddress(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AddressApi.list}');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Lỗi khi thêm địa chỉ: ${response.body}');
    }
  }

  // 3. Cập nhật địa chỉ
  // PATCH: /api/addresses/:id
  Future<void> updateAddress(String token, int id, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AddressApi.byId(id)}');

    final response = await http.patch(
      url,
      headers: _headers(token),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi cập nhật địa chỉ: ${response.body}');
    }
  }

  // 4. Xóa địa chỉ
  // DELETE: /api/addresses/:id
  Future<void> deleteAddress(String token, int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AddressApi.byId(id)}');

    final response = await http.delete(url, headers: _headers(token));

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa địa chỉ: ${response.body}');
    }
  }

  // 5. Thiết lập địa chỉ mặc định
  // PATCH: /api/addresses/:id/set-default
  Future<void> setDefault(String token, int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AddressApi.setDefault(id)}');

    final response = await http.patch(url, headers: _headers(token));

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi đặt mặc định: ${response.body}');
    }
  }
}