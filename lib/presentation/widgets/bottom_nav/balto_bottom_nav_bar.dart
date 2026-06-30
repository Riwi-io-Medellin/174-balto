import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'nav_item_model.dart';

class BaltoBottomNavBar extends StatelessWidget {
  const BaltoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<NavItemModel> _items = [
    NavItemModel(
      label: 'Home',
      icon: Icons.home_rounded,
      accentColor: AppColors.navHome,
    ),
    NavItemModel(
      label: 'Walks',
      icon: Icons.location_on_rounded,
      accentColor: AppColors.navWalks,
    ),
    NavItemModel(
      label: 'Services',
      icon: Icons.people_rounded,
      accentColor: AppColors.navWalkers,
    ),
    NavItemModel(
      label: 'Coach',
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.navCoach,
    ),
    NavItemModel(
      label: 'Profile',
      icon: Icons.pets_rounded,
      accentColor: AppColors.navProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            _items.length,
            (index) => _NavItem(
              model: _items[index],
              isActive: index == currentIndex,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.model,
    required this.isActive,
    required this.onTap,
  });

  final NavItemModel model;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBadge(model: model, isActive: isActive),
            const SizedBox(height: 4),
            Text(
              model.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.navLabelInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.model, required this.isActive});

  final NavItemModel model;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: model.accentColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          model.icon,
          size: 22,
          color: Colors.white,
        ),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: Icon(
        model.icon,
        size: 22,
        color: AppColors.navIconInactive,
      ),
    );
  }
}
