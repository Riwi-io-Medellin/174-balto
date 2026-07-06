import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import 'clinical_history/pet_clinical_history_screen.dart';
import 'edit_pet_screen.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _red = Color(0xFFE53935);
  static const Color _orange = Color(0xFFE58A00);

  String get petId => widget.petId;
  bool _lostActionLoading = false;

  Pet? _findPet(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      try {
        return state.pets.firstWhere((p) => p.id == petId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _confirmDelete(BuildContext context, Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Remove ${pet.name} from your pets? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await sl<PetRepository>().delete(pet.id);
      await context.read<ProfileCubit>().load();
      if (!context.mounted) return;
      BaltoToast.success(context, '${pet.name} removed.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      BaltoToast.error(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> _reportLost(BuildContext context, Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report as lost'),
        content: Text(
          'This will use your current location and alert nearby Balto users so they can help find ${pet.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _orange),
            child: const Text('Report lost'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _lostActionLoading = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          BaltoToast.error(context, 'Location permission is required to report a lost pet.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await context.read<ProfileCubit>().reportLost(
            petId: pet.id,
            lostLatitude: position.latitude,
            lostLongitude: position.longitude,
          );

      if (!context.mounted) return;
      BaltoToast.success(context, '${pet.name} was reported lost. Nearby users have been alerted.');
    } catch (e) {
      if (!context.mounted) return;
      BaltoToast.error(context, 'Could not report ${pet.name} as lost. ${e.toString()}');
    } finally {
      if (mounted) setState(() => _lostActionLoading = false);
    }
  }

  Future<void> _markFound(BuildContext context, Pet pet) async {
    setState(() => _lostActionLoading = true);
    try {
      await context.read<ProfileCubit>().markFound(pet.id);
      if (!context.mounted) return;
      BaltoToast.success(context, '${pet.name} is marked as found.');
    } catch (e) {
      if (!context.mounted) return;
      BaltoToast.error(context, 'Could not update ${pet.name}. ${e.toString()}');
    } finally {
      if (mounted) setState(() => _lostActionLoading = false);
    }
  }

  Widget _lostStatusButton(Pet pet) {
    if (pet.isLost) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _lostActionLoading ? null : () => _markFound(context, pet),
          icon: _lostActionLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: const Text('Mark as found'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1BAA71),
            side: const BorderSide(color: Color(0xFF1BAA71)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _lostActionLoading ? null : () => _reportLost(context, pet),
        icon: _lostActionLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.report_outlined),
        label: const Text('Report pet as lost'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _orange,
          side: const BorderSide(color: _orange),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = _findPet(context);
    if (pet == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: SizedBox.shrink(),
      );
    }

    final age = pet.birthDate != null
        ? '${DateTime.now().year - pet.birthDate!.year} years'
        : 'Unknown';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileCubit>(),
                  child: EditPetScreen(pet: pet),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: _red),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, pet),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
                  _infoRow(Icons.style_outlined, 'Breed', pet.breed ?? 'Not specified'),
                  const SizedBox(height: 12),
                  _infoRow(Icons.cake_outlined, 'Age', age),
                  if (pet.weight != null) ...[
                    const SizedBox(height: 12),
                    _infoRow(Icons.monitor_weight_outlined, 'Weight', '${pet.weight!.toStringAsFixed(1)} kg'),
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
            const SizedBox(height: 16),
            _clinicalHistoryCard(context, pet),
            const SizedBox(height: 16),
            if (pet.isLost) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: _orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${pet.name} is currently marked as lost.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            _lostStatusButton(pet),
          ],
        ),
      ),
    );
  }

  Widget _clinicalHistoryCard(BuildContext context, Pet pet) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PetClinicalHistoryScreen(pet: pet)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1BAA71).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.folder_shared_outlined, color: Color(0xFF1BAA71), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historia Clínica',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Documentos, eventos, tips y documento oficial',
                    style: TextStyle(fontSize: 12, color: _textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textMuted),
          ],
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
          errorBuilder: (_, __, ___) => _buildAvatar(pet),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _buildAvatar(pet);
          },
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: _textMuted),
        ),
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
