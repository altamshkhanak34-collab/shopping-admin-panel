import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/brand_model.dart';

class AdminBrandProvider extends ChangeNotifier {
  late final Dio _dio;

  List<BrandModel> _brands = [];
  bool _isLoading = false;
  String? _error;

  List<BrandModel> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminBrandProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'enter your api base url here',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // 1. Fetch All Brands -> GET /api/brands
  Future<void> fetchBrands() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 🟢 includeInactive=true pass kar rahe hain taaki admin panel par inactive brands bhi fetch ho sakein
      final response = await _dio.get('?includeInactive=true');

      if (response.data['success'] == true) {
        List data = response.data['data'] ?? [];
        _brands = data.map((item) => BrandModel.fromJson(item)).toList();
      } else {
        _error = response.data['message'] ?? 'Failed to load brands';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Add Brand -> POST /api/brands
  Future<bool> addBrand(Map<String, dynamic> brandData) async {
    _error = null;
    try {
      final response = await _dio.post('', data: brandData);

      if (response.data['success'] == true) {
        await fetchBrands(); // Refresh the list
        return true;
      }
      _error = response.data['message'] ?? 'Failed to create brand';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 3. Update Brand -> PUT /api/brands/:id
  Future<bool> updateBrand(String brandId, Map<String, dynamic> updateData) async {
    _error = null;
    try {
      final response = await _dio.put('/$brandId', data: updateData);

      if (response.data['success'] == true) {
        await fetchBrands(); // Refresh the list
        return true;
      }
      _error = response.data['message'] ?? 'Failed to update brand';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 4. Delete Brand (Soft Delete) -> DELETE /api/brands/:id
  Future<bool> deleteBrand(String brandId) async {
    _error = null;
    try {
      final response = await _dio.delete('/$brandId');

      if (response.data['success'] == true) {
        _brands.removeWhere((item) => item.id == brandId);
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to delete brand';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // Common Error Handling Function
  void _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          _error = data['message'].toString();
        } else if (data is String) {
          _error = data;
        } else {
          _error = 'Server error occurred (${e.response?.statusCode})';
        }
      } else {
        _error = 'Network error. Please check your internet connection.';
      }
    } else {
      _error = e.toString();
    }
    debugPrint("Brand Provider Error: $_error");
  }
}