import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSupportProvider extends ChangeNotifier {
  late final Dio _dio;

  List<dynamic> _tickets = [];
  Map<String, dynamic>? _selectedTicket;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get tickets => _tickets;
  Map<String, dynamic>? get selectedTicket => _selectedTicket;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AdminSupportProvider() {
    _dio = Dio(
      BaseOptions(
        // Server.js ke app.use('/api/support/tickets', ticketRoutes) se match karne ke liye:
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

  // 1. Fetch All Admin Tickets -> GET /api/support/tickets/admin/tickets
  Future<void> fetchAllTickets({String? status, String? priority}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        '/admin/tickets',
        queryParameters: {
          if (status != null && status != 'ALL') 'status': status,
          if (priority != null && priority != 'ALL') 'priority': priority,
        },
      );

      if (response.data['success'] == true) {
        _tickets = response.data['data'] ?? [];
      } else {
        _error = response.data['message'] ?? 'Failed to load support tickets';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch Single Ticket Details -> GET /api/support/tickets/admin/tickets/:id
  Future<void> fetchTicketDetails(String ticketId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/tickets/$ticketId');
      if (response.data['success'] == true) {
        _selectedTicket = response.data['data'];
      } else {
        _error = response.data['message'] ?? 'Failed to fetch conversation';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Send Admin Reply -> POST /api/support/tickets/admin/tickets/:id/message
  Future<bool> sendAdminMessage(String ticketId, String text) async {
    _error = null;
    try {
      final response = await _dio.post(
        '/admin/tickets/$ticketId/message',
        data: {'text': text},
      );

      if (response.data['success'] == true) {
        _selectedTicket = response.data['data'];
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to send message';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 4. Update Status -> PUT /api/support/tickets/admin/tickets/:id/status
  Future<bool> updateStatus(String ticketId, String newStatus) async {
    _error = null;
    try {
      final response = await _dio.put(
        '/admin/tickets/$ticketId/status',
        data: {'status': newStatus},
      );

      if (response.data['success'] == true) {
        if (_selectedTicket != null) {
          _selectedTicket!['status'] = newStatus;
        }
        await fetchAllTickets();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to update status';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 5. Update Priority -> PUT /api/support/tickets/admin/tickets/:id/priority
  Future<bool> updatePriority(String ticketId, String newPriority) async {
    _error = null;
    try {
      final response = await _dio.put(
        '/admin/tickets/$ticketId/priority',
        data: {'priority': newPriority},
      );

      if (response.data['success'] == true) {
        if (_selectedTicket != null) {
          _selectedTicket!['priority'] = newPriority;
        }
        await fetchAllTickets();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to update priority';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

  // 6. Delete Ticket -> DELETE /api/support/tickets/admin/tickets/:id
  Future<bool> deleteTicket(String ticketId) async {
    _error = null;
    try {
      final response = await _dio.delete('/admin/tickets/$ticketId');

      if (response.data['success'] == true) {
        _tickets.removeWhere((t) => t['_id'] == ticketId || t['id'] == ticketId);
        if (_selectedTicket != null &&
            (_selectedTicket!['_id'] == ticketId || _selectedTicket!['id'] == ticketId)) {
          _selectedTicket = null;
        }
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Failed to delete ticket';
      notifyListeners();
      return false;
    } catch (e) {
      _handleError(e);
      notifyListeners();
      return false;
    }
  }

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