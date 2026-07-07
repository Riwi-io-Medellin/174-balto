import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/jwt_decoder.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';

/// Read-focused view of a lost-pet report, reachable from the lost-pet alert
/// banner, the notifications list, or a `lost_pet` push notification. Works
/// for both the owner and any other user who received the nearby alert —
/// fetches the pet directly by id rather than depending on the current
/// user's own pet list.
class LostPetReportScreen extends StatefulWidget {
  const LostPetReportScreen({super.key, required this.petId});

  final String petId;

  @override
  State<LostPetReportScreen> createState() => _LostPetReportScreenState();
}

class _LostPetReportScreenState extends State<LostPetReportScreen> {
  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _red = Color(0xFFE53935);
  static const Color _green = Color(0xFF1BAA71);

  final PetRepository _petRepo = sl<PetRepository>();

  Pet? _pet;
  bool _loading = true;
  bool _isOwner = false;
  bool _markFoundLoading = false;
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
      final token = await sl<TokenStorage>().readAccessToken();
      final currentUserId = token != null
          ? JwtDecoder.extractUserId(token)
          : null;
      if (!mounted) return;
      setState(() {
        _pet = pet;
        _isOwner = currentUserId != null && currentUserId == pet.userId;
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

  Future<void> _markFound() async {
    final pet = _pet;
    if (pet == null) return;
    setState(() => _markFoundLoading = true);
    try {
      final updated = await _petRepo.markFound(pet.id);
      if (!mounted) return;
      setState(() => _pet = updated);
      BaltoToast.success(context, '${pet.name} is marked as found.');
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(
        context,
        'Could not update ${pet.name}. ${e.toString()}',
      );
    } finally {
      if (mounted) setState(() => _markFoundLoading = false);
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
        title: const Text('Lost pet report'),
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
                'Could not load this report',
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
    final age = pet.birthDate != null
        ? '${DateTime.now().year - pet.birthDate!.year} years'
        : 'Unknown';
    final hasLocation = pet.lostLatitude != null && pet.lostLongitude != null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _statusBanner(pet),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
              const SizedBox(height: 16),
              Text(
                pet.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 20),
              _infoRow(Icons.pets, 'Species', pet.species ?? 'Not specified'),
              const SizedBox(height: 12),
              _infoRow(
                Icons.style_outlined,
                'Breed',
                pet.breed ?? 'Not specified',
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.cake_outlined, 'Age', age),
              if (pet.color != null) ...[
                const SizedBox(height: 12),
                _infoRow(Icons.palette_outlined, 'Color', pet.color!),
              ],
              if (pet.sex != null) ...[
                const SizedBox(height: 12),
                _infoRow(Icons.male_outlined, 'Sex', pet.sex!),
              ],
              if (pet.weight != null) ...[
                const SizedBox(height: 12),
                _infoRow(
                  Icons.monitor_weight_outlined,
                  'Weight',
                  '${pet.weight!.toStringAsFixed(1)} kg',
                ),
              ],
              if (pet.identificationNumber != null) ...[
                const SizedBox(height: 12),
                _infoRow(
                  Icons.badge_outlined,
                  'ID number',
                  pet.identificationNumber!,
                ),
              ],
              if (pet.microchipNumber != null) ...[
                const SizedBox(height: 12),
                _infoRow(
                  Icons.memory_outlined,
                  'Microchip',
                  pet.microchipNumber!,
                ),
              ],
              if (pet.description != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE0E4F0)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    pet.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasLocation) ...[
          const SizedBox(height: 16),
          _locationCard(pet.lostLatitude!, pet.lostLongitude!),
        ],
        if (_isOwner && pet.isLost) ...[
          const SizedBox(height: 16),
          _markFoundButton(),
        ],
      ],
    );
  }

  Widget _statusBanner(Pet pet) {
    final color = pet.isLost ? _red : _green;
    final label = pet.isLost
        ? 'Still missing${pet.lostAt != null ? ' · reported ${_relativeTime(pet.lostAt!)}' : ''}'
        : 'This pet has been found';
    final icon = pet.isLost
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
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
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('lastSeen'),
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

  Widget _markFoundButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _markFoundLoading ? null : _markFound,
        icon: _markFoundLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline),
        label: const Text('Mark as found'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _green,
          side: const BorderSide(color: _green),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(Pet pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          pet.photoUrl!,
          width: 160,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildAvatar(pet),
        ),
      );
    }
    return _buildAvatar(pet);
  }

  Widget _buildAvatar(Pet pet) {
    return Container(
      width: 80,
      height: 80,
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _primary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: _textMuted)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
      ],
    );
  }
}
