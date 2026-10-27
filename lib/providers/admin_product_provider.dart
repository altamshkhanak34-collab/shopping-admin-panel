import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/product_model.dart';

class AdminProductProvider extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'enter your api base url here',
    connectTimeout: const Duration(seconds: 60), // Render cold start ke liye 60s
    receiveTimeout: const Duration(seconds: 60),
  ));

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter Out of Stock items
  List<ProductModel> get outOfStockProducts =>
      _products.where((p) => p.stock <= 0).toList();

  // Alias Method (ProductsScreen UI Call Compatibility)
  Future<void> fetchProducts() async => fetchAdminProducts();

  // 1. Fetch All Products
  Future<void> fetchAdminProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/products', queryParameters: {
        'limit': 100,
      });

      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? response.data['products'] ?? [];
        _products = list.map((item) => ProductModel.fromJson(item)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Add New Product
  Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/products', data: productData);
      if (response.data['success'] == true) {
        await fetchAdminProducts();
        return true;
      }
      return false;
    } catch (e) {
      print("Add Product Error: $e");
      return false;
    }
  }

  // 3. Update Existing Product
  // 3. Update Existing Product
  Future<bool> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      // 🔴 Debug: Console me print karke check karein konsi ID aa rahi hai
      print("Updating Product ID: '$productId'");

      if (productId.trim().isEmpty) {
        print("Update Failed: Product ID is empty!");
        return false;
      }

      final response = await _dio.put('/products/$productId', data: productData);
      if (response.data['success'] == true) {
        await fetchAdminProducts();
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        print("Update Product Error: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("Update Product Error: $e");
      }
      return false;
    }
  }

  // 4. Delete Product
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete('/products/$productId');
      if (response.data['success'] == true) {
        _products.removeWhere((p) => p.id == productId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Delete Product Error: $e");
      return false;
    }
  }

  // 5. Direct Stock Update API Call
  Future<bool> updateStock({
    required String productId,
    required int newStock,
    String type = 'set',
  }) async {
    try {
      final response = await _dio.patch(
        '/products/$productId/stock',
        data: {
          'stock': newStock,
          'type': type,
        },
      );

      if (response.data['success'] == true) {
        final updatedStock = response.data['data']?['stock'] ?? newStock;
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          final old = _products[index];
          _products[index] = ProductModel(
            id: old.id,
            title: old.title,
            slug: old.slug,
            description: old.description,
            price: old.price,
            originalPrice: old.originalPrice,
            costPrice: old.costPrice,
            discountPercentage: old.discountPercentage,
            images: old.images,
            thumbnail: old.thumbnail,
            sizes: old.sizes,
            colors: old.colors,
            brandId: old.brandId,
            categorySlug: old.categorySlug,
            subCategorySlug: old.subCategorySlug,
            stock: updatedStock,
            isActive: old.isActive,
            isFeatured: old.isFeatured,
            isBestSeller: old.isBestSeller,
            isNewArrival: old.isNewArrival,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print("Stock Update Error: $e");
      return false;
    }
  }
}