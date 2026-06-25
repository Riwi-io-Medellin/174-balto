import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/pet.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  static const Color _primary = Color(0xFF3A80C2);
  static const Color _bg = Color(0xFFF0F4F4);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF6B7280);

  Pet _findPet(BuildContext context) {
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      return state.pets.firstWhere((p) => p.id == petId);
    }
    throw StateError('Pet not found');
  }

  @override
  Widget build(BuildContext context) {
    final pet = _findPet(context);

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
