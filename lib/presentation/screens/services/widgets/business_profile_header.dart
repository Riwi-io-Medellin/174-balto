import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/business.dart';

class BusinessProfileHeader extends StatelessWidget {
  const BusinessProfileHeader({super.key, required this.business});

  final Business business;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String get _whatsappUrl {
    final digits = business.phone.replaceAll(RegExp(r'[^0-9]'), '');
    return 'https://wa.me/57$digits';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadius.radius14,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: business.photoUrl != null && business.photoUrl!.isNotEmpty
                      ? Image.network(
                          business.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (business.isVeterinary) _badge('Veterinary', AppColors.navWalkers),
                        if (business.isVeterinary && business.isStore) const SizedBox(width: 6),
                        if (business.isStore) _badge('Store', AppColors.navCoach),
                        if (business.isVerified) ...[
                          const SizedBox(width: 6),
                          _badge('Verified', const Color(0xFF34C759)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
              const SizedBox(width: 3),
              Text(
                business.rating.toStringAsFixed(1),
                style: AppTextStyles.bodyBold.copyWith(color: const Color(0xFF1F2937)),
              ),
              Text(
                ' (${business.reviewCount} reviews)',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
              ),
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
                style: AppTextStyles.label.copyWith(
                  color: business.isOpen ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                ),
              ),
              if (business.distanceKm != null)
                Text(
                  ' · ${business.distanceKm!.toStringAsFixed(1)}km away',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A0)),
                ),
            ],
          ),
          if (business.nit.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('NIT: ${business.nit}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0))),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (business.phone.isNotEmpty)
                Expanded(
                  child: _ContactButton(
                    icon: Icons.chat_bubble_rounded,
                    color: const Color(0xFF25D366),
                    label: 'WhatsApp',
                    onTap: () => _launch(_whatsappUrl),
                  ),
                ),
              if (business.instagramUrl != null && business.instagramUrl!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.camera_alt_rounded,
                    color: const Color(0xFFE1306C),
                    label: 'Instagram',
                    onTap: () => _launch(business.instagramUrl!),
                  ),
                ),
              ],
              if (business.facebookUrl != null && business.facebookUrl!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.facebook_rounded,
                    color: const Color(0xFF1877F2),
                    label: 'Facebook',
                    onTap: () => _launch(business.facebookUrl!),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFE9ECF1),
        child: const Icon(Icons.storefront_rounded, size: 28, color: Color(0xFFB6BEC9)),
      );

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: AppRadius.radius20),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
      );
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.radius12,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
