import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  // Use the same configuration as ApiService
  static String get baseUrl => ApiConfig.baseUrl;

  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Get all notifications
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/core/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'notifications': (data['notifications'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList(),
          'unread_count': data['unread_count'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load notifications (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/core/notifications/$notificationId/mark-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error':
              'Failed to mark notification as read (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/core/notifications/mark-all-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error':
              'Failed to mark all notifications as read (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
