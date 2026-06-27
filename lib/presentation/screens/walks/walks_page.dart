import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/walks_mock.dart';
import '../../../domain/entities/walk.dart';
import 'completed_walk_summary_page.dart';
import 'live_walk_screen.dart';
import 'upcoming_walk_detail_page.dart';

class WalksPage extends StatelessWidget {
  const WalksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inProgress = kMockWalks.where((w) => w.status == WalkStatus.inProgress).toList();
    final upcoming = kMockWalks.where((w) => w.status == WalkStatus.upcoming).toList();
    final completed = kMockWalks.where((w) => w.status == WalkStatus.completed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _WalksAppBar(),
          if (inProgress.isNotEmpty) ...[
            _SectionHeader(label: 'In Progress', color: AppColors.navWalkers),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _WalkCard(walk: inProgress[i]),
                childCount: inProgress.length,
              ),
            ),
          ],
          if (upcoming.isNotEmpty) ...[
            _SectionHeader(label: 'Upcoming', color: AppColors.navWalks),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _WalkCard(walk: upcoming[i]),
                childCount: upcoming.length,
              ),
            ),
          ],
          if (completed.isNotEmpty) ...[
            _SectionHeader(label: 'Completed', color: const Color(0xFF8A95A3)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _WalkCard(walk: completed[i]),
                childCount: completed.length,
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _WalksAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navWalks.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.directions_walk_rounded,
                  color: AppColors.navWalks, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Walks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        background: Container(color: Colors.white),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkCard extends StatelessWidget {
  const _WalkCard({required this.walk});

  final Walk walk;

  void _onTap(BuildContext context) {
    switch (walk.status) {
      case WalkStatus.inProgress:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => LiveWalkScreen(walk: walk)),
        );
      case WalkStatus.upcoming:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => UpcomingWalkDetailPage(walk: walk)),
        );
      case WalkStatus.completed:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => CompletedWalkSummaryPage(walk: walk)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onTap(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PetAvatar(walk: walk),
                const SizedBox(width: 14),
                Expanded(child: _CardBody(walk: walk)),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          ClipOval(
            child: Image.network(
              walk.petImageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFE8F0F8),
                child: const Icon(Icons.pets,
                    color: AppColors.navWalks, size: 28),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: Image.network(
                  walk.walkerAvatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.navWalkers.withValues(alpha: 0.2),
                    child: const Icon(Icons.person,
                        color: AppColors.navWalkers, size: 12),
                  ),
                ),
              ),
            ),
          ),
          if (walk.status == WalkStatus.inProgress)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.navWalkers,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.walk});

  final Walk walk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              walk.petName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: walk.status),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'with ${walk.walkerName}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: Color(0xFF9AA0B2)),
            const SizedBox(width: 4),
            Text(
              _formatDate(walk.scheduledAt),
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0B2)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.schedule_outlined,
                size: 12, color: Color(0xFF9AA0B2)),
            const SizedBox(width: 4),
            Text(
              '${walk.durationMinutes} min',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0B2)),
            ),
          ],
        ),
        if (walk.status == WalkStatus.inProgress) ...[
          const SizedBox(height: 8),
          _ProgressBar(elapsed: walk.elapsedMinutes, total: walk.durationMinutes),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(DateTime(now.year, now.month, now.day));
    if (diff.inDays == 0) return 'Today, ${_timeStr(dt)}';
    if (diff.inDays == 1) return 'Tomorrow, ${_timeStr(dt)}';
    if (diff.inDays == -1) return 'Yesterday, ${_timeStr(dt)}';
    return '${dt.day}/${dt.month}/${dt.year}, ${_timeStr(dt)}';
  }

  String _timeStr(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.elapsed, required this.total});

  final int elapsed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = (elapsed / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE8F0F8),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navWalkers),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$elapsed / $total min',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.navWalkers,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WalkStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      WalkStatus.inProgress => ('Live', const Color(0xFFE8F8F0), AppColors.navWalkers),
      WalkStatus.upcoming => ('Upcoming', const Color(0xFFE8F0FB), AppColors.navWalks),
      WalkStatus.completed => ('Done', const Color(0xFFF0F0F0), const Color(0xFF8A95A3)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
