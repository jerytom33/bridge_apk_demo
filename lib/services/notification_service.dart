import 'dart:convert';
import 'dart:io';
import '../main.dart'; // Import to access navigatorKey
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/notification_model.dart';
import 'api_service.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  // Singleton pattern - ensures single instance with same listeners
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Use the same configuration as ApiService
  static String get baseUrl => ApiConfig.baseUrl;

  final _firebaseMessaging = FirebaseMessaging.instance;

  // Callback list for foreground message listeners
  final List<Function()> _foregroundListeners = [];

  // Initialize Notifications
  Future<void> initNotifications() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Get FCM Token
      try {
        final fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token: $fcmToken');

        if (fcmToken != null) {
          await registerFcmToken(fcmToken);
        }
      } catch (e) {
        print('Error getting FCM token: $e');
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Setup interaction handling
      await setupInteractedMessage();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message contained a notification: ${message.notification}');
          // Ideally show a local notification here using flutter_local_notifications
          // For now, we just print
        }

        print('🔔 Notifying ${_foregroundListeners.length} badge listeners...');
        // Notify all registered listeners (for real-time badge update)
        for (var listener in _foregroundListeners) {
          listener();
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // Add listener for foreground messages
  void setupForegroundListener(Function() callback) {
    _foregroundListeners.add(callback);
    print(
      '🔔 Badge listener registered. Total listeners: ${_foregroundListeners.length}',
    );
  }

  // Handle interaction (tap on notification)
  Future<void> setupInteractedMessage() async {
    // 1. App launched from Terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // 2. App opened from Background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print('Handling notification interaction: ${message.data}');

    // Extract data from notification payload
    final data = message.data;
    final String? type = data['type'];
    final String? courseId = data['course_id'];
    final String? examId = data['exam_id'];

    // Navigate based on notification type
    switch (type) {
      // Feed/Post related notifications
      case 'post_liked':
      case 'post_saved':
      case 'new_post':
      case 'feed':
        navigatorKey.currentState?.pushNamed('/feed');
        break;

      // Course related notifications
      case 'new_course':
      case 'course_enrolled':
      case 'course':
        if (courseId != null) {
          // Navigate to specific course - passing arguments
          navigatorKey.currentState?.pushNamed(
            '/courses',
            arguments: {'courseId': courseId},
          );
        } else {
          navigatorKey.currentState?.pushNamed('/courses');
        }
        break;

      // Exam related notifications
      case 'new_exam':
      case 'exam_reminder':
      case 'exam':
        if (examId != null) {
          // Navigate to specific exam - passing arguments
          navigatorKey.currentState?.pushNamed(
            '/exams',
            arguments: {'examId': examId},
          );
        } else {
          navigatorKey.currentState?.pushNamed('/exams');
        }
        break;

      // Notification screen notifications
      case 'notification_screen':
      case 'system':
        navigatorKey.currentState?.pushNamed('/notifications');
        break;

      // Profile/Account notifications
      case 'profile':
      case 'account':
        navigatorKey.currentState?.pushNamed('/profile');
        break;

      // Default: Go to home
      default:
        navigatorKey.currentState?.pushNamed('/home');
        break;
    }
  }

  // Register FCM Token with backend
  Future<void> registerFcmToken(String token) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) return;

      String deviceType = 'android';
      if (Platform.isIOS) deviceType = 'ios';

      final response = await http.post(
        Uri.parse('$baseUrl/core/fcm/register/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'token': token, 'device_type': deviceType}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCM Token registered successfully');
      } else {
        print('Failed to register FCM Token: ${response.body}');
      }
    } catch (e) {
      print('Error registering FCM Token: $e');
    }
  }

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
