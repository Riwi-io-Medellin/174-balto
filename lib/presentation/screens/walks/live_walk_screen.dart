import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/walk_tracking_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/entities/walk_media.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../../domain/repositories/walk_booking_repository.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import '../../../domain/repositories/walker_repository.dart';
import '../../bloc/live_walk/live_walk_cubit.dart';
import '../../bloc/live_walk/live_walk_state.dart';
import 'walk_route_summary_screen.dart';

class LiveWalkScreen extends StatelessWidget {
  const LiveWalkScreen({super.key, required this.booking});

  final WalkBooking booking;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveWalkCubit>(
      create: (_) => LiveWalkCubit(
        booking: booking,
        walkerRepository: sl<WalkerRepository>(),
        petRepository: sl<PetRepository>(),
        trackingService: WalkTrackingService(),
        tokenStorage: sl<TokenStorage>(),
        walkBookingRepository: sl<WalkBookingRepository>(),
        walkSessionRepository: sl<WalkSessionRepository>(),
      )..start(),
      child: const _LiveWalkView(),
    );
  }
}

// ── View ─────────────────────────────────────────────────────────────────────

class _LiveWalkView extends StatefulWidget {
  const _LiveWalkView();

  @override
  State<_LiveWalkView> createState() => _LiveWalkViewState();
}

class _LiveWalkViewState extends State<_LiveWalkView> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveWalkCubit, LiveWalkState>(
      listener: (context, state) {
        if (state is LiveWalkActive && state.currentPosition != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(state.currentPosition!),
          );
        }
        if (state is LiveWalkCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WalkRouteSummaryScreen(
                sessionId: state.sessionId,
                distanceKm: state.distanceKm,
                elapsedSeconds: state.elapsedSeconds,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: BlocBuilder<LiveWalkCubit, LiveWalkState>(
          builder: (context, state) {
            if (state is LiveWalkError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context.read<LiveWalkCubit>().retry(),
              );
            }
            if (state is LiveWalkWaiting) {
              return const _WaitingView();
            }
            return Column(
              children: [
                Expanded(
                  flex: 5,
                  child: _MapSection(
                    state: state,
                    onMapCreated: (c) => _mapController = c,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _StatusPanel(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Map ───────────────────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection({required this.state, required this.onMapCreated});

  final LiveWalkState state;
  final void Function(GoogleMapController) onMapCreated;

  // Default map center (Medellín) used before the walker's GPS arrives.
  static const _defaultCenter = LatLng(6.2442, -75.5812);

  @override
  Widget build(BuildContext context) {
    final active = state is LiveWalkActive ? state as LiveWalkActive : null;
    final hasPosition = active?.currentPosition != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Map is always rendered so onMapCreated fires immediately and
        // animateCamera works reliably when the first position arrives.
        GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: hasPosition ? active!.currentPosition! : _defaultCenter,
            zoom: hasPosition ? 16 : 13,
          ),
          markers: hasPosition
              ? {
                  Marker(
                    markerId: const MarkerId('walker'),
                    position: active!.currentPosition!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    infoWindow: InfoWindow(title: '${active.petName} · now'),
                  ),
                }
              : {},
          polylines: (active?.routePoints.length ?? 0) >= 2
              ? {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: active!.routePoints,
                    color: AppColors.navWalks,
                    width: 5,
                    jointType: JointType.round,
                    startCap: Cap.roundCap,
                    endCap: Cap.roundCap,
                  ),
                }
              : {},
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // Overlay shown until walker's first GPS point arrives.
        if (!hasPosition)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Connecting to walker...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: const _BackButton(),
        ),
        const Positioned(
          top: 0,
          right: 0,
          left: 0,
          child: _LiveBadge(),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.arrow_back_rounded,
              color: Color(0xFF1A1A2E), size: 22),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 16),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
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
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.navWalkers,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A4A6A),
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

// ── Waiting ───────────────────────────────────────────────────────────────────

class _WaitingView extends StatelessWidget {
  const _WaitingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.navWalkers.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    size: 40,
                    color: AppColors.navWalkers,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Waiting for your walker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'The map will appear automatically once the walker starts the walk.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.navWalkers,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<LiveWalkCubit>().retry(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navWalkers,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Check now'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Could not connect to the walk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navWalks,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status Panel ──────────────────────────────────────────────────────────────

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.state});

  final LiveWalkState state;

  @override
  Widget build(BuildContext context) {
    final active = state is LiveWalkActive ? state as LiveWalkActive : null;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: active == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.navWalks),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _WalkerRow(
                    name: active.walkerName,
                    avatarUrl: active.walkerAvatarUrl,
                    rating: active.walkerRating,
                  ),
                  const SizedBox(height: 20),
                  _StatsRow(
                    elapsedSeconds: active.elapsedSeconds,
                    distanceKm: active.distanceKm,
                  ),
                  const SizedBox(height: 20),
                  _ActionButtons(walkerName: active.walkerName),
                  const SizedBox(height: 20),
                  const _WellnessCard(),
                  if (active.sessionId != null) ...[
                    const SizedBox(height: 20),
                    _WalkMediaSection(sessionId: active.sessionId!),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class _WalkerRow extends StatelessWidget {
  const _WalkerRow({
    required this.name,
    required this.avatarUrl,
    required this.rating,
  });

  final String name;
  final String avatarUrl;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            avatarUrl,
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
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Text(
                'Your walker · Verified Pro',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
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
  const _StatsRow({
    required this.elapsedSeconds,
    required this.distanceKm,
  });

  final int elapsedSeconds;
  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.route_outlined,
            value: distanceKm > 0
                ? '${distanceKm.toStringAsFixed(2)} km'
                : '0.00 km',
            label: 'Distance',
            color: AppColors.navWalks,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.timer_outlined,
            value: _formatTime(elapsedSeconds),
            label: 'Duration',
            color: AppColors.navWalkers,
          ),
        ),
      ],
    );
  }

  static String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final m = seconds ~/ 60;
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    return '${h}h ${(m % 60).toString().padLeft(2, '0')}m';
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
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9AA0B2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.walkerName});

  final String walkerName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Call',
            icon: Icons.phone_outlined,
            bg: AppColors.navWalks,
            fg: Colors.white,
            onTap: () =>
                BaltoToast.info(context, 'Calling $walkerName...'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionBtn(
            label: 'Chat',
            icon: Icons.chat_bubble_outline_rounded,
            bg: const Color(0xFFEEF3FB),
            fg: AppColors.navWalks,
            onTap: () => BaltoToast.info(context, 'Chat not connected yet.'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionBtn(
            label: 'SOS',
            icon: Icons.warning_amber_rounded,
            bg: const Color(0xFFFFF3CD),
            fg: const Color(0xFFB07D00),
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
  const _WellnessCard();

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Peace of mind',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
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
                const Text(
                  'Your pet is enjoying the walk and has maintained a healthy, energetic activity level during the last 20 minutes.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A4A6A),
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

// ── Walk Media Section (owner live view) ──────────────────────────────────────

class _WalkMediaSection extends StatefulWidget {
  const _WalkMediaSection({required this.sessionId});

  final String sessionId;

  @override
  State<_WalkMediaSection> createState() => _WalkMediaSectionState();
}

class _WalkMediaSectionState extends State<_WalkMediaSection> {
  List<WalkMedia> _items = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final items =
          await sl<WalkSessionRepository>().getSessionMedia(widget.sessionId);
      // ignore: avoid_print
      print('[MediaSection] fetched ${items.length} items for session ${widget.sessionId}');
      if (mounted) setState(() => _items = items);
    } catch (e) {
      // ignore: avoid_print
      print('[MediaSection] getSessionMedia error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Walk Photos & Videos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _OwnerMediaThumb(media: _items[i]),
          ),
        ),
      ],
    );
  }
}

void _openMedia(BuildContext context, WalkMedia media) {
  if (media.isVideo) {
    launchUrl(Uri.parse(media.url), mode: LaunchMode.externalApplication);
    return;
  }
  showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            child: Center(
              child: Image.network(
                media.url,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _OwnerMediaThumb extends StatelessWidget {
  const _OwnerMediaThumb({required this.media});

  final WalkMedia media;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openMedia(context, media),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: media.isVideo
            ? Container(
                width: 80,
                height: 80,
                color: const Color(0xFF1A1A2E),
                child: const Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 32),
              )
            : Image.network(
                media.url,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFE0E4EC),
                  child: const Icon(Icons.broken_image_rounded,
                      color: Colors.grey),
                ),
              ),
      ),
    );
  }
}
