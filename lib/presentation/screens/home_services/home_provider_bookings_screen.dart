import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/home_service_booking.dart';
import '../../bloc/home_provider_booking/home_provider_booking_cubit.dart';
import '../../bloc/home_provider_booking/home_provider_booking_state.dart';

class HomeProviderBookingsScreen extends StatelessWidget {
  const HomeProviderBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeProviderBookingCubit>(
      create: (_) => sl<HomeProviderBookingCubit>()..load(),
      child: const _HomeProviderBookingsView(),
    );
  }
}

class _HomeProviderBookingsView extends StatelessWidget {
  const _HomeProviderBookingsView();

  static const _accent = AppColors.homeServices;

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
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: BlocConsumer<HomeProviderBookingCubit, HomeProviderBookingState>(
          listener: (context, state) {
            if (state is HomeProviderBookingLoaded) {
              if (state.successMessage != null) {
                BaltoToast.success(context, state.successMessage!);
                context.read<HomeProviderBookingCubit>().clearMessages();
              }
              if (state.errorMessage != null) {
                BaltoToast.error(context, state.errorMessage!);
                context.read<HomeProviderBookingCubit>().clearMessages();
              }
            }
          },
          builder: (context, state) {
            if (state is HomeProviderBookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeProviderBookingError) {
              return _ErrorBody(
                message: state.message,
                onRetry: () => context.read<HomeProviderBookingCubit>().load(),
              );
            }
            if (state is HomeProviderBookingLoaded) {
              return TabBarView(
                children: [
                  _BookingList(
                    bookings: state.pending,
                    emptyMessage: 'No pending bookings.',
                    isPerformingAction: state.isPerformingAction,
                    tabType: _TabType.pending,
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
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.homeServices,
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
  });

  final List<HomeServiceBooking> bookings;
  final String emptyMessage;
  final bool isPerformingAction;
  final _TabType tabType;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.homeServices,
      onRefresh: () => context.read<HomeProviderBookingCubit>().refresh(),
      child: bookings.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
              ),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.isPerformingAction,
    required this.tabType,
  });

  final HomeServiceBooking booking;
  final bool isPerformingAction;
  final _TabType tabType;

  static const _accent = AppColors.homeServices;
  static const _orange = Color(0xFFD05A24);

  bool get _canStart => booking.status == HomeServiceBookingStatus.accepted;
  bool get _canFinish =>
      booking.status == HomeServiceBookingStatus.inProgress &&
      booking.homeServiceSessionId != null;

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
                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                Text(duration, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                if (price != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.attach_money_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  Text(price, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ],
            ),
            if (booking.serviceAddress != null && booking.serviceAddress!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_rounded, size: 14, color: Color(0xFF3A80C2)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.serviceAddress!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF3A80C2)),
                    ),
                  ),
                ],
              ),
            ],
            if (booking.specialInstructions != null && booking.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.specialInstructions!,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
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
                          : () => _confirmAction(context, 'Reject this booking?',
                              'The client will be notified.', () {
                              context.read<HomeProviderBookingCubit>().rejectBooking(booking.id);
                            }),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _orange,
                        side: const BorderSide(color: _orange),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reject', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isPerformingAction
                          ? null
                          : () => _confirmAction(context, 'Accept this booking?',
                              'The client will be notified.', () {
                              context.read<HomeProviderBookingCubit>().acceptBooking(booking.id);
                            }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isPerformingAction
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Accept', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
            if (tabType == _TabType.upcoming) ...[
              const SizedBox(height: 12),
              if (_canStart)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isPerformingAction
                        ? null
                        : () => context.read<HomeProviderBookingCubit>().startService(booking.id),
                    icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                    label: const Text('Start Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              if (_canFinish)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isPerformingAction
                        ? null
                        : () => context
                            .read<HomeProviderBookingCubit>()
                            .finishService(booking.homeServiceSessionId!),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Finish Service', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              if (_canStart || _canFinish) const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isPerformingAction
                      ? null
                      : () => _confirmAction(
                            context,
                            'Cancel this booking?',
                            'The client will be notified.',
                            () => context.read<HomeProviderBookingCubit>().cancelBooking(booking.id),
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _orange,
                    side: const BorderSide(color: _orange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isPerformingAction
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _orange),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final HomeServiceBookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      HomeServiceBookingStatus.accepted => ('Upcoming', const Color(0xFF3A80C2)),
      HomeServiceBookingStatus.inProgress => ('Live', AppColors.homeServices),
      HomeServiceBookingStatus.completed => ('Completed', AppColors.homeServices),
      HomeServiceBookingStatus.rejected => ('Rejected', const Color(0xFFD05A24)),
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
