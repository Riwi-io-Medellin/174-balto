import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';

class PetHeroCard extends StatefulWidget {
  const PetHeroCard({super.key, required this.pets, required this.onTap});

  final List<Pet> pets;
  final VoidCallback onTap;

  @override
  State<PetHeroCard> createState() => _PetHeroCardState();
}

class _PetHeroCardState extends State<PetHeroCard> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pets.isEmpty) {
      return _PetCard(pet: null, onTap: widget.onTap);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.pets.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) =>
                _PetCard(pet: widget.pets[i], onTap: widget.onTap),
          ),
        ),
        if (widget.pets.length > 1) ...[
          const SizedBox(height: 10),
          _DotRow(count: widget.pets.length, current: _page),
        ],
      ],
    );
  }
}

// ─── Single pet card ──────────────────────────────────────────────────────────

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

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
              _background(),
              _gradient(),
              _content(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _background() {
    final photoUrl = pet?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _defaultBackground(),
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

  Widget _gradient() {
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

  Widget _content() {
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

// ─── Dot indicator ────────────────────────────────────────────────────────────

class _DotRow extends StatelessWidget {
  const _DotRow({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF3A80C2) : const Color(0xFFCBD5E0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Status pill ──────────────────────────────────────────────────────────────

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
