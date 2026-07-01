import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/walk_session_repository.dart';
import '../../widgets/review_sheet.dart';

class WalkRouteSummaryScreen extends StatefulWidget {
  const WalkRouteSummaryScreen({
    super.key,
    required this.sessionId,
    required this.distanceKm,
    required this.elapsedSeconds,
    this.walkerId,
    this.walkerName,
  });

  final String sessionId;
  final double distanceKm;
  final int elapsedSeconds;
  final String? walkerId;
  final String? walkerName;

  @override
  State<WalkRouteSummaryScreen> createState() => _WalkRouteSummaryScreenState();
}

class _WalkRouteSummaryScreenState extends State<WalkRouteSummaryScreen> {
  GoogleMapController? _mapController;
  List<LatLng>? _routePoints;
  bool _loading = true;
  String? _error;
  late double _distanceKm;

  @override
  void initState() {
    super.initState();
    _distanceKm = widget.distanceKm;
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    if (widget.sessionId.isEmpty) {
      setState(() { _loading = false; });
      return;
    }
    try {
      final points = await sl<WalkSessionRepository>().getRoute(widget.sessionId);
      if (mounted) {
        setState(() {
          _routePoints = points;
          _loading = false;
          if (points.length >= 2) {
            _distanceKm = _calcDistanceKm(points);
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load route'; _loading = false; });
    }
  }

  static double _calcDistanceKm(List<LatLng> points) {
    double total = 0;
    for (var i = 0; i < points.length - 1; i++) {
      total += _haversineMeters(points[i], points[i + 1]);
    }
    return total / 1000;
  }

  static double _haversineMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(a.latitude * pi / 180) *
            cos(b.latitude * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  LatLng get _center {
    final pts = _routePoints;
    if (pts == null || pts.isEmpty) return const LatLng(0, 0);
    final lats = pts.map((p) => p.latitude);
    final lngs = pts.map((p) => p.longitude);
    return LatLng(
      lats.reduce((a, b) => a + b) / pts.length,
      lngs.reduce((a, b) => a + b) / pts.length,
    );
  }

  void _fitRoute() {
    final pts = _routePoints;
    if (_mapController == null || pts == null || pts.isEmpty) return;
    final lats = pts.map((p) => p.latitude);
    final lngs = pts.map((p) => p.longitude);
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            lats.reduce((a, b) => a < b ? a : b),
            lngs.reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            lats.reduce((a, b) => a > b ? a : b),
            lngs.reduce((a, b) => a > b ? a : b),
          ),
        ),
        60,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pts = _routePoints ?? [];
    final hasRoute = pts.length >= 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_loading)
                  const _MapPlaceholder(message: 'Loading route...')
                else if (hasRoute)
                  GoogleMap(
                    onMapCreated: (c) {
                      _mapController = c;
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => _fitRoute());
                    },
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('start'),
                        position: pts.first,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        infoWindow: const InfoWindow(title: 'Start'),
                      ),
                      Marker(
                        markerId: const MarkerId('end'),
                        position: pts.last,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow: const InfoWindow(title: 'End'),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: pts,
                        color: AppColors.navWalks,
                        width: 5,
                        jointType: JointType.round,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  )
                else
                  _MapPlaceholderStatic(
                    message: _error ?? 'No route data recorded',
                  ),

                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: Material(
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
                  ),
                ),

                // Completed badge
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.navWalkers,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'Walk Complete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats panel
          Container(
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
                  const SizedBox(height: 20),

                  const Text(
                    'Walk Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.route_outlined,
                          value: _distanceKm > 0
                              ? '${_distanceKm.toStringAsFixed(2)} km'
                              : '—',
                          label: 'Distance',
                          color: AppColors.navWalks,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.timer_outlined,
                          value: _formatTime(widget.elapsedSeconds),
                          label: 'Duration',
                          color: AppColors.navWalkers,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navWalkers,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (widget.walkerId != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => showReviewSheet(
                          context: context,
                          targetId: widget.walkerId!,
                          targetType: 'walker',
                          targetName: widget.walkerName ?? 'your walker',
                          title: 'Rate your walk',
                          subtitle: widget.walkerName != null
                              ? 'How was your walk with ${widget.walkerName}?'
                              : 'How was your walk?',
                        ),
                        icon: const Icon(Icons.star_outline_rounded, size: 18),
                        label: const Text('Write a Review'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navWalkers,
                          side: const BorderSide(color: AppColors.navWalkers),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
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

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EEE4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Only show spinner when still loading; use a plain text placeholder otherwise
class _MapPlaceholderStatic extends StatelessWidget {
  const _MapPlaceholderStatic({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EEE4),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
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
