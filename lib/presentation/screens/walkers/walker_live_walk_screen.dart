import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/walker_live_walk_service.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/walk_booking.dart';
import '../../../domain/entities/walk_media.dart';
import '../../../domain/repositories/upload_repository.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import '../../bloc/walker_live_walk/walker_live_walk_cubit.dart';
import '../../bloc/walker_live_walk/walker_live_walk_state.dart';
import '../walks/walk_route_summary_screen.dart';

class WalkerLiveWalkScreen extends StatelessWidget {
  const WalkerLiveWalkScreen({super.key, required this.booking});

  final WalkBooking booking;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalkerLiveWalkCubit>(
      create: (_) => WalkerLiveWalkCubit(
        booking: booking,
        walkSessionRepository: sl<WalkSessionRepository>(),
        liveWalkService: WalkerLiveWalkService(),
        uploadRepository: sl<UploadRepository>(),
      )..start(),
      child: const _WalkerLiveWalkView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _WalkerLiveWalkView extends StatefulWidget {
  const _WalkerLiveWalkView();

  @override
  State<_WalkerLiveWalkView> createState() => _WalkerLiveWalkViewState();
}

class _WalkerLiveWalkViewState extends State<_WalkerLiveWalkView> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalkerLiveWalkCubit, WalkerLiveWalkState>(
      listener: (context, state) {
        if (state is WalkerLiveWalkActive) {
          if (state.currentPosition != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(state.currentPosition!),
            );
          }
          if (state.mediaUploadError != null) {
            BaltoToast.error(context, state.mediaUploadError!);
            context.read<WalkerLiveWalkCubit>().clearMediaUploadError();
          }
        }
        if (state is WalkerLiveWalkCompleted) {
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
        body: BlocBuilder<WalkerLiveWalkCubit, WalkerLiveWalkState>(
          builder: (context, state) {
            if (state is WalkerLiveWalkError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context.read<WalkerLiveWalkCubit>().start(),
              );
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
                _BottomPanel(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Map ────────────────────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection({required this.state, required this.onMapCreated});

  static const _defaultCenter = LatLng(6.2442, -75.5812);

  final WalkerLiveWalkState state;
  final void Function(GoogleMapController) onMapCreated;

  @override
  Widget build(BuildContext context) {
    final active =
        state is WalkerLiveWalkActive ? state as WalkerLiveWalkActive : null;
    final hasPosition = active?.currentPosition != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: hasPosition ? active!.currentPosition! : _defaultCenter,
            zoom: hasPosition ? 17 : 13,
          ),
          markers: hasPosition
              ? {
                  Marker(
                    markerId: const MarkerId('me'),
                    position: active!.currentPosition!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    infoWindow: const InfoWindow(title: 'You'),
                  ),
                }
              : {},
          circles: hasPosition && active?.accuracyMeters != null
              ? {
                  Circle(
                    circleId: const CircleId('accuracy'),
                    center: active!.currentPosition!,
                    radius: active.accuracyMeters!,
                    fillColor: Colors.blue.withValues(alpha: 0.08),
                    strokeColor: Colors.blue.withValues(alpha: 0.25),
                    strokeWidth: 1,
                  ),
                }
              : {},
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        if (!hasPosition)
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    state is WalkerLiveWalkStarting ||
                            state is WalkerLiveWalkInitial
                        ? 'Starting walk...'
                        : 'Getting GPS fix...',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
          child: _WalkingBadge(),
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

class _WalkingBadge extends StatelessWidget {
  const _WalkingBadge();

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
                  'Walking',
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

// ── Bottom Panel ───────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.state});

  final WalkerLiveWalkState state;

  @override
  Widget build(BuildContext context) {
    final active =
        state is WalkerLiveWalkActive ? state as WalkerLiveWalkActive : null;
    final isEnding = state is WalkerLiveWalkEnding;

    return Container(
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.timer_outlined,
                    value: _formatTime(active?.elapsedSeconds ?? 0),
                    label: 'Elapsed',
                    color: AppColors.navWalkers,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.gps_fixed_rounded,
                    value: active?.accuracyMeters != null
                        ? '±${active!.accuracyMeters!.toStringAsFixed(0)} m'
                        : '—',
                    label: 'GPS Accuracy',
                    color: AppColors.navWalks,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Media capture buttons
            Row(
              children: [
                Expanded(
                  child: _MediaBtn(
                    icon: Icons.photo_camera_rounded,
                    label: 'Photo',
                    color: const Color(0xFF3A80C2),
                    isLoading: active?.isUploadingMedia ?? false,
                    enabled: active != null && !isEnding,
                    onTap: () => _showMediaSourceSheet(context, isVideo: false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MediaBtn(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    color: const Color(0xFF7C3AED),
                    isLoading: false,
                    enabled: active != null && !isEnding && !(active.isUploadingMedia),
                    onTap: () => _showMediaSourceSheet(context, isVideo: true),
                  ),
                ),
              ],
            ),

            // Thumbnail strip
            if (active != null && active.mediaItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: active.mediaItems.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) =>
                      _MediaThumb(media: active.mediaItems[i]),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // End Walk button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    (active == null || isEnding)
                        ? null
                        : () => _confirmEnd(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD05A24),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFD05A24).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: isEnding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop_circle_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'End Walk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMediaSourceSheet(BuildContext context, {required bool isVideo}) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(isVideo ? 'Record video' : 'Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<WalkerLiveWalkCubit>().captureAndUploadMedia(
                      source: ImageSource.camera,
                      isVideo: isVideo,
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(isVideo ? 'Choose video from gallery' : 'Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<WalkerLiveWalkCubit>().captureAndUploadMedia(
                      source: ImageSource.gallery,
                      isVideo: isVideo,
                    );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmEnd(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End walk?'),
        content: const Text(
          'This will complete the walk and notify the owner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep walking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD05A24),
            ),
            child: const Text('End walk'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<WalkerLiveWalkCubit>().endWalk();
    }
  }

  static String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final m = seconds ~/ 60;
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    return '${h}h ${(m % 60).toString().padLeft(2, '0')}m';
  }
}

// ── Media UI helpers ───────────────────────────────────────────────────────────

class _MediaBtn extends StatelessWidget {
  const _MediaBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color.withValues(alpha: 0.09) : const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (enabled && !isLoading) ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 18, color: enabled ? color : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openWalkerMedia(BuildContext context, WalkMedia media) {
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

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({required this.media});

  final WalkMedia media;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openWalkerMedia(context, media),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            media.isVideo
                ? Container(
                    width: 64,
                    height: 64,
                    color: const Color(0xFF1A1A2E),
                    child: const Icon(Icons.play_circle_fill_rounded,
                        color: Colors.white, size: 28),
                  )
                : Image.network(
                    media.url,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 64,
                      height: 64,
                      color: const Color(0xFFE0E4EC),
                      child: const Icon(Icons.broken_image_rounded,
                          color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0B2)),
          ),
        ],
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────────

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
                const Icon(Icons.error_outline,
                    size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Could not start the walk',
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
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navWalkers,
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
