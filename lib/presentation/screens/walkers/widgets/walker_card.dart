import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/walker.dart';

class WalkerCard extends StatelessWidget {
  const WalkerCard({
    super.key,
    required this.walker,
    required this.onViewProfile,
    required this.onBookWalk,
  });

  final Walker walker;
  final VoidCallback onViewProfile;
  final VoidCallback onBookWalk;

  String get _reviewsLabel {
    final count = walker.reviews;
    if (count >= 1000) return '(${(count / 1000).toStringAsFixed(1)}k)';
    return '($count)';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameRow(cs),
                const SizedBox(height: 6),
                _buildMetaRow(cs),
                const SizedBox(height: 10),
                Text(
                  walker.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                _buildButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              walker.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE8F5EE),
                child: const Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: Color(0xFFB0B8C1),
                ),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(
                  color: Color(0xFFF0F2F5),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.navWalkers,
                    ),
                  ),
                );
              },
            ),
            if (walker.topRated)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.navWalkers,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'TOP RATED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            if (walker.isAcceptingBookings)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1BAA71),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameRow(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: Text(
            walker.name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ),
        Text(
          walker.priceLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.navWalkers,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(ColorScheme cs) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF6C86A)),
        const SizedBox(width: 4),
        Text(
          '${walker.rating}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        Text(
          '  $_reviewsLabel',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        const Spacer(),
        if (walker.yearsOfExperience > 0) ...[
          Icon(
            Icons.work_outline_rounded,
            size: 14,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 2),
          Text(
            '${walker.yearsOfExperience}yr',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
        ],
        Icon(
          Icons.location_on_rounded,
          size: 14,
          color: cs.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          '${walker.distance.toStringAsFixed(1)} km',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onViewProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navWalkers,
              side: const BorderSide(color: AppColors.navWalkers, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onBookWalk,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navWalkers,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
            child: const Text(
              'Book Walk',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
