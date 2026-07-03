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
                  if (business.description != null &&
                      business.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      business.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A6473),
                        height: 1.45,
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
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            business.photoUrl != null && business.photoUrl!.isNotEmpty
                ? Image.network(
                    business.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
            Positioned(
              top: 10,
              left: 10,
              child: Row(
                children: [
                  if (business.isVeterinary)
                    const _CategoryBadge('Veterinary', AppColors.navWalkers),
                  if (business.isVeterinary && business.isStore)
                    const SizedBox(width: 6),
                  if (business.isStore)
                    const _CategoryBadge('Store', AppColors.navCoach),
                ],
              ),
            ),
            if (business.isVerified)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          size: 14, color: AppColors.navWalkers),
                      SizedBox(width: 4),
                      Text('Verified',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFE9ECF1),
        child: const Icon(Icons.storefront_rounded,
            size: 40, color: Color(0xFFB6BEC9)),
      );
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Text(
      business.name,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1F2937),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
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
        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB800)),
        const SizedBox(width: 2),
        Text(
          business.rating.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
        ),
        const SizedBox(width: 4),
        Text('(${business.reviewCount})',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0))),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: business.isOpen ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          business.isOpen ? 'Open Now' : 'Closed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: business.isOpen ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
          ),
        ),
        if (business.distanceKm != null) ...[
          const SizedBox(width: 10),
          const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF8A93A0)),
          const SizedBox(width: 2),
          Text('${business.distanceKm!.toStringAsFixed(1)}km',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0))),
        ],
      ],
    );
  }
}
