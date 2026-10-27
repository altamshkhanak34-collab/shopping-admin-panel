import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminOfferProvider extends ChangeNotifier {
  late final Dio _dio;

  List<dynamic> _offers = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminOfferProvider() {
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

  // 1. Fetch All Admin Offers -> GET /api/offers/admin/all
  Future<void> fetchAdminOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/all');

      if (response.data['success'] == true) {
        _offers = response.data['data'] ?? [];
      } else {
        _error = response.data['message'] ?? 'Failed to load offers';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Create Offer -> POST /api/offers/admin
  Future<bool> createOffer(Map<String, dynamic> offerData) async {
    _error = null;
    try {
      final response = await _dio.post(
        '/admin',
        data: offerData,
      );

      if (response.data['success'] == true) {
        await fetchAdminOffers(); // Refresh the list
        return true;
      }
      _error = response.data['message'] ?? 'Failed to create offer';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 3. Update Offer / Toggle Status -> PUT /api/offers/admin/:id
  Future<bool> updateOffer(String offerId, Map<String, dynamic> updateData) async {
    _error = null;
    try {
      final response = await _dio.put(
        '/admin/$offerId',
        data: updateData,
      );

      if (response.data['success'] == true) {
        await fetchAdminOffers();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to update offer';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 4. Delete Offer -> DELETE /api/offers/admin/:id
  Future<bool> deleteOffer(String offerId) async {
    _error = null;
    try {
      final response = await _dio.delete('/admin/$offerId');

      if (response.data['success'] == true) {
        _offers.removeWhere((item) => item['_id'] == offerId || item['id'] == offerId);
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to delete offer';
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
  }
}