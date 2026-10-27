import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../models/Category_model.dart';

class AdminCategoryProvider with ChangeNotifier {
  final Dio _dio = Dio(); // Express Backend URL yahan set karein
  final String _baseUrl = 'enter your api base url here';

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  // Fetch All Categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(_baseUrl);
      if (response.data['success'] == true) {
        List data = response.data['data'];
        _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Fetch Categories Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Category
  Future<bool> createCategory(String name, String image) async {
    try {
      final response = await _dio.post(_baseUrl, data: {
        'name': name,
        'image': image,
      });

      if (response.data['success'] == true) {
        await fetchCategories(); // Refresh list
        return true;
      }
    } catch (e) {
      debugPrint("Create Category Error: $e");
    }
    return false;
  }

  // Update Category
  Future<bool> updateCategory(String id, {String? name, String? image, bool? isActive}) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (image != null) data['image'] = image;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _dio.put('$_baseUrl/$id', data: data);

      if (response.data['success'] == true) {
        await fetchCategories(); // Refresh list
        return true;
      }
    } catch (e) {
      debugPrint("Update Category Error: $e");
    }
    return false;
  }

  // Soft Delete Category
  Future<bool> deleteCategory(String id) async {
    try {
      final response = await _dio.delete('$_baseUrl/$id');
      if (response.data['success'] == true) {
        await fetchCategories(); // Refresh list
        return true;
      }
    } catch (e) {
      debugPrint("Delete Category Error: $e");
    }
    return false;
  }
}