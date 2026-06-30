import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'quick_care_tile.dart';

class QuickCareGrid extends StatelessWidget {
  const QuickCareGrid({
    super.key,
    this.onClinicTap,
    this.onWalkerTap,
    this.onStoreTap,
    this.onPetsTap,
  });

  final VoidCallback? onClinicTap;
  final VoidCallback? onWalkerTap;
  final VoidCallback? onStoreTap;
  final VoidCallback? onPetsTap;

  static const _tiles = [
    _TileData(
      icon: Icons.local_hospital_outlined,
      title: 'Find a Clinic',
      subtitle: 'Veterinaries',
      backgroundColor: Color(0xFFEAF2FB),
      iconColor: AppColors.dashboard,
    ),
    _TileData(
      icon: Icons.directions_walk,
      title: 'Find a Walker',
      subtitle: 'Trusted nearby',
      backgroundColor: Color(0xFFE5F7F0),
      iconColor: AppColors.petProfile,
    ),
    _TileData(
      icon: Icons.storefront_outlined,
      title: 'Find a Store',
      subtitle: 'Pet supplies',
      backgroundColor: Color(0xFFE4F5F3),
      iconColor: Color(0xFF1BAA9A),
    ),
    _TileData(
      icon: Icons.pets,
      title: 'My Pets',
      subtitle: 'Manage profiles',
      backgroundColor: Color(0xFFF0EAFB),
      iconColor: AppColors.aiCoach,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final callbacks = [onClinicTap, onWalkerTap, onStoreTap, onPetsTap];
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            _tiles.length,
            (i) => SizedBox(
              width: tileWidth,
              child: QuickCareTile(
                icon: _tiles[i].icon,
                title: _tiles[i].title,
                subtitle: _tiles[i].subtitle,
                backgroundColor: _tiles[i].backgroundColor,
                iconColor: _tiles[i].iconColor,
                onTap: callbacks[i] ?? () {},
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TileData {
  const _TileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
}
