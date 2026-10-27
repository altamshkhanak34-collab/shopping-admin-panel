class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String image;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}