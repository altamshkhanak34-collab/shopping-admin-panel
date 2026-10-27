import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminUserProvider extends ChangeNotifier {
  late final Dio _dio;

  List<dynamic> _users = [];
  List<dynamic> _userOrders = []; // 👈 Single user order history list
  bool _isLoading = false;
  bool _isOrdersLoading = false; // 👈 Separate loading state for orders modal
  String? _error;

  List<dynamic> get users => _users;
  List<dynamic> get userOrders => _userOrders;
  bool get isLoading => _isLoading;
  bool get isOrdersLoading => _isOrdersLoading;
  String? get error => _error;

  AdminUserProvider() {
    _dio = Dio(
      BaseOptions(
        // Base URL aapke backend domain ke hisab se setup hai
        baseUrl: 'enter your api base url here',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Dynamic Token Interceptor (SharedPreferences se Bearer Token)
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

  // 👑 Fetch All Admin Users -> GET /api/auth/admin/users
  Future<void> fetchAdminUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/auth/admin/users');

      if (response.data['success'] == true) {
        _users = response.data['users'] ?? [];
      } else {
        _error = response.data['message'] ?? 'Failed to load users list';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 📦 Fetch Specific User Orders -> GET /api/orders/admin/user-orders/:userId
  Future<void> fetchUserOrders(String userId) async {
    _isOrdersLoading = true;
    _userOrders = [];
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/orders/admin/user-orders/$userId');

      if (response.data['success'] == true) {
        _userOrders = response.data['orders'] ?? [];
      } else {
        _error = response.data['message'] ?? 'Failed to load user orders';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  // AdminUserProvider.dart me replace karein:
  Future<bool> updateUserRole(String userId, String newRole) async {
    _error = null;
    try {
      final response = await _dio.put('/auth/admin/users/$userId/role', data: {
        'role': newRole,
      });

      if (response.data['success'] == true) {
        await fetchAdminUsers(); // Isme fetchAdminUsers() ke andar notifyListeners() already ho jayega
        return true;
      }

      _error = response.data['message'] ?? 'Failed to update user role';
      notifyListeners(); // 👈 Error message update hone par UI notify hoga
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners(); // 👈 Dio/Server error aane par UI notify hoga
      return false;
    }
  }

  // Common Dio Error Handling
  void _handleError(dynamic e) {
    if (e is DioException) {
      print('Dio Error Status Code: ${e.response?.statusCode}');
      print('Dio Error Response Data: ${e.response?.data}');

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