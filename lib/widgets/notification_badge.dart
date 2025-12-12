import 'package:flutter/material.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../screens/notifications_screen.dart';

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({Key? key}) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  int unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    loadUnreadCount();
    // Set up periodic refresh every 1 minute
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => loadUnreadCount(),
    );

    // Listen to real-time FCM messages and update badge immediately
    _notificationService.setupForegroundListener(() {
      print('🔔 Badge: FCM message received, refreshing badge...');
      // When a new notification arrives, refresh the badge
      if (mounted) {
        loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadUnreadCount() async {
    try {
      final result = await _notificationService.getNotifications();
      if (result['success'] == true && mounted) {
        setState(() {
          unreadCount = result['unread_count'] as int;
        });
      }
    } catch (e) {
      // Silently fail - don't show error for background refresh
      if (mounted) {
        setState(() {
          unreadCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            // Refresh count after returning from notifications screen
            loadUnreadCount();
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
