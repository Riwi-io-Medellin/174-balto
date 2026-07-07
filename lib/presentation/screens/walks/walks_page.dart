import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../widgets/skeletons/walks_skeleton.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../bloc/my_walks/my_walks_cubit.dart';
import '../../bloc/my_walks/my_walks_state.dart';
import '../../widgets/balto_dialog.dart';
import '../../widgets/balto_header.dart';
import '../../widgets/balto_screen_scaffold.dart';
import '../../widgets/states/empty_state_view.dart';
import '../../widgets/states/error_state_view.dart';
import 'live_walk_screen.dart';
import 'walk_route_summary_screen.dart';

class WalksPage extends StatelessWidget {
  const WalksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyWalksCubit>(
      create: (_) => sl<MyWalksCubit>()..load(),
      child: const _WalksView(),
    );
  }
}

class _WalksView extends StatelessWidget {
  const _WalksView();

  @override
  Widget build(BuildContext context) {
    return BaltoScreenScaffold(
      header: BaltoHeader.iconTitle(
        icon: Icons.directions_walk_rounded,
        iconColor: AppColors.navWalks,
        title: 'My Walks',
      ),
      body: BlocConsumer<MyWalksCubit, MyWalksState>(
        listener: (context, state) {
          if (state is MyWalksLoaded) {
            if (state.successMessage != null) {
              BaltoToast.success(context, state.successMessage!);
              context.read<MyWalksCubit>().clearMessages();
            }
            if (state.errorMessage != null) {
              BaltoToast.error(context, state.errorMessage!);
              context.read<MyWalksCubit>().clearMessages();
            }
          }
        },
        builder: (context, state) {
          if (state is MyWalksLoading) {
            return const WalksSkeleton();
          }

          if (state is MyWalksError) {
            return ErrorStateView(
              message: state.message,
              accentColor: AppColors.navWalks,
              onRetry: () => context.read<MyWalksCubit>().load(),
            );
          }

          if (state is MyWalksLoaded) {
            final now = DateTime.now();
            final completedToday = state.history
                .where((b) =>
                    b.status == WalkBookingStatus.completed &&
                    b.slotStart.year == now.year &&
                    b.slotStart.month == now.month &&
                    b.slotStart.day == now.day)
                .toList()
              ..sort((a, b) => b.slotStart.compareTo(a.slotStart));
            final olderHistory = state.history
                .where((b) => !completedToday.contains(b))
                .toList();
            final isEmpty = state.inProgress.isEmpty &&
                state.pending.isEmpty &&
                state.upcoming.isEmpty &&
                completedToday.isEmpty &&
                olderHistory.isEmpty;

            return RefreshIndicator(
              color: AppColors.navWalks,
              onRefresh: () => context.read<MyWalksCubit>().refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (state.inProgress.isNotEmpty) ...[
                    const _SectionHeader(
                        label: 'In Progress',
                        color: AppColors.navWalkers),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _BookingCard(booking: state.inProgress[i]),
                        childCount: state.inProgress.length,
                      ),
                    ),
                  ],
                  if (state.pending.isNotEmpty) ...[
                    const _SectionHeader(
                        label: 'Pending',
                        color: AppColors.alert),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _BookingCard(booking: state.pending[i]),
                        childCount: state.pending.length,
                      ),
                    ),
                  ],
                  if (state.upcoming.isNotEmpty) ...[
                    const _SectionHeader(
                        label: 'Upcoming',
                        color: AppColors.navWalks),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _BookingCard(booking: state.upcoming[i]),
                        childCount: state.upcoming.length,
                      ),
                    ),
                  ],
                  if (completedToday.isNotEmpty) ...[
                    const _SectionHeader(
                        label: 'Completed Today',
                        color: AppColors.petProfile),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _BookingCard(booking: completedToday[i]),
                        childCount: completedToday.length,
                      ),
                    ),
                  ],
                  if (olderHistory.isNotEmpty) ...[
                    const _SectionHeader(
                        label: 'History',
                        color: AppColors.textSecondary),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _BookingCard(booking: olderHistory[i]),
                        childCount: olderHistory.length,
                      ),
                    ),
                  ],
                  if (isEmpty)
                    const SliverFillRemaining(
                      child: EmptyStateView(
                        icon: Icons.directions_walk_rounded,
                        title: 'No walks yet.',
                        subtitle: 'Book a walker to get started.',
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
                borderRadius: AppRadius.radius2,
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final WalkBooking booking;

  bool _isInProgress() {
    // Backend status "in_progress" means walker has started.
    if (booking.status == WalkBookingStatus.inProgress) return true;
    if (booking.status != WalkBookingStatus.accepted) return false;
    // Accepted + active session = still live (started before scheduled slot).
    if (booking.walkSessionId != null) return true;
    // Accepted + inside scheduled window.
    final now = DateTime.now();
    final window = booking.slotStart.subtract(const Duration(minutes: 5));
    final end = booking.slotStart.add(Duration(minutes: booking.durationMinutes));
    return now.isAfter(window) && now.isBefore(end);
  }

  bool _canCancel() {
    if (booking.status == WalkBookingStatus.pending) return true;
    if (booking.status == WalkBookingStatus.accepted) {
      return booking.slotStart.isAfter(DateTime.now());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final inProgress = _isInProgress();
    final canCancel = _canCancel();
    final local = booking.slotStart.toLocal();
    final now = DateTime.now();
    final elapsed = inProgress
        ? now.difference(booking.slotStart).inMinutes.clamp(0, booking.durationMinutes)
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: inProgress
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveWalkScreen(booking: booking),
                    ),
                  )
              : booking.status == WalkBookingStatus.completed &&
                      booking.walkSessionId != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WalkRouteSummaryScreen(
                            sessionId: booking.walkSessionId!,
                            distanceKm:
                                (booking.actualDistanceMeters ?? 0) / 1000,
                            elapsedSeconds: booking.actualDurationSeconds ??
                                booking.durationMinutes * 60,
                            walkerId: booking.walkerId,
                            walkerName: booking.walkerName,
                          ),
                        ),
                      )
                  : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.radius16,
              border: Border.all(color: Colors.grey.shade100),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: inProgress
                          ? AppColors.navWalkers.withValues(alpha: 0.12)
                          : AppColors.navWalks.withValues(alpha: 0.10),
                      borderRadius: AppRadius.radius12,
                    ),
                    child: Icon(
                      Icons.directions_walk_rounded,
                      color: inProgress
                          ? AppColors.navWalkers
                          : AppColors.navWalks,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusBadge(
                          status: booking.status,
                          isInProgress: inProgress,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatSlot(local),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_outlined,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.durationMinutes} min',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (booking.totalPrice != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money_rounded,
                        size: 13, color: Colors.grey.shade500),
                    Text(
                      booking.totalPrice!.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ] else if (booking.snapshotHourlyRate != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money_rounded,
                        size: 13, color: Colors.grey.shade500),
                    Text(
                      '${booking.snapshotHourlyRate!.toStringAsFixed(2)}/hr',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
              if (booking.specialInstructions != null &&
                  booking.specialInstructions!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_rounded,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.specialInstructions!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ],
              if (inProgress) ...[
                const SizedBox(height: 12),
                _ProgressBar(
                    elapsed: elapsed,
                    total: booking.durationMinutes),
              ],
              if (canCancel) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: context
                            .read<MyWalksCubit>()
                            .state
                            .runtimeType ==
                        MyWalksLoaded &&
                        (context.read<MyWalksCubit>().state
                                as MyWalksLoaded)
                            .isPerformingAction
                        ? null
                        : () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.alert,
                      side: const BorderSide(color: AppColors.alert),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radius10),
                    ),
                    child: const Text('Cancel Booking',
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await BaltoDialog.confirm(
      context,
      title: 'Cancel booking?',
      message: 'This action cannot be undone. The walker will be notified.',
      confirmLabel: 'Yes, cancel',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<MyWalksCubit>().cancelBooking(booking.id);
    }
  }

  static String _formatSlot(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '$day, $month ${dt.day} · $hour:$minute $amPm';
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.elapsed, required this.total});

  final int elapsed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadius.radius4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE8F0F8),
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.navWalkers),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$elapsed / $total min',
          style: AppTextStyles.micro.copyWith(color: AppColors.navWalkers),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(
      {required this.status, required this.isInProgress});

  final WalkBookingStatus status;
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radius20,
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

  (String, Color, Color) _resolve() {
    if (isInProgress) {
      return (
        'Live',
        AppColors.navWalkers.withValues(alpha: 0.12),
        AppColors.navWalkers,
      );
    }
    return switch (status) {
      WalkBookingStatus.pending => (
          'Pending',
          AppColors.alert.withValues(alpha: 0.12),
          AppColors.alert,
        ),
      WalkBookingStatus.accepted => (
          'Upcoming',
          AppColors.navWalks.withValues(alpha: 0.12),
          AppColors.navWalks,
        ),
      WalkBookingStatus.inProgress => (
          'Live',
          AppColors.navWalkers.withValues(alpha: 0.12),
          AppColors.navWalkers,
        ),
      WalkBookingStatus.completed => (
          'Completed',
          const Color(0xFFF0F0F0),
          const Color(0xFF8A95A3),
        ),
      WalkBookingStatus.rejected => (
          'Rejected',
          AppColors.alert.withValues(alpha: 0.10),
          AppColors.alert,
        ),
      WalkBookingStatus.walkerCancelled ||
      WalkBookingStatus.ownerCancelled => (
          'Cancelled',
          const Color(0xFFF0F0F0),
          const Color(0xFF8A95A3),
        ),
    };
  }
}
