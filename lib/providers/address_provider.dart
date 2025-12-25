import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../service/address_service.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _addresses = await _service.fetchAddresses(token);
    } catch (e) {
      print(e);
      _addresses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String token, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createAddress(token, data);
      await fetchAddresses(token); // Tải lại danh sách sau khi thêm
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> updateAddress(String token, int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Gọi service update (đã viết ở bước trước)
      await _service.updateAddress(token, id, data);

      // Nếu người dùng có tick chọn "Mặc định" lúc sửa, gọi thêm API set default
      if (data['isDefault'] == true) {
        await _service.setDefault(token, id);
      }

      await fetchAddresses(token); // Tải lại danh sách mới
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  Future<void> deleteAddress(String token, int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteAddress(token, id);
      // Sau khi xóa xong, tải lại danh sách để UI cập nhật
      await fetchAddresses(token);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}