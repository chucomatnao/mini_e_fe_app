// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../service/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  String? _errorMessage;
  OrderPreview? _orderPreview;
  List<OrderModel> _myOrders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderPreview? get orderPreview => _orderPreview;
  List<OrderModel> get myOrders => _myOrders;

  // Preview
  Future<void> previewOrder(int addressId, List<int> itemIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orderPreview = await _orderService.previewOrder(addressId: addressId, itemIds: itemIds);
    } catch (e) {
      _errorMessage = e.toString();
      _orderPreview = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Order
  Future<Map<String, dynamic>?> placeOrder({
    required int addressId,
    required List<int> itemIds,
    required String paymentMethod,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _orderService.createOrder(
        addressId: addressId,
        itemIds: itemIds,
        paymentMethod: paymentMethod,
        note: note,
      );

      // COD sẽ có order ngay -> refresh list
      // VNPAY thì order chỉ xuất hiện sau khi finalize -> refresh cũng không sao
      fetchMyOrders();

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // List Orders
  Future<void> fetchMyOrders({bool refresh = false}) async {
    if (refresh) {
      _myOrders = [];
      _isLoading = true;
      notifyListeners();
    }

    try {
      _myOrders = await _orderService.getMyOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Polling theo orderId (COD / hoặc dùng khi bạn đã có id)
  Future<bool> checkOrderStatus(String orderId) async {
    try {
      final order = await _orderService.getOrderDetail(orderId);
      return order.paymentStatus == 'PAID' || order.status == 'PAID' || order.status == 'COMPLETED';
    } catch (_) {
      return false;
    }
  }

  // ✅ Polling theo sessionCode (VNPAY - KHÔNG sửa BE)
  // Vì VNPAY create chưa có order, order chỉ xuất hiện sau finalize.
  Future<bool> checkPaidBySessionCode(String sessionCode) async {
    try {
      final list = await _orderService.getMyOrders(page: 1, limit: 50);

      for (final o in list) {
        if (o.sessionCode == sessionCode) {
          if (o.paymentStatus == 'PAID' || o.status == 'PAID' || o.status == 'COMPLETED') {
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
