import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AdminBannerProvider extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      // ⚠️ Apne backend base URL se replace karein
      baseUrl: 'enter your api base url here',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  List<dynamic> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 1. Fetch All Banners (Fixed Endpoint: /banners/)
  Future<void> fetchAllBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/banners');
      if (response.data['success'] == true) {
        _banners = response.data['data'] ?? [];
      } else {
        _error = response.data['message'] ?? 'Failed to load banners';
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Server error occurred';
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Create Banner
  Future<bool> createBanner(Map<String, dynamic> bannerData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post('/banners', data: bannerData);
      if (response.data['success'] == true) {
        await fetchAllBanners(); // Refresh list
        return true;
      }
      _error = response.data['message'];
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to create banner';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Update Banner
  Future<bool> updateBanner(String bannerId, Map<String, dynamic> bannerData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.put('/banners/$bannerId', data: bannerData);
      if (response.data['success'] == true) {
        await fetchAllBanners();
        return true;
      }
      _error = response.data['message'];
      return false;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to update banner';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Toggle Active Status (Fixed Method: PUT & Endpoint: /banners/:id/status)
  Future<bool> toggleBannerStatus(String bannerId, bool isActive) async {
    try {
      final response = await _dio.put(
        '/banners/$bannerId/status',
        data: {'isActive': isActive},
      );
      if (response.data['success'] == true) {
        final index = _banners.indexWhere((b) => (b['_id'] ?? b['id']) == bannerId);
        if (index != -1) {
          _banners[index]['isActive'] = isActive;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 5. Delete Banner
  Future<bool> deleteBanner(String bannerId) async {
    try {
      final response = await _dio.delete('/banners/$bannerId');
      if (response.data['success'] == true) {
        _banners.removeWhere((b) => (b['_id'] ?? b['id']) == bannerId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}