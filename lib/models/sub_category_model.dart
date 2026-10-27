class SubCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String categoryName;
  final String image;
  final bool isActive;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.categoryName,
    required this.image,
    required this.isActive,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    // Populate object handling
    String catId = '';
    String catName = '';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        catId = json['category']['_id'] ?? '';
        catName = json['category']['name'] ?? '';
      } else {
        catId = json['category'].toString();
      }
    }

    return SubCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      categoryId: catId,
      categoryName: catName,
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}