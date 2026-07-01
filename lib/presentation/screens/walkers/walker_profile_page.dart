import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/availability_slot.dart';
import '../../../domain/entities/available_slot.dart';
import '../../../domain/entities/walker.dart';
import '../../bloc/feedback/feedback_cubit.dart';
import '../../bloc/feedback/feedback_state.dart';
import '../../bloc/walker/walker_cubit.dart';
import '../../bloc/walker/walker_state.dart';
import '../../widgets/rating_summary.dart';
import '../../widgets/review_card.dart';
import '../../widgets/review_sheet.dart';
import 'booking_screen.dart';

class WalkerProfilePage extends StatefulWidget {
  const WalkerProfilePage({super.key, required this.walker});

  final Walker walker;

  @override
  State<WalkerProfilePage> createState() => _WalkerProfilePageState();
}

class _WalkerProfilePageState extends State<WalkerProfilePage> {
  late final WalkerCubit _cubit;
  late final FeedbackCubit _feedbackCubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<WalkerCubit>();
    _feedbackCubit = sl<FeedbackCubit>();
    if (widget.walker.id.isNotEmpty) {
      _cubit.loadWalkerDetail(widget.walker.id);
      _feedbackCubit.loadWalkerReviews(widget.walker.id);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _feedbackCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _feedbackCubit),
      ],
      child: BlocBuilder<WalkerCubit, WalkerState>(
        builder: (context, state) {
          final walker =
              state is WalkerDetailLoaded ? state.walker : widget.walker;
          final isLoadingDetail = state is WalkerLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            bottomNavigationBar: _BookingBar(walker: walker),
            body: CustomScrollView(
              slivers: [
                _WalkerAppBar(walker: walker),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(walker: walker),
                      if (isLoadingDetail)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.navWalkers,
                            ),
                          ),
                        ),
                      if (walker.galleryImages.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _GalleryStrip(images: walker.galleryImages),
                      ],
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _AboutCard(
                          walker: walker,
                          firstName: walker.name.split(' ').first,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ServiceDetailsSection(walker: walker),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ServiceAreaCard(area: walker.serviceArea),
                      ),
                      if (walker.weeklyAvailability.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _WeeklyScheduleSection(
                            slots: walker.weeklyAvailability,
                          ),
                        ),
                      ],
                      if (walker.availableSlots.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _AvailabilitySlotsSection(
                            slots: walker.availableSlots,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _WalkerReviewsSection(
                          walkerId: walker.id,
                          walkerName: walker.name,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _WalkerAppBar extends StatelessWidget {
  const _WalkerAppBar({required this.walker});

  final Walker walker;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFFF5F6FA),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.walker});

  final Walker walker;

  String get _reviewsText {
    final c = walker.reviews;
    return c >= 1000
        ? '(${(c / 1000).toStringAsFixed(1)}k reviews)'
        : '($c reviews)';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = walker.avatarUrl ?? walker.imageUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFE8F5EE),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: Color(0xFFB0B8C1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'WALKER PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A93A0),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            walker.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFF6C86A),
              ),
              const SizedBox(width: 4),
              Text(
                '${walker.rating}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                ' $_reviewsText',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A93A0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (walker.yearsOfExperience > 0) ...[
                Text(
                  '${walker.yearsOfExperience} years exp.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5A6473),
                  ),
                ),
                if (walker.isVerified)
                  const Text(
                    '  ·  ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
                  ),
              ],
              if (walker.isVerified)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.navCoach,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navCoach,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Gallery ──────────────────────────────────────────────────────────────────

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            images[i],
            width: 220,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 220,
              height: 160,
              color: const Color(0xFFE8F5EE),
              child: const Icon(
                Icons.image_outlined,
                size: 36,
                color: Color(0xFFB0B8C1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── About Card ──────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.walker, required this.firstName});

  final Walker walker;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final bio = walker.biography ?? walker.description;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.navWalkers.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.navWalkers,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'About $firstName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A6473),
              height: 1.55,
            ),
          ),
          if (walker.specialties.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: walker.specialties
                  .map((s) => _SpecialtyChip(label: s))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568),
        ),
      ),
    );
  }
}

// ─── Service Details ──────────────────────────────────────────────────────────

class _ServiceDetailsSection extends StatelessWidget {
  const _ServiceDetailsSection({required this.walker});

  final Walker walker;

  String _completedLabel(int? n) {
    if (n == null) return '—';
    return n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k+' : '$n+';
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <_StatTileData>[
      _StatTileData(
        icon: Icons.payments_outlined,
        iconColor: AppColors.navWalks,
        bgColor: const Color(0xFFEBF3FB),
        value: walker.pricePerWalk != null
            ? '\$${walker.pricePerWalk!.toStringAsFixed(0)}/walk'
            : walker.priceLabel,
        label: 'Price',
      ),
      _StatTileData(
        icon: Icons.location_on_outlined,
        iconColor: AppColors.navWalkers,
        bgColor: const Color(0xFFE8F8F2),
        value: walker.serviceRadiusKm != null
            ? '${walker.serviceRadiusKm!.round()} km'
            : (walker.serviceArea ?? '—'),
        label: walker.serviceRadiusKm != null ? 'Radius' : 'Area',
      ),
      _StatTileData(
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.navCoach,
        bgColor: const Color(0xFFE5F7F9),
        value: _completedLabel(walker.completedWalks),
        label: 'Completed',
      ),
      _StatTileData(
        icon: Icons.pets_rounded,
        iconColor: AppColors.navProfile,
        bgColor: const Color(0xFFFBF3E5),
        value: walker.maxDogs?.toString() ?? '—',
        label: 'Max Dogs',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.65,
          children: tiles.map((t) => _StatTile(data: t)).toList(),
        ),
      ],
    );
  }
}

class _StatTileData {
  const _StatTileData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 22, color: data.iconColor),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8A93A0),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Service Area ─────────────────────────────────────────────────────────────

class _ServiceAreaCard extends StatelessWidget {
  const _ServiceAreaCard({required this.area});

  final String? area;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Area',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(color: const Color(0xFFDEEBD8)),
                // Road-like horizontal lines
                Positioned.fill(
                  child: CustomPaint(painter: _MapGridPainter()),
                ),
                // Service radius circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.navWalks.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.navWalks.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
                // Center pin dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.navWalks,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navWalks.withValues(alpha: 0.45),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (area != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        area!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBFD1B8)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Ratings & Reviews ────────────────────────────────────────────────────────

class _WalkerReviewsSection extends StatelessWidget {
  const _WalkerReviewsSection({
    required this.walkerId,
    required this.walkerName,
  });

  final String walkerId;
  final String walkerName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            if (state is FeedbackLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: AppColors.navWalkers),
                ),
              )
            else if (state is FeedbackError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Color(0xFF8A93A0)),
                  ),
                ),
              )
            else if (state is FeedbackLoaded) ...[
              RatingSummary(summary: state.summary),
              if (state.summary.reviews.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...state.summary.reviews.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReviewCard(review: r),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'No reviews yet.',
                    style: TextStyle(color: Color(0xFF8A93A0)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => showReviewSheet(
                    context: context,
                    targetId: walkerId,
                    targetType: 'walker',
                    targetName: walkerName,
                    title: 'Rate this walker',
                    subtitle: 'How was your experience with $walkerName?',
                  ),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Write a Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navWalkers,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Weekly Schedule ─────────────────────────────────────────────────────────

class _WeeklyScheduleSection extends StatelessWidget {
  const _WeeklyScheduleSection({required this.slots});

  final List<AvailabilitySlot> slots;

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _daysFull = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  Map<int, List<AvailabilitySlot>> _group() {
    final map = <int, List<AvailabilitySlot>>{};
    for (final s in slots) {
      map.putIfAbsent(s.dayOfWeek, () => []).add(s);
    }
    return map;
  }

  String _fmt(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _group();
    final activeDays = List.generate(7, (i) => i)
        .where((d) => grouped.containsKey(d))
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.navWalkers.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppColors.navWalkers,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Weekly Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day pills row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(7, (i) {
              final active = grouped.containsKey(i);
              return Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.navWalkers
                      : const Color(0xFFF0F2F5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _days[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : const Color(0xFFB0B8C1),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Time slots per active day
          ...activeDays.map((day) {
            final daySlots = grouped[day]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _daysFull[day],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: daySlots.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.navWalkers.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.navWalkers.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            '${_fmt(s.startTime)} – ${_fmt(s.endTime)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navWalkers,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Availability Slots (Today) ───────────────────────────────────────────────

class _AvailabilitySlotsSection extends StatelessWidget {
  const _AvailabilitySlotsSection({required this.slots});

  final List<AvailableSlot> slots;

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Today',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots
              .map(
                (s) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navWalkers.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.navWalkers.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _formatTime(s.start),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navWalkers,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── Booking Bar ─────────────────────────────────────────────────────────────

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.walker});

  final Walker walker;

  String get _priceLabel {
    if (walker.pricePerWalk != null) {
      return '\$${walker.pricePerWalk!.toStringAsFixed(0)}';
    }
    return walker.priceLabel;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_priceLabel / walk',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: AppColors.navWalkers,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'INSTANT BOOK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navWalkers,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => BookingScreen(walker: walker),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Book a Walk',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
