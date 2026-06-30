import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../widgets/skeletons/walker_bookings_skeleton.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../bloc/walker_booking/walker_booking_cubit.dart';
import '../../bloc/walker_booking/walker_booking_state.dart';
import 'walker_live_walk_screen.dart';

class WalkerBookingsScreen extends StatelessWidget {
  const WalkerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalkerBookingCubit>(
      create: (_) => sl<WalkerBookingCubit>()..load(),
      child: const _WalkerBookingsView(),
    );
  }
}

class _WalkerBookingsView extends StatelessWidget {
  const _WalkerBookingsView();

  static const _green = Color(0xFF1BAA71);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Bookings',
            style: TextStyle(
              color: _green,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: _green),
          bottom: TabBar(
            labelColor: _green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _green,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: BlocConsumer<WalkerBookingCubit, WalkerBookingState>(
          listener: (context, state) {
            if (state is WalkerBookingLoaded) {
              if (state.successMessage != null) {
                BaltoToast.success(context, state.successMessage!);
                context.read<WalkerBookingCubit>().clearMessages();
              }
              if (state.errorMessage != null) {
                BaltoToast.error(context, state.errorMessage!);
                context.read<WalkerBookingCubit>().clearMessages();
              }
            }
          },
          builder: (context, state) {
            if (state is WalkerBookingLoading) {
              return const WalkerBookingsSkeleton();
            }
            if (state is WalkerBookingError) {
              return _ErrorBody(
                message: state.message,
                onRetry: () => context.read<WalkerBookingCubit>().load(),
              );
            }
            if (state is WalkerBookingLoaded) {
              return TabBarView(
                children: [
                  _BookingList(
                    bookings: state.pending,
                    emptyMessage: 'No pending bookings.',
                    isPerformingAction: state.isPerformingAction,
                    tabType: _TabType.pending,
                    acceptedBookings: state.upcoming,
                  ),
                  _BookingList(
                    bookings: state.upcoming,
                    emptyMessage: 'No upcoming bookings.',
                    isPerformingAction: state.isPerformingAction,
                    tabType: _TabType.upcoming,
                  ),
                  _BookingList(
                    bookings: state.completed,
                    emptyMessage: 'No completed bookings.',
                    isPerformingAction: state.isPerformingAction,
                    tabType: _TabType.completed,
                  ),
                  _BookingList(
                    bookings: state.cancelled,
                    emptyMessage: 'No cancelled bookings.',
                    isPerformingAction: state.isPerformingAction,
                    tabType: _TabType.cancelled,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

enum _TabType { pending, upcoming, completed, cancelled }

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1BAA71),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.isPerformingAction,
    required this.tabType,
    this.acceptedBookings = const [],
  });

  final List<WalkBooking> bookings;
  final String emptyMessage;
  final bool isPerformingAction;
  final _TabType tabType;
  final List<WalkBooking> acceptedBookings;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1BAA71),
      onRefresh: () => context.read<WalkerBookingCubit>().refresh(),
      child: bookings.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: bookings.length,
              itemBuilder: (context, index) => _BookingCard(
                booking: bookings[index],
                isPerformingAction: isPerformingAction,
                tabType: tabType,
                acceptedBookings: acceptedBookings,
              ),
            ),
    );
  }
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isPerformingAction,
    required this.tabType,
    this.acceptedBookings = const [],
  });

  final WalkBooking booking;
  final bool isPerformingAction;
  final _TabType tabType;
  final List<WalkBooking> acceptedBookings;

  static const _green = Color(0xFF1BAA71);
  static const _orange = Color(0xFFD05A24);

  bool _canStart() {
    if (booking.status != WalkBookingStatus.accepted) return false;
    final now = DateTime.now();
    // Allow starting from 15 minutes before the scheduled time
    final window = booking.slotStart.subtract(const Duration(minutes: 15));
    final end =
        booking.slotStart.add(Duration(minutes: booking.durationMinutes));
    return now.isAfter(window) && now.isBefore(end);
  }

  double? _minDistanceKmToAccepted() {
    if (booking.ownerLatitude == null || booking.ownerLongitude == null) return null;
    double? minDist;
    for (final b in acceptedBookings) {
      if (b.ownerLatitude == null || b.ownerLongitude == null) continue;
      final d = _haversineKm(
        booking.ownerLatitude!, booking.ownerLongitude!,
        b.ownerLatitude!, b.ownerLongitude!,
      );
      if (minDist == null || d < minDist) minDist = d;
    }
    return minDist;
  }

  @override
  Widget build(BuildContext context) {
    final local = booking.slotStart.toLocal();
    final dateStr = _formatSlot(local);
    final duration = '${booking.durationMinutes} min';
    final price = booking.totalPrice != null
        ? '\$${booking.totalPrice!.toStringAsFixed(2)}'
        : booking.snapshotHourlyRate != null
            ? '\$${booking.snapshotHourlyRate!.toStringAsFixed(2)}/hr'
            : null;

    final distKm = tabType == _TabType.pending ? _minDistanceKmToAccepted() : null;
    final isFarAway = distKm != null && distKm > 3.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFarAway ? const Color(0xFFFFD97A) : Colors.grey.shade200,
          width: isFarAway ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(duration,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black87)),
                if (price != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.attach_money_rounded,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(price,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87)),
                ],
              ],
            ),
            if (booking.specialInstructions != null &&
                booking.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.specialInstructions!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ],
            if (tabType == _TabType.pending && booking.ownerAddress != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_rounded, size: 14, color: Color(0xFF3A80C2)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.ownerAddress!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF3A80C2)),
                    ),
                  ),
                ],
              ),
            ],
            if (isFarAway) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8EC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD97A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 15, color: Color(0xFFB87300)),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${distKm.toStringAsFixed(1)} km from your accepted walk — accepting may be difficult.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB87300),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (tabType == _TabType.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isPerformingAction
                          ? null
                          : () =>
                              _confirmAction(context, 'Reject this booking?',
                                  'The client will be notified.', () {
                                context
                                    .read<WalkerBookingCubit>()
                                    .rejectBooking(booking.id);
                              }),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _orange,
                        side: const BorderSide(color: _orange),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reject',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isPerformingAction
                          ? null
                          : () =>
                              _confirmAction(context, 'Accept this booking?',
                                  'The client will be notified.', () {
                                context
                                    .read<WalkerBookingCubit>()
                                    .acceptBooking(booking.id);
                              }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isPerformingAction
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Accept',
                              style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
            if (tabType == _TabType.upcoming) ...[
              const SizedBox(height: 12),
              if (_canStart())
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WalkerLiveWalkScreen(booking: booking),
                      ),
                    ),
                    icon: const Icon(Icons.directions_walk_rounded, size: 18),
                    label: const Text(
                      'Start Walk',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              if (_canStart()) const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isPerformingAction
                      ? null
                      : () => _confirmAction(
                            context,
                            'Cancel this booking?',
                            'The client will be notified.',
                            () => context
                                .read<WalkerBookingCubit>()
                                .cancelBooking(booking.id),
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    side: const BorderSide(color: _orange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isPerformingAction
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _orange),
                        )
                      : const Text('Cancel', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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

  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WalkBookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      WalkBookingStatus.pending => ('Pending', const Color(0xFFF59E0B)),
      WalkBookingStatus.accepted => ('Upcoming', const Color(0xFF3A80C2)),
      WalkBookingStatus.inProgress => ('Live', const Color(0xFF1BAA71)),
      WalkBookingStatus.completed => ('Completed', const Color(0xFF1BAA71)),
      WalkBookingStatus.rejected => ('Rejected', const Color(0xFFD05A24)),
      WalkBookingStatus.walkerCancelled => ('Cancelled', Colors.grey),
      WalkBookingStatus.ownerCancelled => ('Cancelled', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
