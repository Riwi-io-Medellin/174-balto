import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/repositories/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repo = sl<NotificationRepository>();
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;

  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _textLight = Color(0xFF9AA0B2);
  static const Color _primary = Color(0xFF3A80C2);
  static const Color _unreadBg = Color(0xFFF0F7FF);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifications = await _repo.getMyNotifications(page: 1, pageSize: 50);
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } on NotificationFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _repo.markAsRead(id);
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == id) {
            return AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              entityId: n.entityId,
              entityType: n.entityType,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
      });
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((n) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            entityId: n.entityId,
            entityType: n.entityType,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
      });
    } catch (_) {}
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'walk_started':
        return Icons.directions_walk;
      case 'walk_finished':
        return Icons.check_circle_outline;
      case 'walk_cancelled':
        return Icons.cancel_outlined;
      case 'walker_assigned':
        return Icons.person_pin;
      case 'walker_approved':
        return Icons.verified_rounded;
      case 'walker_rejected':
        return Icons.error_outline;
      case 'business_approved':
        return Icons.store_rounded;
      case 'business_rejected':
        return Icons.storefront_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'walk_started':
      case 'walk_finished':
        return const Color(0xFF1BAA71);
      case 'walk_cancelled':
        return const Color(0xFFE5544B);
      case 'walker_assigned':
      case 'walker_approved':
      case 'business_approved':
        return const Color(0xFF3A80C2);
      case 'walker_rejected':
      case 'business_rejected':
        return const Color(0xFFD05A24);
      default:
        return const Color(0xFF5A6473);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _primary),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFF9AA0B2)),
              const SizedBox(height: 16),
              Text(
                'Could not load notifications',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none, size: 64, color: _textLight.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'ll notify you about walks, bookings, and updates.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);

    return GestureDetector(
      onTap: notification.isRead
          ? null
          : () => _markAsRead(notification.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : _unreadBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFF1F3F6)
                : color.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(fontSize: 11, color: _textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: const TextStyle(fontSize: 13, color: _textMuted, height: 1.3),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A80C2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
