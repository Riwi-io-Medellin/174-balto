import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/balto_toast.dart';
import '../../../domain/entities/pet.dart';
import '../../../domain/repositories/pet_repository.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../vet_document_analysis/vet_document_analysis_screen.dart';
import 'edit_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _red = Color(0xFFE53935);

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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VetDocumentAnalysisScreen(pet: pet),
                  ),
                ),
                icon: const Icon(Icons.medical_information_outlined),
                label: const Text('Health Document Analysis'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.aiCoach,
                  side: const BorderSide(color: AppColors.aiCoach),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
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
