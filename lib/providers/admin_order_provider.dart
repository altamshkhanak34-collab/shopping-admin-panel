

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/order_model.dart';


class AdminOrderProvider extends ChangeNotifier {
  late final Dio _dio;
  late IO.Socket _socket;

  OrderModel? _latestIncomingOrder;
  bool _hasNewOrderAlert = false;

  OrderModel? get latestIncomingOrder => _latestIncomingOrder;
  bool get hasNewOrderAlert => _hasNewOrderAlert;

  List<OrderModel> _orders = [];
  List<OrderModel> _returnRequests = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get returnRequests => _returnRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminOrderProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'enter your api base url here',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 🟢 Interceptor to automatically attach Auth Token from SharedPreferences
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

    // 🔴 3. Socket.io initialization and connection setup
    _initSocketListener();

  }


  // Socket setup method
  void _initSocketListener() {
    _socket = IO.io('enter your api base url here', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('⚡ Admin connected to Socket Server');
    });

    // Listen for new incoming orders from backend
    _socket.on('newOrder', (data) {
      try {
        // Parse incoming order JSON data into OrderModel
        if (data != null) {
          _latestIncomingOrder = OrderModel.fromJson(data);
          _hasNewOrderAlert = true;

          // Automatically refresh the entire order list so the new order appears instantly
          fetchAllOrders();

          notifyListeners(); // UI ko notify karein taaki badge ya alert show ho sake
        }
      } catch (e) {
        print('Error parsing socket order: $e');
      }
    });

    _socket.onDisconnect((_) {
      print('❌ Admin disconnected from Socket Server');
    });
  }

  // Clear new order alert flag when admin views it
  void clearNewOrderAlert() {
    _hasNewOrderAlert = false;
    _latestIncomingOrder = null;
    notifyListeners();
  }

  // 1. Fetch All Admin Orders
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/orders/admin/all');

      if (response.data['success'] == true) {
        final List list = response.data['orders'] ?? [];
        _orders = list.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        _error = response.data['message'] ?? 'Failed to fetch orders';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Update Order Status
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _error = null;
    try {
      final response = await _dio.patch(
        '/orders/$orderId/status',
        data: {'orderStatus': newStatus},
      );

      if (response.data['success'] == true) {
        await fetchAllOrders();
        return true;
      }
      _error = response.data['message'] ?? 'Status update failed';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 3. Update Tracking Details
  Future<bool> updateTrackingInfo({
    required String orderId,
    required String courierPartner,
    required String trackingId,
    required String trackingUrl,
  }) async {
    _error = null;
    try {
      final response = await _dio.patch(
        '/orders/$orderId/tracking',
        data: {
          'courierPartner': courierPartner,
          'trackingId': trackingId,
          'trackingUrl': trackingUrl,
        },
      );

      if (response.data['success'] == true) {
        await fetchAllOrders();
        return true;
      }
      _error = response.data['message'] ?? 'Tracking update failed';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 4. Fetch All Return Requests
  Future<void> fetchReturnRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/orders/admin/returns');

      if (response.data['success'] == true) {
        final List list = response.data['returns'] ?? [];
        _returnRequests = list.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        _error = response.data['message'] ?? 'Failed to fetch return requests';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Process Return Request (APPROVED / REJECTED)
  Future<bool> processReturnRequest({
    required String orderId,
    required String status,
    required String adminComment,
  }) async {
    _error = null;
    try {
      final response = await _dio.put(
        '/orders/admin/$orderId/return',
        data: {
          'status': status,
          'adminComment': adminComment,
        },
      );

      if (response.data['success'] == true) {
        await fetchReturnRequests();
        await fetchAllOrders();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to process return';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 6. Process Refund
  Future<bool> processRefund({
    required String orderId,
    required double refundAmount,
    required String transactionId,
  }) async {
    _error = null;
    try {
      final response = await _dio.put(
        '/orders/admin/$orderId/refund',
        data: {
          'refundAmount': refundAmount,
          'transactionId': transactionId,
        },
      );

      if (response.data['success'] == true) {
        await fetchReturnRequests();
        await fetchAllOrders();
        return true;
      }
      _error = response.data['message'] ?? 'Refund processing failed';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // Helper method for centralized Error Handling
  void _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data != null) {
        _error = e.response?.data['message'] ?? 'Server error occurred';
      } else {
        _error = 'Network error. Please check your internet connection.';
      }
    } else {
      _error = e.toString();
    }
  }

  @override
  void dispose() {
    _socket.dispose(); // Disconnect socket when provider is disposed
    super.dispose();
  }

}