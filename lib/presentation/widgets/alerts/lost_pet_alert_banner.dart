import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/notification.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/repositories/pet_repository.dart';

/// Alert-style banner shown when the current user has unread `lost_pet`
/// notifications. Distinct from the regular notification list: bright,
/// dismissible per-notification (marks it as read), self-loading.
///
/// Drop this into HomeScreen and NotificationsScreen. It renders nothing
/// while there are no unread lost_pet notifications, so it never gets in
/// the way of users who aren't affected.
class LostPetAlertBanner extends StatefulWidget {
  const LostPetAlertBanner({super.key});

  @override
  State<LostPetAlertBanner> createState() => _LostPetAlertBannerState();
}

class _LostPetAlertBannerState extends State<LostPetAlertBanner> {
  static const Color _alert = Color(0xFFE53935);

  final NotificationRepository _notificationRepo = sl<NotificationRepository>();
  final PetRepository _petRepo = sl<PetRepository>();

  List<AppNotification> _alerts = [];
  final Map<String, Pet> _petByNotification = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final notifications = await _notificationRepo.getMyNotifications(
        unreadOnly: true,
        page: 1,
        pageSize: 50,
      );
      final lostAlerts = notifications.where((n) => n.type == 'lost_pet').toList();

      // Only fetch the pet behind the alert shown on top, to keep this cheap.
      if (lostAlerts.isNotEmpty && lostAlerts.first.entityId != null) {
        try {
          final pet = await _petRepo.getById(lostAlerts.first.entityId!);
          _petByNotification[lostAlerts.first.id] = pet;
        } catch (_) {
          // If the pet fetch fails we still show the alert with title/body only.
        }
      }

      if (!mounted) return;
      setState(() {
        _alerts = lostAlerts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _dismiss(AppNotification notification) async {
    setState(() => _alerts = _alerts.where((n) => n.id != notification.id).toList());
    try {
      await _notificationRepo.markAsRead(notification.id);
    } catch (_) {
      // Best-effort: if this fails the alert may reappear next load, which
      // is safe (no data loss, just an extra dismiss).
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _alerts.isEmpty) return const SizedBox.shrink();

    final top = _alerts.first;
    final pet = _petByNotification[top.id];
    final extraCount = _alerts.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _alert.withValues(alpha: 0.08),
        borderRadius: AppRadius.radius16,
        border: Border.all(color: _alert.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _photo(pet),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pets, size: 14, color: _alert),
                    const SizedBox(width: 6),
                    const Text(
                      'LOST PET NEARBY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _alert,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  top.title,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  top.body,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                if (extraCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+$extraCount more lost pet alert${extraCount == 1 ? '' : 's'}',
                    style: AppTextStyles.micro.copyWith(color: _alert),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF9AA0B2)),
            tooltip: 'Dismiss',
            onPressed: () => _dismiss(top),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _photo(Pet? pet) {
    if (pet?.photoUrl != null && pet!.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radius10,
        child: Image.network(
          pet.photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(),
        ),
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _alert.withValues(alpha: 0.15),
        borderRadius: AppRadius.radius10,
      ),
      child: const Icon(Icons.pets, color: _alert),
    );
  }
}
