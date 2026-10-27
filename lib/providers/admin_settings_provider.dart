import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettingsProvider extends ChangeNotifier {
  late final Dio _dio;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Settings Data State
  String storeName = '';
  String supportEmail = '';
  String supportPhone = '';
  String defaultCurrency = 'USD (\$';
  double taxRate = 18.0;
  bool orderAlerts = true;
  bool lowStockAlerts = true;
  bool ticketAlerts = true;
  bool maintenanceMode = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  AdminSettingsProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'enter your api base url here', // Apna base URL match karein
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

  // 1. Fetch Settings -> GET /api/settings
  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        storeName = data['storeName'] ?? '';
        supportEmail = data['supportEmail'] ?? '';
        supportPhone = data['supportPhone'] ?? '';
        defaultCurrency = data['defaultCurrency'] ?? 'USD (\$';
        taxRate = (data['taxRate'] ?? 18.0).toDouble();

        final notifs = data['notifications'] ?? {};
        orderAlerts = notifs['orderAlerts'] ?? true;
        lowStockAlerts = notifs['lowStockAlerts'] ?? true;
        ticketAlerts = notifs['ticketAlerts'] ?? true;

        maintenanceMode = data['maintenanceMode'] ?? false;
      }
    } catch (e) {
      _error = 'Failed to load settings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Update Settings -> PUT /api/settings
  Future<bool> updateSettings(Map<String, dynamic> updateData) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.put('', data: updateData);
      if (response.data['success'] == true) {
        await fetchSettings(); // Refresh local state
        _isSaving = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to update settings';
    }

    _isSaving = false;
    notifyListeners();
    return false;
  }
}