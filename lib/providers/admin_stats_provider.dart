import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';

class AdminStatsProvider extends ChangeNotifier {
  late final Dio _dio;

  bool _isLoading = false;
  Map<String, dynamic> _stats = {
    'totalRevenue': 0,
    'totalOrders': 0,
    'totalProducts': 0,
    'totalUsers': 0,
  };
  List<dynamic> _lowStockProducts = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic> get stats => _stats;
  List<dynamic> get lowStockProducts => _lowStockProducts;
  String? get error => _error;

  AdminStatsProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'enter your api base url here',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // JWT Token Interceptor (jaise aapke offer provider me hai)
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

  // 1. Fetch Dashboard Stats -> GET /api/admin/stats
  Future<void> fetchAdminStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/stats');

      if (response.data['success'] == true) {
        _stats = response.data['stats'] ?? {};
      } else {
        _error = response.data['message'] ?? 'Failed to load dashboard stats';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch Low Stock Products -> GET /api/admin/low-stock
  Future<void> fetchLowStockProducts() async {
    try {
      final response = await _dio.get('/admin/low-stock');
      // print("Low Stock Response: ${response.data}");

      if (response.data['success'] == true) {
        _lowStockProducts = response.data['products'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      // Background call hai toh error ko optionally handle kar sakte hain
      print('Low stock fetch error: $e');
    }
  }

  List<OrderModel> _recentOrders = []; // 👈 OrderModel type
  List<OrderModel> get recentOrders => _recentOrders;

  Future<void> fetchRecentOrders() async {
    try {
      final response = await _dio.get('/admin/orders/recent?limit=5');
      // print("Recent Orders Response: ${response.data}");

      if (response.data['success'] == true) {
        final List list = response.data['orders'] ?? [];
        _recentOrders = list.map((json) => OrderModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Recent Orders Error: $e");
    }
  }

  List<dynamic> _salesAnalytics = [];
  List<dynamic> get salesAnalytics => _salesAnalytics;

  // 4. Fetch Sales Analytics -> GET /api/admin/analytics
  Future<void> fetchSalesAnalytics() async {
    try {
      final response = await _dio.get('/admin/analytics');
      // print("Analytics Response: ${response.data}");

      if (response.data['success'] == true) {
        _salesAnalytics = response.data['analytics'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      print("Analytics Error: $e");
    }
  }

  List<dynamic> _monthlyAnalytics = [];
  List<dynamic> get monthlyAnalytics => _monthlyAnalytics;

  bool _isMonthlyChart = false;
  bool get isMonthlyChart => _isMonthlyChart;

  void toggleChartType(bool isMonthly) {
    _isMonthlyChart = isMonthly;
    notifyListeners();
    if (isMonthly && _monthlyAnalytics.isEmpty) {
      fetchMonthlySalesAnalytics();
    }
  }

  // Fetch Monthly Analytics -> GET /api/admin/analytics/monthly
  Future<void> fetchMonthlySalesAnalytics() async {
    try {
      final response = await _dio.get('/admin/analytics/monthly');
      // print("Monthly Analytics Response: ${response.data}");

      if (response.data['success'] == true) {
        _monthlyAnalytics = response.data['analytics'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      print("Monthly Analytics Error: $e");
    }
  }


  Map<String, dynamic> _orderStatusData = {};
  Map<String, dynamic> get orderStatusData => _orderStatusData;

  bool _isOrderStatusLoading = false;
  bool get isOrderStatusLoading => _isOrderStatusLoading;

  Future<void> fetchOrderStatusAnalytics() async {
    _isOrderStatusLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/order-status');
      if (response.data['success'] == true) {
        _orderStatusData = response.data;
      }
    } catch (e) {
      print("Order Status Error: $e");
    } finally {
      _isOrderStatusLoading = false;
      notifyListeners();
    }
  }


  List<dynamic> _topProducts = [];
  bool _isTopProductsLoading = false;

  List<dynamic> get topProducts => _topProducts;
  bool get isTopProductsLoading => _isTopProductsLoading;

  Future<void> fetchTopProducts() async {
    _isTopProductsLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/top-products');
      if (response.data['success'] == true) {
        _topProducts = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching top products: $e');
    } finally {
      _isTopProductsLoading = false;
      notifyListeners();
    }
  }


  List<dynamic> _allTopProducts = [];
  bool _isAllTopProductsLoading = false;

  List<dynamic> get allTopProducts => _allTopProducts;
  bool get isAllTopProductsLoading => _isAllTopProductsLoading;

  Future<void> fetchAllTopProducts() async {
    _isAllTopProductsLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/all-top-products');
      if (response.data['success'] == true) {
        _allTopProducts = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching all top products: $e');
    } finally {
      _isAllTopProductsLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _topCategories = [];
  bool _isTopCategoriesLoading = false;

  List<dynamic> get topCategories => _topCategories;
  bool get isTopCategoriesLoading => _isTopCategoriesLoading;

  Future<void> fetchTopCategories() async {
    _isTopCategoriesLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/top-categories');
      if (response.data['success'] == true) {
        _topCategories = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching top categories: $e');
    } finally {
      _isTopCategoriesLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _allTopCategories = [];
  List<dynamic> get allTopCategories => _allTopCategories;

  List<dynamic> _categoryProducts = [];
  List<dynamic> get categoryProducts => _categoryProducts;

  bool _isAllCategoriesLoading = false;
  bool get isAllCategoriesLoading => _isAllCategoriesLoading;

  bool _isCategoryProductsLoading = false;
  bool get isCategoryProductsLoading => _isCategoryProductsLoading;

// Fetch all categories for View All screen
  Future<void> fetchAllTopCategories() async {
    _isAllCategoriesLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/all-top-categories');
      if (response.data['success'] == true) {
        _allTopCategories = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching all top categories: $e');
    } finally {
      _isAllCategoriesLoading = false;
      notifyListeners();
    }
  }

// Fetch products of a selected category
  Future<void> fetchCategoryProducts(String categorySlug) async {
    _isCategoryProductsLoading = true;
    _categoryProducts = [];
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/category-products/$categorySlug');
      if (response.data['success'] == true) {
        _categoryProducts = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching category products: $e');
    } finally {
      _isCategoryProductsLoading = false;
      notifyListeners();
    }
  }

  bool _isRevenueMonthly = false; // false = Last 7 Days, true = This Year
  bool get isRevenueMonthly => _isRevenueMonthly;

  List<dynamic> _revenueTrends = [];
  List<dynamic> get revenueTrends => _revenueTrends;

  bool _isRevenueLoading = false;
  bool get isRevenueLoading => _isRevenueLoading;

// Toggle method dropdown ke liye
  void toggleRevenueChartType(bool isMonthly) {
    _isRevenueMonthly = isMonthly;
    notifyListeners();
    fetchRevenueTrends(); // Toggle hote hi naya data fetch hoga
  }

  Future<void> fetchRevenueTrends() async {
    _isRevenueLoading = true;
    notifyListeners();

    try {
      // Agar monthly true hai toh query parameter bhejenge
      String endpoint = _isRevenueMonthly
          ? '/admin/analytics/revenue-trends?type=monthly'
          : '/admin/analytics/revenue-trends';

      final response = await _dio.get(endpoint);
      if (response.data['success'] == true) {
        _revenueTrends = response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching revenue trends: $e');
    } finally {
      _isRevenueLoading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // PROFIT & LOSS ANALYTICS STATE
  // =====================================================
  Map<String, dynamic> _profitLossData = {
    'totalRevenue': 0.0,
    'totalCost': 0.0,
    'netProfit': 0.0,
    'isProfit': true,
  };
  bool _isProfitLoading = false;

  Map<String, dynamic> get profitLossData => _profitLossData;
  bool get isProfitLoading => _isProfitLoading;

  // Helper Getters for direct UI consumption
  double get totalRevenueVal => (_profitLossData['totalRevenue'] ?? 0).toDouble();
  double get totalCostVal => (_profitLossData['totalCost'] ?? 0).toDouble();
  double get netProfitVal => (_profitLossData['netProfit'] ?? 0).toDouble();
  bool get isProfitVal => _profitLossData['isProfit'] ?? true;

  // Fetch Profit & Loss Analytics -> GET /api/admin/analytics/profit-loss
  Future<void> fetchProfitAndLossAnalytics() async {
    _isProfitLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/analytics/profit-loss');

      if (response.data['success'] == true) {
        _profitLossData = response.data['data'] ?? {
          'totalRevenue': 0.0,
          'totalCost': 0.0,
          'netProfit': 0.0,
          'isProfit': true,
        };
      }
    } catch (e) {
      debugPrint("Profit & Loss Analytics Error: $e");
    } finally {
      _isProfitLoading = false;
      notifyListeners();
    }
  }

  int activeUsersCount = 0;

  int inactiveUsersCount = 0;



  Future<void> fetchUserStats() async {

    try {

      final response = await _dio.get('/admin/user-stats');

      if (response.data['success'] == true) {

        activeUsersCount = response.data['activeUsers'] ?? 0;

        inactiveUsersCount = response.data['inactiveUsers'] ?? 0;

        notifyListeners();

      }

    } catch (e) {

      print('Error fetching user stats: $e');

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