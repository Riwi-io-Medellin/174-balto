import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/business.dart';

class BusinessProfileHeader extends StatelessWidget {
  const BusinessProfileHeader({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoSection(business: business),
        const Divider(height: 1, color: Color(0xFFF1F3F6)),
        _QuickActions(business: business),
        const Divider(height: 1, color: Color(0xFFF1F3F6)),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  business.logoImage,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFFE8F5EE),
                    child: const Icon(Icons.pets, color: AppColors.navWalkers),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (business.isVeterinary)
                          const _Badge('Veterinary', AppColors.navWalkers),
                        if (business.isVeterinary && business.isStore)
                          const SizedBox(width: 6),
                        if (business.isStore)
                          const _Badge('Pet Store', AppColors.navCoach),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF6C86A)),
              const SizedBox(width: 4),
              Text(
                '${business.rating}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                ' (${business.reviewCount} reviews)',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: business.isOpen
                      ? AppColors.navWalkers
                      : const Color(0xFFD05A24),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                business.isOpen ? 'Open Now' : 'Closed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: business.isOpen
                      ? AppColors.navWalkers
                      : const Color(0xFFD05A24),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '· ${business.distance.toStringAsFixed(1)}km away',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navWalkers,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Action(icon: Icons.calendar_month_outlined, label: 'Book', onTap: () {}),
          _Action(icon: Icons.search_rounded, label: 'Browse', onTap: () {}),
          _Action(
            icon: Icons.phone_outlined,
            label: 'Call',
            onTap: () {},
          ),
          _Action(icon: Icons.chat_bubble_outline_rounded, label: 'Message', onTap: () {}),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF1F2937)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A6473),
            ),
          ),
        ],
      ),
    );
  }
}
