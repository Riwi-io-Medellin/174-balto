import 'package:flutter/material.dart';
import '../../../widgets/balto_chip.dart';

class WalkerFilterChip extends StatelessWidget {
  const WalkerFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BaltoChip(label: label, isSelected: isSelected, onTap: onTap);
  }
}
