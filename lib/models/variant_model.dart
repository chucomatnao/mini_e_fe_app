// lib/models/variant_model.dart
class VariantModel {
  final String name;
  final List<String> options;

  VariantModel({
    required this.name,
    required this.options,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      name: json['name']?.toString() ?? '',
      options: (json['values'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'options': options,
    };
  }
}