import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walk.dart';

class LiveWalkScreen extends StatelessWidget {
  const LiveWalkScreen({super.key, required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _MapSection(walk: walk),
          ),
          Expanded(
            flex: 6,
            child: _StatusPanel(walk: walk),
          ),
        ],
      ),
    );
  }
}

// ── Map ──────────────────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _MapPainter()),
        CustomPaint(painter: _RoutePainter()),
        _PetMarker(petName: walk.petName),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: _BackButton(),
        ),
        const Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: _UpdatedBadge(),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.arrow_back_rounded,
              color: cs.onSurface, size: 22),
        ),
      ),
    );
  }
}

class _UpdatedBadge extends StatelessWidget {
  const _UpdatedBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.navWalks.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Updated 5 seconds ago',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PetMarker extends StatelessWidget {
  const _PetMarker({required this.petName});

  final String petName;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.52,
      top: MediaQuery.of(context).size.height * 0.16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$petName · now',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.navWalks,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navWalks.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8EEE4);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final roadSm = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final block = Paint()..color = const Color(0xFFD4DDD0);

    // Blocks
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 8; j++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              28 + i * (size.width / 5),
              28 + j * (size.height / 7),
              size.width / 5 - 16,
              size.height / 7 - 16,
            ),
            const Radius.circular(6),
          ),
          block,
        );
      }
    }

    // Horizontal roads
    for (var j = 0; j <= 7; j++) {
      canvas.drawLine(
        Offset(0, (j + 0.5) * size.height / 7),
        Offset(size.width, (j + 0.5) * size.height / 7),
        j % 3 == 0 ? road : roadSm,
      );
    }
    // Vertical roads
    for (var i = 0; i <= 5; i++) {
      canvas.drawLine(
        Offset((i + 0.5) * size.width / 5, 0),
        Offset((i + 0.5) * size.width / 5, size.height),
        i % 2 == 0 ? road : roadSm,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.85);
    path.cubicTo(
      size.width * 0.2, size.height * 0.55,
      size.width * 0.38, size.height * 0.55,
      size.width * 0.38, size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.38, size.height * 0.15,
      size.width * 0.55, size.height * 0.15,
      size.width * 0.56, size.height * 0.24,
    );

    final paint = Paint()
      ..color = AppColors.navWalks
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    // Start dot
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.85),
      7,
      Paint()..color = AppColors.navWalks.withValues(alpha: 0.4),
    );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.85),
      4,
      Paint()..color = AppColors.navWalks,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Status Panel ─────────────────────────────────────────────────────────────

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _WalkerRow(walk: walk),
            const SizedBox(height: 20),
            _StatsRow(walk: walk),
            const SizedBox(height: 20),
            _ActionButtons(walk: walk),
            const SizedBox(height: 20),
            _WellnessCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _WalkerRow extends StatelessWidget {
  const _WalkerRow({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            walk.walkerAvatarUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 50,
              height: 50,
              color: AppColors.navWalkers.withValues(alpha: 0.15),
              child: const Icon(Icons.person,
                  color: AppColors.navWalkers, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                walk.walkerName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: cs.onSurface,
                ),
              ),
              Text(
                'Your walker · Verified Pro',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFE8A84C), size: 15),
              const SizedBox(width: 3),
              Text(
                walk.walkerRating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.route_outlined,
            value: walk.distanceKm != null
                ? '${walk.distanceKm!.toStringAsFixed(1)} km'
                : '—',
            label: 'Distance',
            color: AppColors.navWalks,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.timer_outlined,
            value: '${walk.elapsedMinutes} min',
            label: 'Duration',
            color: AppColors.navWalkers,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Call',
            icon: Icons.phone_outlined,
            bg: AppColors.navWalks,
            fg: Colors.white,
            onTap: () =>
                BaltoToast.info(context, 'Calling ${walk.walkerName}...'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionBtn(
            label: 'Chat',
            icon: Icons.chat_bubble_outline_rounded,
            bg: AppColors.navWalks.withValues(alpha: 0.1),
            fg: AppColors.navWalks,
            onTap: () =>
                BaltoToast.info(context, 'Chat not connected yet.'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionBtn(
            label: 'SOS',
            icon: Icons.warning_amber_rounded,
            bg: cs.surfaceContainerLow,
            fg: AppColors.alert,
            onTap: () => BaltoToast.warning(
              context,
              'Emergency SOS will alert Balto support immediately.',
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WellnessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navWalkers.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.navWalkers.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined,
                color: AppColors.navWalkers, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peace of mind',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const Text(
                  'Live wellbeing check · All good',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.navWalkers,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your pet is enjoying the walk and has maintained a healthy, energetic activity level during the last 20 minutes.',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CustomPaint(
            size: const Size(40, 28),
            painter: _HeartbeatPainter(),
          ),
        ],
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navWalkers
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.1);
    path.lineTo(size.width * 0.45, size.height * 0.9);
    path.lineTo(size.width * 0.55, size.height * 0.2);
    path.lineTo(size.width * 0.65, size.height * 0.6);
    path.lineTo(size.width * 0.75, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
