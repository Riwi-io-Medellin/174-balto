import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/availability_slot.dart';
import '../../../domain/entities/home_provider_service_area.dart';
import '../../../domain/entities/home_provider_service_item.dart';
import '../../../domain/entities/home_service_provider.dart';
import '../../../domain/repositories/home_favorite_provider_repository.dart';
import '../../bloc/feedback/feedback_cubit.dart';
import '../../bloc/feedback/feedback_state.dart';
import '../../bloc/home_service/home_service_cubit.dart';
import '../../bloc/home_service/home_service_state.dart';
import '../../widgets/rating_summary.dart';
import '../../widgets/review_card.dart';
import '../../widgets/review_sheet.dart';
import 'home_service_booking_screen.dart';

class HomeServiceProviderProfilePage extends StatefulWidget {
  const HomeServiceProviderProfilePage({super.key, required this.provider});

  final HomeServiceProvider provider;

  @override
  State<HomeServiceProviderProfilePage> createState() =>
      _HomeServiceProviderProfilePageState();
}

class _HomeServiceProviderProfilePageState
    extends State<HomeServiceProviderProfilePage> {
  late final HomeServiceCubit _cubit;
  late final FeedbackCubit _feedbackCubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<HomeServiceCubit>();
    _feedbackCubit = sl<FeedbackCubit>();
    if (widget.provider.id.isNotEmpty) {
      _cubit.loadProviderDetail(widget.provider.id);
      _feedbackCubit.loadHomeServiceProviderReviews(widget.provider.id);
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
      child: BlocBuilder<HomeServiceCubit, HomeServiceState>(
        builder: (context, state) {
          final provider = state is HomeServiceDetailLoaded
              ? state.provider
              : widget.provider;
          final isLoadingDetail = state is HomeServiceLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            bottomNavigationBar: _BookingBar(provider: provider),
            body: CustomScrollView(
              slivers: [
                _ProviderAppBar(providerId: provider.id),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(provider: provider),
                      if (isLoadingDetail)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.homeServices,
                            ),
                          ),
                        ),
                      if (provider.galleryImages.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _GalleryStrip(images: provider.galleryImages),
                      ],
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _AboutCard(
                          provider: provider,
                          firstName: provider.name.split(' ').first,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ServicesSection(services: provider.services),
                      ),
                      if (provider.serviceAreas.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _ServiceAreasSection(
                            areas: provider.serviceAreas,
                          ),
                        ),
                      ],
                      if (provider.weeklyAvailability.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _WeeklyScheduleSection(
                            slots: provider.weeklyAvailability,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _ReviewsSection(
                          providerId: provider.id,
                          providerName: provider.name,
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

class _ProviderAppBar extends StatelessWidget {
  const _ProviderAppBar({required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
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
      actions: [_FavoriteButton(providerId: providerId)],
    );
  }
}

// Owns its own favorite-toggle state so tapping it doesn't rebuild the
// whole provider profile (gallery, about, services, schedule, reviews).
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.providerId});

  final String providerId;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.providerId.isNotEmpty) _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final ids = await sl<HomeFavoriteProviderRepository>()
          .getMyFavoriteProviderIds();
      if (!mounted) return;
      setState(() => _isFavorite = ids.contains(widget.providerId));
    } catch (_) {
      // ignore — favorites are a non-critical enhancement
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repo = sl<HomeFavoriteProviderRepository>();
      if (_isFavorite) {
        await repo.removeFavorite(widget.providerId);
      } else {
        await repo.addFavorite(widget.providerId);
      }
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
    } on HomeFavoriteProviderFailure catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      BaltoToast.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggle,
      icon: Icon(
        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: _isFavorite ? AppColors.homeServices : const Color(0xFF1F2937),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.provider});

  final HomeServiceProvider provider;

  String get _reviewsText {
    final c = provider.reviews;
    return c >= 1000
        ? '(${(c / 1000).toStringAsFixed(1)}k reviews)'
        : '($c reviews)';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = provider.avatarUrl ?? provider.imageUrl;
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
                  color: const Color(0xFFFBEAF1),
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
          Text(
            'HOME SERVICE PROVIDER',
            style: AppTextStyles.micro.copyWith(
              color: const Color(0xFF8A93A0),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            provider.name,
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
                '${provider.rating}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                ' $_reviewsText',
                style: const TextStyle(fontSize: 14, color: Color(0xFF8A93A0)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (provider.yearsOfExperience > 0) ...[
                Text(
                  '${provider.yearsOfExperience} years exp.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5A6473),
                  ),
                ),
                if (provider.isVerified)
                  const Text(
                    '  ·  ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
                  ),
              ],
              if (provider.isVerified)
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
                      style: AppTextStyles.label.copyWith(
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
          borderRadius: AppRadius.radius14,
          child: Image.network(
            images[i],
            width: 220,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 220,
              height: 160,
              color: const Color(0xFFFBEAF1),
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
  const _AboutCard({required this.provider, required this.firstName});

  final HomeServiceProvider provider;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final bio = provider.biography ?? provider.description;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
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
                  color: AppColors.homeServices.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.homeServices,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'About $firstName',
                style: AppTextStyles.titleSmall.copyWith(
                  color: const Color(0xFF1F2937),
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
          if (provider.specialties.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.specialties
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
        borderRadius: AppRadius.radiusPill,
        border: Border.all(color: const Color(0xFFE0E4EC)),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionStrong.copyWith(
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }
}

// ─── Services & Pricing ────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.services});

  final List<HomeProviderServiceItem> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Offered',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 14),
        if (services.isEmpty)
          const Text(
            'No services listed yet.',
            style: TextStyle(color: Color(0xFF8A93A0)),
          )
        else
          ...services
              .where((s) => s.isActive)
              .map(
                (s) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.radius14,
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.homeServices.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.design_services_rounded,
                          size: 18,
                          color: AppColors.homeServices,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.serviceTypeName,
                          style: AppTextStyles.bodyBold.copyWith(
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Text(
                        s.priceLabel,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.homeServices,
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

// ─── Service Areas ─────────────────────────────────────────────────────────────

class _ServiceAreasSection extends StatelessWidget {
  const _ServiceAreasSection({required this.areas});

  final List<HomeProviderServiceArea> areas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Areas',
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
          children: areas
              .map(
                (a) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.homeServices.withValues(alpha: 0.08),
                    borderRadius: AppRadius.radius10,
                    border: Border.all(
                      color: AppColors.homeServices.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        size: 14,
                        color: AppColors.homeServices,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${a.label ?? 'Area'} · ${a.radiusKm.toStringAsFixed(0)}km',
                        style: AppTextStyles.captionStrong.copyWith(
                          color: AppColors.homeServices,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── Weekly Schedule ─────────────────────────────────────────────────────────

class _WeeklyScheduleSection extends StatelessWidget {
  const _WeeklyScheduleSection({required this.slots});

  final List<AvailabilitySlot> slots;

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _daysFull = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
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
    final activeDays = List.generate(
      7,
      (i) => i,
    ).where((d) => grouped.containsKey(d)).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
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
                  color: AppColors.homeServices.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: AppColors.homeServices,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Weekly Schedule',
                style: AppTextStyles.titleSmall.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                      ? AppColors.homeServices
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
                      style: AppTextStyles.label.copyWith(
                        color: const Color(0xFF1F2937),
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
                            color: AppColors.homeServices.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: AppRadius.radius8,
                            border: Border.all(
                              color: AppColors.homeServices.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Text(
                            '${_fmt(s.startTime)} – ${_fmt(s.endTime)}',
                            style: AppTextStyles.captionStrong.copyWith(
                              color: AppColors.homeServices,
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

// ─── Ratings & Reviews ────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.providerId, required this.providerName});

  final String providerId;
  final String providerName;

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
                  child: CircularProgressIndicator(
                    color: AppColors.homeServices,
                  ),
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
                    targetId: providerId,
                    targetType: 'home_service_provider',
                    targetName: providerName,
                    title: 'Rate this provider',
                    subtitle: 'How was your experience with $providerName?',
                  ),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Write a Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.homeServices,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radius12,
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

// ─── Booking Bar ─────────────────────────────────────────────────────────────

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.provider});

  final HomeServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.sheet,
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.startingPriceLabel,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: AppColors.homeServices,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'BOOK NOW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.homeServices,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: provider.services.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) =>
                            HomeServiceBookingScreen(provider: provider),
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE0E4EC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radius14),
              ),
              child: const Text(
                'Book Service',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
