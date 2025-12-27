// lib/service/order_service.dart

import '../utils/app_constants.dart';
import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  // 1. Preview (BE trả data: { address, orders, summary })
  Future<OrderPreview> previewOrder({
    required int addressId,
    required List<int> itemIds,
  }) async {
    final response = await _apiClient.post(
      OrderApi.preview,
      data: {
        'addressId': addressId,
        'itemIds': itemIds,
      },
    );

    if (response.data['success'] == true) {
      final summary = response.data['data']['summary'];
      return OrderPreview.fromJson(summary);
    }

    throw Exception(response.data['message'] ?? 'Lỗi tính phí ship');
  }

  // 2. Create order
  // COD -> { orders: [...] }
  // VNPAY -> { session: {...}, paymentUrl: "..." }
  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    required List<int> itemIds,
    required String paymentMethod, // 'COD' | 'VNPAY'
    String? note,
  }) async {
    final response = await _apiClient.post(
      OrderApi.create,
      data: {
        'addressId': addressId,
        'itemIds': itemIds,
        'paymentMethod': paymentMethod,
        'note': note,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }

    throw Exception(response.data['message'] ?? 'Đặt hàng thất bại');
  }

  // 3. List orders
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 30}) async {
    final response = await _apiClient.get('${OrderApi.mine}?page=$page&limit=$limit');

    if (response.data['success'] == true) {
      final List<dynamic> listData = response.data['data']['items'];
      return listData.map((e) => OrderModel.fromJson(e)).toList();
    }

    throw Exception('Lỗi tải danh sách đơn hàng');
  }

  // 4. Detail
  Future<OrderModel> getOrderDetail(String orderId) async {
    final response = await _apiClient.get(OrderApi.detail(orderId));

    if (response.data['success'] == true) {
      return OrderModel.fromJson(response.data['data']);
    }

    throw Exception('Không tìm thấy đơn hàng');
  }
}
