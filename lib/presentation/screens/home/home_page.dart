import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../bloc/my_walks/my_walks_cubit.dart';
import '../../bloc/my_walks/my_walks_state.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../pets/manage_pets_screen.dart';
import '../walks/live_walk_screen.dart';
import '../../widgets/skeletons/home_skeleton.dart';
import 'widgets/daily_tip_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/pet_hero_card.dart';
import 'widgets/quick_care_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenServices});

  final void Function(int filter)? onOpenServices;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileCubit>(
          create: (_) => sl<ProfileCubit>()..load(),
        ),
        BlocProvider<MyWalksCubit>(
          create: (_) => sl<MyWalksCubit>()..load(),
        ),
      ],
      child: _HomeView(onOpenServices: onOpenServices),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({this.onOpenServices});

  final void Function(int filter)? onOpenServices;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    // Poll walk status every 30 s so live card appears without manual refresh.
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<MyWalksCubit>().refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<MyWalksCubit>().refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _openServices(int filter) => widget.onOpenServices?.call(filter);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) return const HomeSkeleton();

              final firstName =
                  state is ProfileLoaded ? state.user.firstName : 'there';
              final photoUrl =
                  state is ProfileLoaded ? state.user.photoUrl : null;
              final pets =
                  state is ProfileLoaded ? state.pets : <Pet>[];

              return RefreshIndicator(
                onRefresh: () => context.read<MyWalksCubit>().refresh(),
                child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        GreetingHeader(
                          firstName: firstName,
                          photoUrl: photoUrl,
                          onNotificationTap: () {},
                        ),
                        const SizedBox(height: 20),
                        PetHeroCard(pets: pets, onTap: () {}),
                        const SizedBox(height: 16),
                        const _DailyTipFromState(),
                        const SizedBox(height: 26),
                        const _SectionTitle('Walks'),
                        const SizedBox(height: 12),
                        const _WalksSection(),
                        const SizedBox(height: 26),
                        const _SectionTitle('Quick care'),
                        const SizedBox(height: 12),
                        QuickCareGrid(
                          onClinicTap: () => _openServices(2),
                          onWalkerTap: () => _openServices(1),
                          onStoreTap:  () => _openServices(3),
                          onPetsTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<ProfileCubit>(),
                                child: const ManagePetsScreen(),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Daily tip ──────────────────────────────────────────────────────────────────

class _DailyTipFromState extends StatelessWidget {
  const _DailyTipFromState();

  static const _tips = [
    'Regular walks reduce anxiety in dogs and improve their mood throughout the day.',
    'Did you know that dogs need at least 30 minutes of exercise daily to stay healthy?',
    'Short, frequent walks are better for older dogs than one long outing.',
    'Sniff breaks during walks are mentally stimulating for your dog — let them explore!',
    'Walking your dog at the same time each day helps regulate their internal clock.',
  ];

  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().day % _tips.length;
    return DailyTipCard(tip: _tips[dayIndex]);
  }
}

// ── Walks section ──────────────────────────────────────────────────────────────

class _WalksSection extends StatelessWidget {
  const _WalksSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyWalksCubit, MyWalksState>(
      builder: (context, state) {
        if (state is MyWalksLoading || state is MyWalksInitial) {
          return const _WalksShimmer();
        }

        if (state is! MyWalksLoaded) {
          return const _EmptyWalksCard();
        }

        final cards = <Widget>[];

        final liveBooking = _findLiveBooking(state);
        if (liveBooking != null) {
          cards.add(_LiveWalkCard(booking: liveBooking));
          cards.add(const SizedBox(height: 10));
        }

        // Skip upcoming card if that booking is already the live one
        final nextUpcoming = state.upcoming
            .where((b) => b.id != liveBooking?.id)
            .firstOrNull;
        if (nextUpcoming != null) {
          cards.add(_UpcomingWalkCard(booking: nextUpcoming));
          cards.add(const SizedBox(height: 10));
        }

        if (cards.isEmpty) {
          return const _EmptyWalksCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards,
        );
      },
    );
  }

  WalkBooking? _findLiveBooking(MyWalksLoaded state) {
    for (final b in state.bookings) {
      if (b.status == WalkBookingStatus.inProgress) return b;
    }
    return null;
  }
}

// ── Live walk card ─────────────────────────────────────────────────────────────

class _LiveWalkCard extends StatelessWidget {
  const _LiveWalkCard({required this.booking});

  final WalkBooking booking;

  @override
  Widget build(BuildContext context) {
    final hasSession = booking.walkSessionId != null;
    final label = hasSession ? 'Walk in progress' : 'Walk starting soon';
    final sublabel = hasSession
        ? 'Your dog is out! Tap to see live location.'
        : _formatTime(booking.slotStart);

    return GestureDetector(
      onTap: hasSession
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LiveWalkScreen(booking: booking),
                ),
              )
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: hasSession
              ? const LinearGradient(
                  colors: [Color(0xFF1BAA71), Color(0xFF17956A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasSession ? null : const Color(0xFFE8F5EE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasSession
              ? [
                  BoxShadow(
                    color: const Color(0xFF1BAA71).withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: hasSession ? 0.2 : 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSession ? Icons.map_rounded : Icons.access_time_rounded,
                color: hasSession ? Colors.white : const Color(0xFF1BAA71),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (hasSession) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: hasSession ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasSession
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF5A6473),
                    ),
                  ),
                ],
              ),
            ),
            if (hasSession)
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return 'Today, $h:$m $ampm · ${booking.durationMinutes} min';
  }
}

// ── Upcoming walk card ─────────────────────────────────────────────────────────

class _UpcomingWalkCard extends StatelessWidget {
  const _UpcomingWalkCard({required this.booking});

  final WalkBooking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF3A80C2),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming walk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatSlot(booking.slotStart, booking.durationMinutes),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSlot(DateTime dt, int durationMinutes) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final isToday =
        local.year == now.year && local.month == now.month && local.day == now.day;
    final isTomorrow = local.difference(DateTime(now.year, now.month, now.day)).inDays == 1;
    final dayLabel = isToday
        ? 'Today'
        : isTomorrow
            ? 'Tomorrow'
            : '${_weekday(local.weekday)}, ${local.day}/${local.month}';
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '$dayLabel, $h:$m $ampm · $durationMinutes min';
  }

  String _weekday(int w) => const [
        '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
      ][w];
}

// ── Empty / loading states ─────────────────────────────────────────────────────

class _EmptyWalksCard extends StatelessWidget {
  const _EmptyWalksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.pets, size: 32, color: Color(0xFFD0D5DD)),
          SizedBox(height: 10),
          Text(
            'No upcoming walks',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A93A0),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Book a walker to get started',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B8C1)),
          ),
        ],
      ),
    );
  }
}

class _WalksShimmer extends StatelessWidget {
  const _WalksShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F5),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ── Section title ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF1BAA71),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
