class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? parentId;
  final bool isActive;
  final int sortOrder;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.parentId,
    required this.isActive,
    required this.sortOrder,
    this.children = const [],
  });

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1';
    }
    return false;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = (rawChildren is List)
        ? rawChildren
            .whereType<Map>()
            .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CategoryModel>[];

    final parentId = json['parentId'] ??
        (json['parent'] is Map ? (json['parent']['id']) : null);

    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: json['description']?.toString(),
      parentId: parentId == null ? null : (parentId as num).toInt(),
      isActive: _parseBool(json['isActive']),
      sortOrder:
          (json['sortOrder'] is num) ? (json['sortOrder'] as num).toInt() : 0,
      children: children,
    );
  }
}
