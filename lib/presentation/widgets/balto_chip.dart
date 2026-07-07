import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';

/// Shared filter-chip look. `ServiceCategoryChip` and `WalkerFilterChip` were
/// byte-for-byte identical widgets under different names — this is the one
/// implementation both now delegate to.
class BaltoChip extends StatelessWidget {
  const BaltoChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = AppColors.navWalkers,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : const Color(0xFFF0F2F5),
          borderRadius: AppRadius.radiusPill,
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF5A6473),
          ),
        ),
      ),
    );
  }
}
