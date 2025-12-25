import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Import HTTP
import 'dart:convert'; // Import convert

import '../../models/address_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../widgets/vietnam_address_selector.dart';
import '../../widgets/osm_location_picker.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const AddAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  // THÊM: Controller riêng cho chi tiết địa chỉ để đồng bộ
  final TextEditingController _detailAddressController = TextEditingController();

  String _finalFormattedAddress = '';
  double? _lat;
  double? _lng;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');

    // Nếu là edit, điền sẵn địa chỉ vào ô chi tiết
    if (widget.address != null) {
      _detailAddressController.text = widget.address!.formattedAddress.split(',')[0];
    }

    _finalFormattedAddress = widget.address?.formattedAddress ?? '';
    _lat = widget.address?.lat;
    _lng = widget.address?.lng;
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailAddressController.dispose(); // Nhớ dispose
    super.dispose();
  }

  // --- LOGIC MỚI: Map -> Address (Reverse Geocoding) ---
  Future<void> _updateAddressFromCoordinates(double lat, double lng) async {
    // 1. Cập nhật biến tọa độ để lưu server
    setState(() {
      _lat = lat;
      _lng = lng;
    });

    // 2. Gọi API lấy tên đường
    final url = "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json";
    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'FlutterApp/1.0'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'];

        if (displayName != null) {
          setState(() {
            // Cập nhật ô nhập liệu để người dùng thấy
            _detailAddressController.text = displayName;
            // Cập nhật giá trị cuối cùng
            _finalFormattedAddress = displayName;
          });
        }
      }
    } catch (e) {
      print("Lỗi reverse geocode: $e");
    }
  }
  // -----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context);
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Cập nhật địa chỉ' : 'Thêm địa chỉ mới')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập SĐT' : null,
                ),
                const SizedBox(height: 20),
                const Text("Địa chỉ:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Selector nhận controller và trả về tọa độ
                VietnamAddressSelector(
                  addressController: _detailAddressController, // Truyền controller
                  onAddressChanged: (fullAddr) {
                    setState(() {
                      _finalFormattedAddress = fullAddr;
                    });
                  },
                  onCoordinatesChanged: (lat, lng) {
                    // Khi chọn Dropdown -> Cập nhật tọa độ -> Map tự bay đến (nhờ didUpdateWidget)
                    setState(() {
                      _lat = lat;
                      _lng = lng;
                    });
                  },
                ),

                const SizedBox(height: 20),
                const Text("Ghim vị trí trên bản đồ:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Map nhận tọa độ và trả về sự kiện click
                OsmLocationPicker(
                  initLat: _lat,
                  initLng: _lng,
                  onPicked: (lat, lng) {
                    // Khi click map -> Tìm tên đường -> Điền vào Selector
                    _updateAddressFromCoordinates(lat, lng);
                  },
                ),

                const SizedBox(height: 16),
                if (widget.address?.isDefault != true)
                  SwitchListTile(
                    title: const Text('Đặt làm địa chỉ mặc định'),
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val),
                  ),
                const SizedBox(height: 24),

                // Nút Lưu (Logic cũ giữ nguyên)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addressProvider.isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        // ... (Logic lưu server giữ nguyên)
                        // Đảm bảo dùng _lat, _lng, _finalFormattedAddress mới nhất
                        try {
                          final data = {
                            'fullName': _nameController.text.trim(),
                            'phone': _phoneController.text.trim(),
                            'formattedAddress': _finalFormattedAddress,
                            'isDefault': _isDefault,
                            'lat': _lat,
                            'lng': _lng,
                          };
                          if (isEditing) {
                            await addressProvider.updateAddress(auth.accessToken!, widget.address!.id, data);
                          } else {
                            await addressProvider.addAddress(auth.accessToken!, data);
                          }
                          if (mounted) Navigator.pop(context);
                        } catch(e) { /*...*/ }
                      }
                    },
                    child: Text(isEditing ? 'Cập Nhật' : 'Lưu Địa Chỉ'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}