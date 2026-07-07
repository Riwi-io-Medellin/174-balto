import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../domain/entities/vet_document_analysis.dart';

class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.urgencyLevel});

  final UrgencyLevel urgencyLevel;

  @override
  Widget build(BuildContext context) {
    final color = switch (urgencyLevel) {
      UrgencyLevel.routine => const Color(0xFF1BAA71),
      UrgencyLevel.scheduleVetVisit => const Color(0xFFE8A84C),
      UrgencyLevel.urgent => const Color(0xFFD05A24),
      UrgencyLevel.emergency => const Color(0xFFD32F2F),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.radius20,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            urgencyLevel.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
