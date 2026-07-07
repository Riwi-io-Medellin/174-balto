import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walk.dart';

class UpcomingWalkDetailPage extends StatelessWidget {
  const UpcomingWalkDetailPage({super.key, required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(walk: walk),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatusCard(walk: walk),
                  const SizedBox(height: 16),
                  _WalkInfoCard(walk: walk),
                  const SizedBox(height: 16),
                  _WalkerCard(walk: walk),
                  if (walk.notes != null && walk.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _NotesCard(notes: walk.notes!),
                  ],
                  const SizedBox(height: 24),
                  _CancelButton(onCancel: () {
                    BaltoToast.warning(
                      context,
                      'Cancellation will be available closer to the scheduled time.',
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              walk.petName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Upcoming Walk',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.navWalks,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              walk.petImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE8F0F8),
                child: const Icon(Icons.pets,
                    color: AppColors.navWalks, size: 64),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final date = walk.scheduledAt;
    final diff = date.difference(DateTime.now());
    final hoursLeft = diff.inHours;
    final minsLeft = diff.inMinutes.remainder(60);
    final timeLeft = hoursLeft > 0
        ? '${hoursLeft}h ${minsLeft}m away'
        : '${minsLeft}m away';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navWalks.withValues(alpha: 0.08),
        borderRadius: AppRadius.radius16,
        border: Border.all(
          color: AppColors.navWalks.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.navWalks.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time_rounded,
                color: AppColors.navWalks, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Walk Scheduled',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeLeft,
                style: AppTextStyles.label.copyWith(color: AppColors.navWalks),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalkInfoCard extends StatelessWidget {
  const _WalkInfoCard({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final dt = walk.scheduledAt.toLocal();
    final dateStr = '${_weekday(dt.weekday)}, ${_month(dt.month)} ${dt.day}';
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return _Card(
      title: 'Walk Details',
      icon: Icons.directions_walk_rounded,
      iconColor: AppColors.navWalks,
      child: Column(
        children: [
          _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date', value: dateStr),
          const _Divider(),
          _InfoRow(icon: Icons.schedule_outlined, label: 'Time', value: timeStr),
          const _Divider(),
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '${walk.durationMinutes} minutes',
          ),
          if (walk.meetingLocation != null) ...[
            const _Divider(),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'Meeting Point',
              value: walk.meetingLocation!,
            ),
          ],
        ],
      ),
    );
  }

  String _weekday(int d) => const [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][d];

  String _month(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}

class _WalkerCard extends StatelessWidget {
  const _WalkerCard({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Your Walker',
      icon: Icons.person_outline_rounded,
      iconColor: AppColors.navWalkers,
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              walk.walkerAvatarUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 52,
                height: 52,
                color: AppColors.navWalkers.withValues(alpha: 0.15),
                child: const Icon(Icons.person,
                    color: AppColors.navWalkers, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      walk.walkerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        color: AppColors.navWalks, size: 16),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Verified Pro',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFE8A84C), size: 16),
              const SizedBox(width: 3),
              Text(
                walk.walkerRating.toStringAsFixed(1),
                style: AppTextStyles.bodyBold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Special Instructions',
      icon: Icons.notes_rounded,
      iconColor: AppColors.navProfile,
      child: Text(
        notes,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4A4A6A),
          height: 1.6,
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.alert,
          side: BorderSide(color: AppColors.alert.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radius14,
          ),
        ),
        child: const Text(
          'Cancel Walk',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyBold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9AA0B2)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Color(0xFFF0F0F4), height: 1, thickness: 1);
  }
}
