import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';

/// Shown when the owner taps a "pet_location_shared" notification — mirrors
/// LostPetReportScreen's map card, but for the location a finder shared after
/// scanning the pet's NFC tag (Pet.tagScanLatitude/Longitude/At) rather than
/// a lost-pet report.
class TagScanLocationScreen extends StatefulWidget {
  const TagScanLocationScreen({super.key, required this.petId});

  final String petId;

  @override
  State<TagScanLocationScreen> createState() => _TagScanLocationScreenState();
}

class _TagScanLocationScreenState extends State<TagScanLocationScreen> {
  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  final PetRepository _petRepo = sl<PetRepository>();

  Pet? _pet;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pet = await _petRepo.getById(widget.petId);
      if (!mounted) return;
      setState(() {
        _pet = pet;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Tag scan location'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _pet == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFF9AA0B2),
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load this location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Pet not found.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final pet = _pet!;
    final hasLocation =
        pet.tagScanLatitude != null && pet.tagScanLongitude != null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _headerCard(pet),
        if (hasLocation) ...[
          const SizedBox(height: 16),
          _locationCard(pet.tagScanLatitude!, pet.tagScanLongitude!),
        ] else ...[
          const SizedBox(height: 16),
          _noLocationCard(),
        ],
      ],
    );
  }

  Widget _headerCard(Pet pet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPhoto(pet),
          const SizedBox(height: 14),
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pet.tagScanAt != null
                ? 'Someone scanned this tag ${_relativeTime(pet.tagScanAt!)} and shared their location.'
                : 'Someone scanned this pet\'s NFC tag.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _noLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'No location has been shared for this tag scan yet.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: _textMuted),
      ),
    );
  }

  Widget _locationCard(double lat, double lng) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('tagScan'),
                  position: LatLng(lat, lng),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openInMaps(lat, lng),
                icon: const Icon(Icons.directions_outlined),
                label: const Text('Open in Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(Pet pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          pet.photoUrl!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildAvatar(pet),
        ),
      );
    }
    return _buildAvatar(pet);
  }

  Widget _buildAvatar(Pet pet) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          pet.name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
    );
  }
}
