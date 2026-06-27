import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';

class PetHeroCard extends StatelessWidget {
  const PetHeroCard({super.key, this.pet, required this.onTap});

  final Pet? pet;
  final VoidCallback onTap;

  String get _petName => pet?.name ?? 'Your Pet';

  String get _breedAndAge {
    final parts = <String>[];
    if (pet?.breed != null && pet!.breed!.isNotEmpty) parts.add(pet!.breed!);
    if (pet?.birthDate != null) {
      final age = DateTime.now().year - pet!.birthDate!.year;
      parts.add('$age yrs');
    }
    return parts.isEmpty ? 'Add your first pet' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(),
              _buildGradient(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final photoUrl = pet?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultBackground(),
      );
    }
    return _defaultBackground();
  }

  Widget _defaultBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF607F7F), Color(0xFF3A80C2)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.pets, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildGradient() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.35, 1.0],
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.72),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _breedAndAge,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _petName,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const _StatusPill(),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'FEELING\nGREAT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
