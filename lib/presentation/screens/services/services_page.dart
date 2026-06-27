import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services_mock.dart';
import '../../../data/walkers_mock.dart';
import '../../../domain/entities/business.dart';
import '../../../domain/entities/walker.dart';
import 'business_profile_page.dart';
import 'widgets/business_card.dart';
import 'widgets/compact_walker_card.dart';
import 'widgets/service_category_chip.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int _selectedFilter = 0;

  static const List<String> _filters = [
    'All',
    'Walkers',
    'Veterinaries',
    'Stores',
  ];

  List<Object> get _filteredItems {
    switch (_selectedFilter) {
      case 1:
        return List<Object>.from(kMockWalkers);
      case 2:
        return kMockBusinesses.where((b) => b.isVeterinary).toList();
      case 3:
        return kMockBusinesses.where((b) => b.isStore).toList();
      default:
        return [...kMockBusinesses, ...kMockWalkers];
    }
  }

  void _openProfile(Business business) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BusinessProfilePage(business: business),
      ),
    );
  }

  void _showWalkerSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Walker profiles are coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
                  const SizedBox(height: 14),
                  _buildFilterRow(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found.',
                        style: TextStyle(color: Color(0xFF8A93A0)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        if (item is Business) {
                          return BusinessCard(
                            business: item,
                            onTap: () => _openProfile(item),
                          );
                        }
                        if (item is Walker) {
                          return CompactWalkerCard(
                            walker: item,
                            onTap: _showWalkerSnackBar,
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
            color: AppColors.navCoach.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.manage_search_rounded,
            size: 18,
            color: AppColors.navCoach,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'PawSphere Finder',
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
        itemBuilder: (_, i) => ServiceCategoryChip(
          label: _filters[i],
          isSelected: i == _selectedFilter,
          onTap: () => setState(() => _selectedFilter = i),
        ),
      ),
    );
  }
}
