import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: entry.isActive ? 1.0 : 0.72,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        elevation: entry.isActive ? 2 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        child: InkWell(
          onTap: entry.isActive ? onTap : null,
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
                _WalkThumbnail(imageUrl: entry.imageUrl),
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
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF8A93A0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalkThumbnail extends StatelessWidget {
  const _WalkThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.directions_walk,
        size: 22,
        color: Color(0xFFB0B8C1),
      ),
    );
  }
}
