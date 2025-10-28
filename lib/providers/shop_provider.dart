import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../service/shop_service.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _service = ShopService();

  Shop? _shop;
  bool _loading = false;
  String? _error;

  Shop? get shop => _shop;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadMyShop(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _shop = await _service.getMy(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(Map<String, dynamic> data, String token) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _shop = await _service.register(data, token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Map<String, dynamic> data, String token) async {
    if (_shop == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _shop = await _service.update(_shop!.id, data, token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String token) async {
    if (_shop == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.delete(_shop!.id, token);
      _shop = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}