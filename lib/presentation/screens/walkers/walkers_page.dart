import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/walkers_mock.dart';
import 'widgets/walker_card.dart';
import 'widgets/walker_filter_chip.dart';
import 'widgets/walkers_search_bar.dart';

class WalkersPage extends StatefulWidget {
  const WalkersPage({super.key});

  @override
  State<WalkersPage> createState() => _WalkersPageState();
}

class _WalkersPageState extends State<WalkersPage> {
  int _selectedFilter = 0;

  static const List<String> _filters = [
    'Nearby',
    'Top Rated',
    'Available Today',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.navWalkers,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  const WalkersSearchBar(),
                  const SizedBox(height: 14),
                  _buildFilterRow(),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Available Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: kMockWalkers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) => WalkerCard(
                  walker: kMockWalkers[i],
                  onViewProfile: () {},
                  onBookWalk: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.navWalkers.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pets_rounded,
            size: 18,
            color: AppColors.navWalkers,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Community Walkers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search_rounded, color: Color(0xFF1F2937)),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune_rounded, color: Color(0xFF1F2937)),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => WalkerFilterChip(
          label: _filters[i],
          isSelected: i == _selectedFilter,
          onTap: () => setState(() => _selectedFilter = i),
        ),
      ),
    );
  }
}
