import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../bloc/my_walks/my_walks_cubit.dart';
import '../../bloc/my_walks/my_walks_state.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import 'widgets/daily_tip_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/pet_hero_card.dart';
import 'widgets/quick_care_grid.dart';
import 'widgets/walk_card.dart';
import '../pets/manage_pets_screen.dart';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const String _kDailyTip =
      'Did you know that Border Collies need more attention to burn energy and be happy?';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
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
              final firstName =
                  state is ProfileLoaded ? state.user.firstName : 'there';
              final photoUrl =
                  state is ProfileLoaded ? state.user.photoUrl : null;
              final pets =
                  state is ProfileLoaded ? state.pets : <Pet>[];

              return CustomScrollView(
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
                        const DailyTipCard(tip: _kDailyTip),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Walks section ────────────────────────────────────────────────────────────

class _WalksSection extends StatelessWidget {
  const _WalksSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyWalksCubit, MyWalksState>(
      builder: (context, state) {
        if (state is MyWalksLoading || state is MyWalksInitial) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (state is! MyWalksLoaded) return const SizedBox.shrink();

        final entries = _buildEntries(state);

        if (entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No walks yet.',
              style: TextStyle(fontSize: 14, color: Color(0xFF8A93A0)),
            ),
          );
        }

        return Column(
          children: entries
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WalkCard(entry: e, onTap: () {}),
                  ))
              .toList(),
        );
      },
    );
  }

  List<WalkEntry> _buildEntries(MyWalksLoaded state) {
    final entries = <WalkEntry>[];

    for (final b in state.inProgress) {
      entries.add(_toEntry(b, isActive: true));
    }

    final upcoming = [
      ...state.pending,
      ...state.upcoming,
    ]..sort((a, b) => a.slotStart.compareTo(b.slotStart));

    for (final b in upcoming.take(3)) {
      entries.add(_toEntry(b));
    }

    for (final b in state.history.take(2)) {
      entries.add(_toEntry(b));
    }

    return entries;
  }

  WalkEntry _toEntry(WalkBooking b, {bool isActive = false}) {
    final local = b.slotStart.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay = DateTime(local.year, local.month, local.day);

    String dateLabel;
    if (slotDay == today) {
      dateLabel = 'Today';
    } else if (slotDay == today.subtract(const Duration(days: 1))) {
      dateLabel = 'Yesterday';
    } else if (slotDay == today.add(const Duration(days: 1))) {
      dateLabel = 'Tomorrow';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      dateLabel = '${months[local.month - 1]} ${local.day}';
    }

    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeLabel = '$h:$minute $period';

    final statusLabel = _statusLabel(b.status, isActive: isActive);

    return WalkEntry(
      title: '$statusLabel · $dateLabel',
      subtitle: '$timeLabel · ${b.durationMinutes} min',
      isActive: isActive,
      statusColor: _statusColor(b.status, isActive: isActive),
    );
  }

  String _statusLabel(WalkBookingStatus status, {bool isActive = false}) {
    if (isActive) return 'Current walk';
    return switch (status) {
      WalkBookingStatus.pending         => 'Pending approval',
      WalkBookingStatus.accepted        => 'Upcoming walk',
      WalkBookingStatus.completed       => 'Completed',
      WalkBookingStatus.rejected        => 'Rejected',
      WalkBookingStatus.walkerCancelled => 'Cancelled by walker',
      WalkBookingStatus.ownerCancelled  => 'Cancelled',
    };
  }

  Color _statusColor(WalkBookingStatus status, {bool isActive = false}) {
    if (isActive) return const Color(0xFF1BAA71);   // green
    return switch (status) {
      WalkBookingStatus.pending         => const Color(0xFFD05A24),  // orange
      WalkBookingStatus.accepted        => const Color(0xFF3A80C2),  // blue
      WalkBookingStatus.completed       => const Color(0xFF9CA3AF),  // gray
      WalkBookingStatus.rejected        => const Color(0xFFE53E3E),  // red
      WalkBookingStatus.walkerCancelled => const Color(0xFFE53E3E),  // red
      WalkBookingStatus.ownerCancelled  => const Color(0xFF9CA3AF),  // gray
    };
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

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
