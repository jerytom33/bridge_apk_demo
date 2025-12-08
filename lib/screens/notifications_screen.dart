import 'package:flutter/material.dart';
import 'dart:async';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> notifications = [];
  int unreadCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() => isLoading = true);

    try {
      final result = await _notificationService.getNotifications();

      if (result['success'] == true) {
        setState(() {
          notifications = result['notifications'] as List<NotificationModel>;
          unreadCount = result['unread_count'] as int;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Error loading notifications'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final result = await _notificationService.markAsRead(notificationId);
      if (result['success'] == true) {
        loadNotifications(); // Reload to update UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notification as read: $e')),
        );
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final result = await _notificationService.markAllAsRead();
      if (result['success'] == true) {
        loadNotifications(); // Reload to update UI
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Error marking all as read'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking all as read: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllAsRead,
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => markAsRead(notification.id),
                  );
                },
              ),
            ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIconForType(notification.notificationType),
        color: notification.isRead
            ? Colors.grey
            : Theme.of(context).primaryColor,
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            _formatTime(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: onTap,
      tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.1),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'guide_registration':
      case 'company_registration':
        return Icons.person_add;
      case 'guide_approved':
      case 'company_approved':
        return Icons.check_circle;
      case 'guide_rejected':
      case 'company_rejected':
        return Icons.cancel;
      case 'post_liked':
        return Icons.favorite;
      case 'post_saved':
        return Icons.bookmark;
      case 'guide_logout':
      case 'company_logout':
        return Icons.exit_to_app;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
