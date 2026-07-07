import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/vet_document_analysis.dart';
import '../../../widgets/app_network_image.dart';

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
      return _PetCard(pet: null, onTap: widget.onTap, index: 0, total: 0);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.pets.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _PetCard(
              pet: widget.pets[i],
              onTap: widget.onTap,
              index: i,
              total: widget.pets.length,
            ),
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
  const _PetCard({
    required this.pet,
    required this.onTap,
    required this.index,
    required this.total,
  });

  final Pet? pet;
  final VoidCallback onTap;
  final int index;
  final int total;

  static const _green = Color(0xFF1BAA71);
  static const _blue = Color(0xFF3A80C2);
  static const _teal = Color(0xFF607F7F);
  static const _purple = Color(0xFF5F36C2);

  String get _petName => pet?.name ?? 'Add Your First Pet';

  String get _subtitle {
    if (pet == null) return 'Tap to get started';
    final parts = <String>[];
    if (pet?.species != null && pet!.species!.isNotEmpty) {
      parts.add(pet!.species!);
    }
    if (pet?.breed != null && pet!.breed!.isNotEmpty) parts.add(pet!.breed!);
    if (pet?.birthDate != null) {
      final age = DateTime.now().year - pet!.birthDate!.year;
      parts.add('$age yrs');
    }
    if (pet?.weight != null) parts.add('${pet!.weight!.toStringAsFixed(1)} kg');
    return parts.isEmpty ? 'Tap to view details' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: AppRadius.radius24,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 5),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: _green.withValues(alpha: 0.10),
              blurRadius: 32,
              offset: const Offset(0, 14),
              spreadRadius: -6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radius24,
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _background(),
                _gradientOverlay(),
                _decorativeCircles(),
                _topRow(),
                _bottomContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _background() {
    final photoUrl = pet?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return AppNetworkImage(
        photoUrl,
        height: 220,
        errorWidget: _defaultBackground(),
      );
    }
    return _defaultBackground();
  }

  Widget _defaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.45, 1.0],
          colors: pet == null
              ? [_purple, const Color(0xFF3A6BC4), _teal]
              : [_teal, _blue, _green],
        ),
      ),
    );
  }

  Widget _gradientOverlay() {
    final hasPhoto = pet?.photoUrl != null && pet!.photoUrl!.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.45, 1.0],
          colors: [
            Colors.black.withValues(alpha: hasPhoto ? 0.10 : 0.0),
            Colors.black.withValues(alpha: hasPhoto ? 0.20 : 0.0),
            Colors.black.withValues(alpha: hasPhoto ? 0.78 : 0.55),
          ],
        ),
      ),
    );
  }

  Widget _decorativeCircles() {
    final hasPhoto = pet?.photoUrl != null && pet!.photoUrl!.isNotEmpty;
    if (hasPhoto) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 40,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          right: 20,
          child: Icon(
            Icons.pets,
            size: 90,
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }

  Widget _topRow() {
    return Positioned(
      top: 14,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (pet?.species != null && pet!.species!.isNotEmpty)
            _GlassChip(label: pet!.species!)
          else if (pet == null)
            const _GlassChip(label: 'Balto')
          else
            const SizedBox.shrink(),
          if (total > 1) _GlassChip(label: '${index + 1} / $total'),
        ],
      ),
    );
  }

  Widget _bottomContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _petName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusPill(
              isEmpty: pet == null,
              urgencyLevel: pet?.latestHealthUrgency != null
                  ? UrgencyLevel.fromJson(pet!.latestHealthUrgency!)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Glass chip ───────────────────────────────────────────────────────────────

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.radiusPill,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Status pill ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isEmpty, this.urgencyLevel});

  final bool isEmpty;
  final UrgencyLevel? urgencyLevel;

  static const _healthy = Color(0xFFFF6B8A);

  (IconData, Color, String) get _visual {
    if (isEmpty) return (Icons.add_circle_outline, Colors.white, 'ADD PET');
    return switch (urgencyLevel) {
      null ||
      UrgencyLevel.routine => (Icons.favorite_rounded, _healthy, 'HEALTHY'),
      UrgencyLevel.scheduleVetVisit => (
        Icons.event_note_rounded,
        const Color(0xFFE8A84C),
        'CHECKUP',
      ),
      UrgencyLevel.urgent => (
        Icons.warning_rounded,
        const Color(0xFFD05A24),
        'URGENT',
      ),
      UrgencyLevel.emergency => (
        Icons.emergency_rounded,
        const Color(0xFFD32F2F),
        'EMERGENCY',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _visual;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.radiusPill,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1BAA71) : const Color(0xFFCBD5E0),
            borderRadius: AppRadius.radius4,
          ),
        );
      }),
    );
  }
}
