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
      // Refresh list ngầm
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

  // Check Status (Helper cho polling)
  Future<bool> checkOrderStatus(String orderId) async {
    try {
      final order = await _orderService.getOrderDetail(orderId);
      // Nếu trạng thái là PAID -> return true
      return order.paymentStatus == 'PAID' || order.status == 'PAID';
    } catch (_) {
      return false;
    }
  }
}