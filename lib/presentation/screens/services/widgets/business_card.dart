import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/business.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.business,
    required this.onTap,
  });

  final Business business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            _CoverImage(business: business),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(business: business),
                  const SizedBox(height: 6),
                  _MetaRow(business: business),
                  const SizedBox(height: 8),
                  Text(
                    business.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A6473),
                      height: 1.45,
                    ),
                  ),
                  if (business.features.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _FeatureChips(features: business.features),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navWalkers,
                        side: const BorderSide(
                          color: AppColors.navWalkers,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              business.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFE8F5EE),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 56,
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
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (business.isVeterinary) const _CategoryBadge('Veterinary', AppColors.navWalkers),
                  if (business.isVeterinary && business.isStore)
                    const SizedBox(width: 6),
                  if (business.isStore) const _CategoryBadge('Store', AppColors.navCoach),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            business.logoImage,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 44,
              height: 44,
              color: const Color(0xFFE8F5EE),
              child: const Icon(Icons.pets, size: 22, color: AppColors.navWalkers),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            business.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF6C86A)),
        const SizedBox(width: 3),
        Text(
          '${business.rating}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: business.isOpen
                ? AppColors.navWalkers
                : const Color(0xFFD05A24),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          business.isOpen ? 'Open Now' : 'Closed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: business.isOpen
                ? AppColors.navWalkers
                : const Color(0xFFD05A24),
          ),
        ),
        const Spacer(),
        const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF8A93A0)),
        Text(
          '${business.distance.toStringAsFixed(1)}km',
          style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0)),
        ),
      ],
    );
  }
}

class _FeatureChips extends StatelessWidget {
  const _FeatureChips({required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: features
          .take(3)
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                f,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A6473),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
