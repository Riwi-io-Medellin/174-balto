import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/walk.dart';

class CompletedWalkSummaryPage extends StatelessWidget {
  const CompletedWalkSummaryPage({super.key, required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _SummaryAppBar(walk: walk),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _CompletedBanner(walk: walk),
                  const SizedBox(height: 16),
                  _RoutePreviewCard(walk: walk),
                  const SizedBox(height: 16),
                  _StatsGrid(walk: walk),
                  const SizedBox(height: 16),
                  _WalkerCard(walk: walk),
                  const SizedBox(height: 16),
                  if (walk.userRating != null) _RatingCard(walk: walk),
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

class _SummaryAppBar extends StatelessWidget {
  const _SummaryAppBar({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${walk.petName}\'s Walk',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A95A3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final dt = walk.scheduledAt.toLocal();
    final month = _month(dt.month);
    final dateStr = '$month ${dt.day}, ${dt.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navWalkers,
            AppColors.navWalkers.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'Walk Completed!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BannerStat(
                  value: '${walk.elapsedMinutes} min', label: 'Duration'),
              _BannerDivider(),
              _BannerStat(
                value: walk.distanceKm != null
                    ? '${walk.distanceKm!.toStringAsFixed(1)} km'
                    : '—',
                label: 'Distance',
              ),
              if (walk.userRating != null) ...[
                _BannerDivider(),
                _BannerStat(
                  value: walk.userRating!.toStringAsFixed(1),
                  label: 'Rating',
                  icon: Icons.star_rounded,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _month(int m) => const [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m];
}

class _BannerStat extends StatelessWidget {
  const _BannerStat({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFFFD966), size: 16),
              const SizedBox(width: 3),
            ],
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}

class _RoutePreviewCard extends StatelessWidget {
  const _RoutePreviewCard({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MiniMapPainter()),
            CustomPaint(painter: _MiniRoutePainter()),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route_outlined,
                        color: AppColors.navWalks, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Route Preview',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8EEE4));
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10;
    final block = Paint()..color = const Color(0xFFD4DDD0);
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 4; j++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              20 + i * (size.width / 4),
              20 + j * (size.height / 3),
              size.width / 4 - 10,
              size.height / 3 - 10,
            ),
            const Radius.circular(4),
          ),
          block,
        );
      }
    }
    for (var j = 0; j <= 3; j++) {
      canvas.drawLine(
        Offset(0, (j + 0.5) * size.height / 3),
        Offset(size.width, (j + 0.5) * size.height / 3),
        road,
      );
    }
    for (var i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset((i + 0.5) * size.width / 4, 0),
        Offset((i + 0.5) * size.width / 4, size.height),
        road,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MiniRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.8);
    path.cubicTo(
      size.width * 0.15, size.height * 0.4,
      size.width * 0.45, size.height * 0.4,
      size.width * 0.45, size.height * 0.25,
    );
    path.cubicTo(
      size.width * 0.45, size.height * 0.1,
      size.width * 0.75, size.height * 0.1,
      size.width * 0.8, size.height * 0.3,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.navWalks
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Start/End dots
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      5,
      Paint()..color = AppColors.navWalks,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      6,
      Paint()..color = AppColors.navWalkers,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      10,
      Paint()
        ..color = AppColors.navWalkers.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final dt = walk.scheduledAt.toLocal();
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _GridTile(
          icon: Icons.timer_outlined,
          label: 'Duration',
          value: '${walk.elapsedMinutes} min',
          color: AppColors.navWalks,
        ),
        _GridTile(
          icon: Icons.route_outlined,
          label: 'Distance',
          value: walk.distanceKm != null
              ? '${walk.distanceKm!.toStringAsFixed(1)} km'
              : '—',
          color: AppColors.navWalkers,
        ),
        _GridTile(
          icon: Icons.schedule_outlined,
          label: 'Start Time',
          value: timeStr,
          color: AppColors.navProfile,
        ),
        _GridTile(
          icon: Icons.pets_outlined,
          label: 'Pet',
          value: walk.petName,
          color: AppColors.navCoach,
        ),
      ],
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9AA0B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalkerCard extends StatelessWidget {
  const _WalkerCard({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              walk.walkerAvatarUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: AppColors.navWalkers.withValues(alpha: 0.15),
                child: const Icon(Icons.person,
                    color: AppColors.navWalkers, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_rounded,
                        color: AppColors.navWalks, size: 15),
                  ],
                ),
                const Text(
                  'Your Walker',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFE8A84C), size: 15),
              const SizedBox(width: 3),
              Text(
                walk.walkerRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final rating = walk.userRating!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.star_outline_rounded,
                  color: Color(0xFFE8A84C), size: 18),
              SizedBox(width: 8),
              Text(
                'Your Rating',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < rating.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: const Color(0xFFE8A84C),
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            _ratingLabel(rating.round()),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A6A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int r) => switch (r) {
        5 => 'Excellent!',
        4 => 'Good',
        3 => 'Average',
        2 => 'Below expectations',
        _ => 'Needs improvement',
      };
}
