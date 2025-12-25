// lib/service/order_service.dart

import '../utils/app_constants.dart';
import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  // 1. Xem trước đơn hàng
  Future<OrderPreview> previewOrder({
    required int addressId,
    required List<int> itemIds,
  }) async {
    try {
      // SỬA LỖI: Dùng tham số 'data' thay vì 'body' (Dio dùng data)
      final response = await _apiClient.post(
        OrderApi.preview,
        data: {
          'addressId': addressId,
          'itemIds': itemIds,
        },
      );

      // SỬA LỖI: Truy cập qua response.data
      if (response.data['success'] == true) {
        return OrderPreview.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Lỗi tính phí ship');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. Tạo đơn hàng
  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    required List<int> itemIds,
    required String paymentMethod, // 'COD' | 'VNPAY'
    String? note,
  }) async {
    try {
      // SỬA LỖI: Dùng tham số 'data' thay vì 'body'
      final response = await _apiClient.post(
        OrderApi.create,
        data: {
          'addressId': addressId,
          'itemIds': itemIds,
          'paymentMethod': paymentMethod,
          'note': note,
        },
      );

      // SỬA LỖI: Truy cập qua response.data
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Đặt hàng thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 3. Lấy danh sách đơn hàng
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('${OrderApi.mine}?page=$page&limit=$limit');

      // SỬA LỖI: Truy cập qua response.data
      if (response.data['success'] == true) {
        final List<dynamic> listData = response.data['data']['items'];
        return listData.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi tải danh sách đơn hàng');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. Chi tiết đơn hàng
  Future<OrderModel> getOrderDetail(String orderId) async {
    try {
      final response = await _apiClient.get(OrderApi.detail(orderId));

      // SỬA LỖI: Truy cập qua response.data
      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        throw Exception('Không tìm thấy đơn hàng');
      }
    } catch (e) {
      rethrow;
    }
  }
}