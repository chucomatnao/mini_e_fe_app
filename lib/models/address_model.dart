class AddressModel {
  final int id;
  final String fullName;
  final String phone;
  final String formattedAddress;
  final bool isDefault;
  // Thêm toạ độ để dùng sau này (BE trả về string hoặc number)
  final double? lat;
  final double? lng;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.formattedAddress,
    required this.isDefault,
    this.lat,
    this.lng,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      formattedAddress: json['formattedAddress'] ?? '',

      // --- SỬA LỖI TẠI ĐÂY ---
      // Logic: Nếu giá trị là 1 hoặc true thì tính là true, ngược lại là false
      isDefault: json['isDefault'] == true || json['isDefault'] == 1,

      // Parse an toàn cho toạ độ (MySQL Decimal thường trả về String)
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
    );
  }

  // Payload gửi lên server (Server NestJS nhận bool hay number đều được nhờ DTO)
  Map<String, dynamic> toJsonCreate() {
    return {
      'fullName': fullName,
      'phone': phone,
      'formattedAddress': formattedAddress,
      'isDefault': isDefault,
      'lat': lat,
      'lng': lng,
    };
  }
}