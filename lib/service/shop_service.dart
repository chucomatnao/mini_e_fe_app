import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop_model.dart';
import '../utils/app_constants.dart';

class ShopService {
  final String _base = '${AppConstants.baseUrl}/shops';

  Future<Shop> register(Map<String, dynamic> data, String token) async {
    final uri = Uri.parse('$_base/register');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    _check(resp);
    return Shop.fromJson(jsonDecode(resp.body)['data']);
  }

  Future<Shop?> getMy(String token) async {
    final uri = Uri.parse('$_base/me');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 404) return null;          // chưa có shop
    _check(resp);
    return Shop.fromJson(jsonDecode(resp.body)['data']);
  }

  Future<Shop> update(int id, Map<String, dynamic> data, String token) async {
    final uri = Uri.parse('$_base/$id');
    final resp = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    _check(resp);
    return Shop.fromJson(jsonDecode(resp.body)['data']);
  }

  Future<void> delete(int id, String token) async {
    final uri = Uri.parse('$_base/$id');
    final resp = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    _check(resp);
  }

  void _check(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final msg = jsonDecode(resp.body)['message'] ?? 'Lỗi không xác định';
      throw Exception(msg);
    }
  }
}