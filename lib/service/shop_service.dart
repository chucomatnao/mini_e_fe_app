// lib/service/shop_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/shop_model.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';

class ShopService {
  final ApiClient _api = ApiClient(); // Singleton

  // ==================== REGISTER ====================
  Future<ShopModel> register(Map<String, dynamic> data) async {
    final resp = await _api.post(ShopsApi.register, data: data);
    _throwIfError(resp);
    return ShopModel.fromJson(resp.data['data']);
  }

  // ==================== MY SHOP ====================
  Future<ShopModel> getMyShop() async {
    final resp = await _api.get(ShopsApi.myShop);
    _throwIfError(resp);
    return ShopModel.fromJson(resp.data['data']);
  }

  // ==================== UPDATE ====================
  Future<ShopModel> update(int shopId, Map<String, dynamic> data) async {
    final resp = await _api.patch(ShopsApi.byId('$shopId'), data: data);
    _throwIfError(resp);
    return ShopModel.fromJson(resp.data['data']);
  }

  // ==================== DELETE ====================
  Future<void> delete(int shopId) async {
    final resp = await _api.delete(ShopsApi.byId('$shopId'));
    _throwIfError(resp);
  }

  // ==================== CHECK NAME ====================
  Future<bool> checkName(String name) async {
    final resp = await _api.get(
      ShopsApi.checkName,
      queryParameters: {'name': name},
    );
    _throwIfError(resp);
    return resp.data['data']['exists'] as bool;
  }

  // ==================== LIST SHOPS ====================
  Future<List<ShopModel>> getShops({
    String? q,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> qp = {
      'page': page,
      'limit': limit,
      if (q != null && q.isNotEmpty) 'q': q,
      if (status != null) 'status': status,
    };

    final resp = await _api.get(ShopsApi.shops, queryParameters: qp);
    _throwIfError(resp);

    final List items = resp.data['data']['items'];
    return items.map((e) => ShopModel.fromJson(e)).toList();
  }

  // ==================== HELPER ====================
  void _throwIfError(Response resp) {
    if (resp.statusCode! >= 400) {
      final message = resp.data['message'] ?? 'Lỗi không xác định';
      throw Exception(message);
    }
  }
}