import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/walker.dart';
import '../../../widgets/app_network_image.dart';

class CompactWalkerCard extends StatelessWidget {
  const CompactWalkerCard({
    super.key,
    required this.walker,
    required this.onTap,
  });

  final Walker walker;
  final VoidCallback onTap;

  String get _reviewsLabel {
    final c = walker.reviews;
    return c >= 1000 ? '(${(c / 1000).toStringAsFixed(1)}k)' : '($c)';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.07),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Photo(imageUrl: walker.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            walker.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const _StatusBadge(isActive: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF6C86A),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${walker.rating} $_reviewsLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A6473),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _WalkerBadge(),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFFB0B8C1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: AppNetworkImage(
        imageUrl,
        width: 52,
        height: 52,
        errorWidget: Container(
          width: 52,
          height: 52,
          color: const Color(0xFFE8F5EE),
          child: const Icon(Icons.person_rounded, color: Color(0xFFB0B8C1)),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.navWalkers.withValues(alpha: 0.12)
            : const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isActive ? 'Active' : 'Unavailable',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.navWalkers : const Color(0xFF8A93A0),
        ),
      ),
    );
  }
}

class _WalkerBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Walker',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.dashboard,
        ),
      ),
    );
  }
}
