// File quản lý state cho danh sách sản phẩm
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  // Hàm tải dữ liệu mẫu (sau này thay bằng API)
  void loadSampleProducts() {
    _isLoading = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _products = [
        ProductModel(
          id: '1',
          name: 'Sản phẩm 1',
          description: 'Mô tả sản phẩm 1',
          price: 100.0,
          imageUrl: 'https://via.placeholder.com/150',
        ),
        ProductModel(
          id: '2',
          name: 'Sản phẩm 2',
          description: 'Mô tả sản phẩm 2',
          price: 200.0,
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}