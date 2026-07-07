import 'package:flutter/material.dart';

import '../../../../../core/constants/app_radius.dart';
import '../../../../../domain/entities/pet_clinical_record.dart';

/// Clean cards with the tips automatically generated
/// every time the clinical history changes.
class ClinicalTipsSection extends StatelessWidget {
  const ClinicalTipsSection({super.key, required this.tips});

  final List<PetClinicalTip> tips;

  static const _textDark = Color(0xFF1A1A2E);

  ({IconData icon, Color color}) _styleFor(String category) {
    switch (category) {
      case PetClinicalTipCategory.feeding:
        return (icon: Icons.restaurant_outlined, color: const Color(0xFFE58A00));
      case PetClinicalTipCategory.vaccination:
        return (icon: Icons.vaccines_outlined, color: const Color(0xFF3A80C2));
      case PetClinicalTipCategory.alert:
        return (icon: Icons.warning_amber_rounded, color: const Color(0xFFD05A24));
      case PetClinicalTipCategory.care:
        return (icon: Icons.favorite_outline_rounded, color: const Color(0xFF1BAA71));
      case PetClinicalTipCategory.general:
      default:
        return (icon: Icons.lightbulb_outline_rounded, color: const Color(0xFF5F36C2));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final tip in tips) ...[
          Builder(builder: (context) {
            final style = _styleFor(tip.category);
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radius14,
                border: Border.all(color: const Color(0xFFE0E4EC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: style.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(style.icon, size: 17, color: style.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PetClinicalTipCategory.label(tip.category).toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: style.color, letterSpacing: 0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(tip.message, style: const TextStyle(fontSize: 13, color: _textDark, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
