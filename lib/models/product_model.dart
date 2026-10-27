class ColorOption {
  final String name;
  final String hexCode;
  final List<String> images;

  ColorOption({
    required this.name,
    required this.hexCode,
    required this.images,
  });

  factory ColorOption.fromJson(Map<String, dynamic> json) {
    return ColorOption(
      name: json['name'] ?? '',
      hexCode: json['hexCode'] ?? '#000000',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'hexCode': hexCode,
    'images': images,
  };
}

class ProductModel {
  final String id;
  final String title;
  final String slug;
  final String description;
  final double price;
  final double originalPrice;
  final double costPrice; // 👈 1. Declare here
  final double discountPercentage;
  final List<String> images;
  final String thumbnail;
  final List<String> sizes;
  final List<ColorOption> colors;
  final String? brandId;
  final String categorySlug;
  final String subCategorySlug;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final bool isBestSeller;
  final bool isNewArrival;
  final bool isFlashSale;
  final double? flashSalePrice;

  ProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.costPrice, // 👈 2. Add to constructor
    required this.discountPercentage,
    required this.images,
    required this.thumbnail,
    required this.sizes,
    required this.colors,
    this.brandId,
    required this.categorySlug,
    required this.subCategorySlug,
    required this.stock,
    required this.isActive,
    required this.isFeatured,
    required this.isBestSeller,
    required this.isNewArrival,
    this.isFlashSale = false,
    this.flashSalePrice,
  });

  bool get isOutOfStock => stock <= 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Category Slug String or Object Handle
    String parseSlug(dynamic slugData) {
      if (slugData is Map) {
        return slugData['slug']?.toString() ?? '';
      }
      return slugData?.toString() ?? '';
    }

    return ProductModel(
      // 🔴 FIX 1: Robust Mongo ID parser
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,

      // 👈 3. Parse costPrice safely from JSON
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,

      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      thumbnail: json['thumbnail'] ?? '',
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: (json['colors'] as List? ?? [])
          .map((c) => ColorOption.fromJson(c))
          .toList(),
      brandId: json['brandId'] is Map
          ? json['brandId']['_id']?.toString()
          : json['brandId']?.toString(),
      // 🔴 FIX 2: Safe Slug parsing
      categorySlug: parseSlug(json['categorySlug']),
      subCategorySlug: parseSlug(json['subCategorySlug']),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      isFlashSale: json['isFlashSale'] ?? false,
      flashSalePrice: (json['flashSalePrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'slug': slug,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,

    // 👈 4. Include costPrice in toJson map
    'costPrice': costPrice,

    'discountPercentage': discountPercentage,
    'images': images,
    'thumbnail': thumbnail,
    'sizes': sizes,
    'colors': colors.map((c) => c.toJson()).toList(),
    'brandId': brandId,
    'categorySlug': categorySlug,
    'subCategorySlug': subCategorySlug,
    'stock': stock,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'isBestSeller': isBestSeller,
    'isNewArrival': isNewArrival,
    'isFlashSale': isFlashSale,
    'flashSalePrice': flashSalePrice,
  };
}