import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/public_pet_tag_info.dart';
import '../../../domain/repositories/public_pet_tag_repository.dart';

/// Public, no-login-required view of a pet's tag info — shown when a Balto
/// user scans an NFC tag from inside the app (a stranger without the app
/// sees the equivalent server-rendered HTML page in their browser instead).
class PublicPetTagScreen extends StatefulWidget {
  const PublicPetTagScreen({super.key, required this.petId});

  final String petId;

  @override
  State<PublicPetTagScreen> createState() => _PublicPetTagScreenState();
}

class _PublicPetTagScreenState extends State<PublicPetTagScreen> {
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _primary = Color(0xFF1BAA71);
  static const Color _orange = Color(0xFFE58A00);

  late Future<PublicPetTagInfo> _future;
  bool _sharingLocation = false;

  @override
  void initState() {
    super.initState();
    _future = sl<PublicPetTagRepository>().getPublicInfo(widget.petId);
  }

  Future<void> _callOwner(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareLocation(PublicPetTagInfo pet) async {
    setState(() => _sharingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          BaltoToast.error(context, 'Location permission is required to share your location.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await sl<PublicPetTagRepository>().shareLocation(
        petId: pet.id,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      BaltoToast.success(context, 'Your location was sent to ${pet.ownerName}.');
    } catch (e) {
      if (!mounted) return;
      BaltoToast.error(context, 'Could not share your location. ${e.toString()}');
    } finally {
      if (mounted) setState(() => _sharingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        title: const Text('Pet Tag'),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
      ),
      body: FutureBuilder<PublicPetTagInfo>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is PublicPetTagFailure
                ? (snapshot.error as PublicPetTagFailure).message
                : 'Could not load this pet tag.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _textMuted, fontSize: 15),
                ),
              ),
            );
          }

          final pet = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (pet.isLost)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: _orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${pet.name} has been reported lost. Please contact the owner.',
                          style: const TextStyle(
                            color: _orange,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Center(child: _buildAvatar(pet)),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ),
              if (pet.species != null)
                Center(
                  child: Text(
                    pet.species!,
                    style: const TextStyle(color: _textMuted, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pet.breed != null) _infoRow('Breed', pet.breed!),
                    if (pet.color != null) _infoRow('Color', pet.color!),
                    if (pet.birthDate != null)
                      _infoRow(
                        'Age',
                        '${DateTime.now().year - pet.birthDate!.year} yr',
                      ),
                    _infoRow('Owner', pet.ownerName),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (pet.ownerPhone.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _callOwner(pet.ownerPhone),
                    icon: const Icon(Icons.call_rounded),
                    label: Text('Call ${pet.ownerName}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _sharingLocation ? null : () => _shareLocation(pet),
                  icon: _sharingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.location_on_rounded),
                  label: const Text('Share My Location with Owner'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD05A24),
                    side: const BorderSide(color: Color(0xFFD05A24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _textMuted)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PublicPetTagInfo pet) {
    if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          pet.photoUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _initialsAvatar(pet.name),
        ),
      );
    }
    return _initialsAvatar(pet.name);
  }

  Widget _initialsAvatar(String name) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
    );
  }
}
