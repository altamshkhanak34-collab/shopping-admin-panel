import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../models/sub_category_model.dart';

class AdminSubCategoryProvider with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  final String _baseUrl = 'enter your api base url here';

  List<SubCategoryModel> _subCategories = [];
  bool _isLoading = false;

  List<SubCategoryModel> get subCategories => _subCategories;
  bool get isLoading => _isLoading;

  // Fetch Sub-Categories (Optionally filtered by categoryId)
  Future<void> fetchSubCategories({String? categoryId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String url = _baseUrl;
      if (categoryId != null && categoryId.isNotEmpty) {
        url = '$_baseUrl?categoryId=$categoryId';
      }

      final response = await _dio.get(url);
      if (response.data['success'] == true) {
        List data = response.data['data'];
        _subCategories = data.map((e) => SubCategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Fetch SubCategories Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create SubCategory
  Future<bool> createSubCategory({
    required String name,
    required String categoryId,
    required String image,
  }) async {
    try {
      final response = await _dio.post(_baseUrl, data: {
        'name': name,
        'categoryId': categoryId,
        'image': image,
      });

      if (response.data['success'] == true) {
        await fetchSubCategories();
        return true;
      }
    } catch (e) {
      debugPrint("Create SubCategory Error: $e");
    }
    return false;
  }

  // Update SubCategory
  Future<bool> updateSubCategory(
      String id, {
        String? name,
        String? categoryId,
        String? image,
        bool? isActive,
      }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (categoryId != null) data['categoryId'] = categoryId;
      if (image != null) data['image'] = image;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _dio.put('$_baseUrl/$id', data: data);

      if (response.data['success'] == true) {
        await fetchSubCategories();
        return true;
      }
    } catch (e) {
      debugPrint("Update SubCategory Error: $e");
    }
    return false;
  }

  // Delete SubCategory
  Future<bool> deleteSubCategory(String id) async {
    try {
      final response = await _dio.delete('$_baseUrl/$id');
      if (response.data['success'] == true) {
        await fetchSubCategories();
        return true;
      }
    } catch (e) {
      debugPrint("Delete SubCategory Error: $e");
    }
    return false;
  }
}