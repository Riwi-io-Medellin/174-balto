import 'package:flutter/material.dart';

import '../../../widgets/app_network_image.dart';

class WalkEntry {
  const WalkEntry({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.isActive = false,
    this.statusColor,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool isActive;
  final Color? statusColor;
}

class WalkCard extends StatelessWidget {
  const WalkCard({super.key, required this.entry, required this.onTap});

  final WalkEntry entry;
  final VoidCallback onTap;

  Color get _cardBg {
    if (entry.statusColor != null) {
      return entry.statusColor!.withValues(alpha: 0.07);
    }
    return const Color(0xFFF5F8FF);
  }

  Color get _shadowColor {
    if (entry.statusColor != null) {
      return entry.statusColor!.withValues(alpha: 0.18);
    }
    return Colors.black.withValues(alpha: 0.06);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: entry.isActive ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: entry.statusColor != null
              ? Border.all(
                  color: entry.statusColor!.withValues(alpha: 0.20),
                  width: 1,
                )
              : Border.all(color: const Color(0xFFE8EDF5), width: 1),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (entry.statusColor != null) ...[
                Container(
                  width: 3,
                  height: 44,
                  decoration: BoxDecoration(
                    color: entry.statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              _WalkThumbnail(
                imageUrl: entry.imageUrl,
                accentColor: entry.statusColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A93A0),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: entry.statusColor ?? const Color(0xFF8A93A0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkThumbnail extends StatelessWidget {
  const _WalkThumbnail({this.imageUrl, this.accentColor});

  final String? imageUrl;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AppNetworkImage(
          imageUrl!,
          width: 48,
          height: 48,
          errorWidget: _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final color = accentColor ?? const Color(0xFF3A80C2);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.directions_walk,
        size: 22,
        color: color.withValues(alpha: 0.60),
      ),
    );
  }
}
