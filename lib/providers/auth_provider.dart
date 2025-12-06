import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await ApiService.loginUser(email, password);

      if (result['success']) {
        // Load user data after login
        final profileResult = await ApiService.fetchProfile();
        if (profileResult['success']) {
          // Extract user data from profile result
          final userData =
              profileResult['data']['user'] ?? profileResult['data'];
          if (userData != null) {
            _user = User.fromJson(userData);
          }
        }
        _isAuthenticated = true;
        notifyListeners();
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Login failed: $e'};
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final result = await ApiService.registerUser(
        name,
        email,
        password,
        confirmPassword,
      );

      if (result['success']) {
        // Auto-login after register
        _isAuthenticated = true;
        // Load user data after registration
        final profileResult = await ApiService.fetchProfile();
        if (profileResult['success']) {
          // Extract user data from profile result
          final userData =
              profileResult['data']['user'] ?? profileResult['data'];
          if (userData != null) {
            _user = User.fromJson(userData);
          }
        }
        notifyListeners();
        return {'success': true, 'message': 'Account created successfully!'};
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Registration failed: $e'};
    }
  }

  // Auto-login check
  Future<void> autoLogin() async {
    try {
      final isAuthenticated = await AuthService.isAuthenticated();
      if (isAuthenticated) {
        final profileResult = await ApiService.fetchProfile();
        if (profileResult['success']) {
          // Extract user data from profile result
          final userData =
              profileResult['data']['user'] ?? profileResult['data'];
          if (userData != null) {
            _user = User.fromJson(userData);
          }
          _isAuthenticated = true;
        } else {
          await logout();
        }
      } else {
        _isAuthenticated = false;
      }
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
