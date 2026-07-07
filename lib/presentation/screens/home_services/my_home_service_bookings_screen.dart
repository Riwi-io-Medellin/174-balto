import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/home_service_booking.dart';
import '../../bloc/my_home_service_bookings/my_home_service_bookings_cubit.dart';
import '../../bloc/my_home_service_bookings/my_home_service_bookings_state.dart';

class MyHomeServiceBookingsScreen extends StatelessWidget {
  const MyHomeServiceBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyHomeServiceBookingsCubit>(
      create: (_) => sl<MyHomeServiceBookingsCubit>()..load(),
      child: const _MyHomeServiceBookingsView(),
    );
  }
}

class _MyHomeServiceBookingsView extends StatelessWidget {
  const _MyHomeServiceBookingsView();

  static const _accent = AppColors.homeServices;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Home Services',
            style: TextStyle(
              color: _accent,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: _accent),
          bottom: const TabBar(
            labelColor: _accent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _accent,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body:
            BlocConsumer<
              MyHomeServiceBookingsCubit,
              MyHomeServiceBookingsState
            >(
              listener: (context, state) {
                if (state is MyHomeServiceBookingsLoaded) {
                  if (state.successMessage != null) {
                    BaltoToast.success(context, state.successMessage!);
                    context.read<MyHomeServiceBookingsCubit>().clearMessages();
                  }
                  if (state.errorMessage != null) {
                    BaltoToast.error(context, state.errorMessage!);
                    context.read<MyHomeServiceBookingsCubit>().clearMessages();
                  }
                }
              },
              builder: (context, state) {
                if (state is MyHomeServiceBookingsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MyHomeServiceBookingsLoaded) {
                  return TabBarView(
                    children: [
                      _BookingList(
                        bookings: state.pending,
                        emptyMessage: 'No pending bookings.',
                        isPerformingAction: state.isPerformingAction,
                        canCancel: true,
                      ),
                      _BookingList(
                        bookings: state.upcoming,
                        emptyMessage: 'No upcoming bookings.',
                        isPerformingAction: state.isPerformingAction,
                        canCancel: true,
                      ),
                      _BookingList(
                        bookings: state.history,
                        emptyMessage: 'No past bookings.',
                        isPerformingAction: state.isPerformingAction,
                        canCancel: false,
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

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.isPerformingAction,
    required this.canCancel,
  });

  final List<HomeServiceBooking> bookings;
  final String emptyMessage;
  final bool isPerformingAction;
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.homeServices,
      onRefresh: () => context.read<MyHomeServiceBookingsCubit>().refresh(),
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
                canCancel: canCancel,
              ),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isPerformingAction,
    required this.canCancel,
  });

  final HomeServiceBooking booking;
  final bool isPerformingAction;
  final bool canCancel;

  static const _orange = Color(0xFFD05A24);

  @override
  Widget build(BuildContext context) {
    final local = booking.slotStart.toLocal();
    final dateStr = _formatSlot(local);
    final duration = '${booking.durationMinutes} min';
    final price = booking.totalPrice != null
        ? '\$${booking.totalPrice!.toStringAsFixed(2)}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.providerName ?? dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  duration,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                if (price != null) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.attach_money_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ],
            ),
            if (booking.serviceAddress != null &&
                booking.serviceAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.place_rounded,
                    size: 14,
                    color: Color(0xFF3A80C2),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.serviceAddress!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3A80C2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (canCancel &&
                booking.status != HomeServiceBookingStatus.inProgress &&
                booking.status != HomeServiceBookingStatus.completed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isPerformingAction
                      ? null
                      : () => _confirmCancel(context, booking.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    side: const BorderSide(color: _orange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isPerformingAction
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _orange,
                          ),
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
      'Dec',
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '$day, $month ${dt.day} · $hour:$minute $amPm';
  }

  Future<void> _confirmCancel(BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text('The provider will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<MyHomeServiceBookingsCubit>().cancelBooking(bookingId);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final HomeServiceBookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      HomeServiceBookingStatus.accepted => (
        'Upcoming',
        const Color(0xFF3A80C2),
      ),
      HomeServiceBookingStatus.inProgress => ('Live', AppColors.homeServices),
      HomeServiceBookingStatus.completed => (
        'Completed',
        AppColors.homeServices,
      ),
      HomeServiceBookingStatus.rejected => (
        'Rejected',
        const Color(0xFFD05A24),
      ),
      HomeServiceBookingStatus.providerCancelled => ('Cancelled', Colors.grey),
      HomeServiceBookingStatus.clientCancelled => ('Cancelled', Colors.grey),
      HomeServiceBookingStatus.pending => ('Pending', const Color(0xFFF59E0B)),
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
