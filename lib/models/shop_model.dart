class Shop {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Shop({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.logoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
    address: json['address'] as String?,
    logoUrl: json['logoUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'address': address,
    'logoUrl': logoUrl,
  };
}