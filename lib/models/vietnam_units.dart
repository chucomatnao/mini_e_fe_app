class LocationItem {
  final String id;
  final String name;
  final String fullName;

  LocationItem({required this.id, required this.name, required this.fullName});

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'] ?? json['name'],
    );
  }
}