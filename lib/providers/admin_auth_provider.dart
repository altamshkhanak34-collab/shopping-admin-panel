import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  // Dio Instance
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'enter your api base url here', // 🟢 Update Base URL here
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 1. App start hone par Auto-Login Check
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('accessToken')) {
      return false;
    }

    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    final userString = prefs.getString('userData');
    if (userString != null) {
      _userData = json.decode(userString);
    }

    notifyListeners();
    return true;
  }

  // 2. Login Function (Using Dio + Admin Check)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data;

      if (response.statusCode == 200 && responseData['success'] == true) {
        final user = responseData['user'];

        // 🛡️ Admin Check
        final String role = user['role'] ?? '';

        if (role.toUpperCase() == 'ADMIN') {
          _accessToken = responseData['accessToken'];
          _refreshToken = responseData['refreshToken'];
          _userData = user;

          // Local Storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', _accessToken!);
          if (_refreshToken != null) {
            await prefs.setString('refreshToken', _refreshToken!);
          }
          await prefs.setString('userData', json.encode(_userData));

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Access Denied: Admin privileges required';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = responseData['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (dioErr) {
      if (dioErr.response != null && dioErr.response?.data != null) {
        _error = dioErr.response?.data['message'] ?? 'Invalid credentials';
      } else {
        _error = 'Network connection error. Please check your internet.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (err) {
      _error = 'Something went wrong: ${err.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. Logout Function (Using Dio)
  Future<void> logout() async {
    if (_accessToken != null) {
      try {
        await _dio.post(
          '/auth/logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $_accessToken',
            },
          ),
        );
      } catch (_) {}
    }

    _accessToken = null;
    _refreshToken = null;
    _userData = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}