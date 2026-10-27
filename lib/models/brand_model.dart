class BrandModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String logo;
  final bool isActive;

  BrandModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.logo,
    required this.isActive,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}