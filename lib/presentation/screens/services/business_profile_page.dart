import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/business.dart';
import 'widgets/business_overview_tab.dart';
import 'widgets/business_profile_header.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key, required this.business});

  final Business business;

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  int _tab = 0;

  Business get _b => widget.business;

  List<String> get _tabs => [
        'Overview',
        if (_b.isVeterinary) 'Veterinary',
        if (_b.isStore) 'Store',
        'Reviews',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: BusinessProfileHeader(business: _b)),
          SliverToBoxAdapter(child: _buildTabBar()),
          SliverToBoxAdapter(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.navWalkers,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _b.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF3A80C2),
                child: const Icon(Icons.storefront_rounded, size: 80, color: Colors.white24),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: Text(
                _b.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F6))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = i == _tab;
            return GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active ? AppColors.navWalkers : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.navWalkers : const Color(0xFF8A93A0),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final label = _tabs[_tab];
    switch (label) {
      case 'Veterinary':
        return _buildVetTab();
      case 'Store':
        return _buildStoreTab();
      case 'Reviews':
        return _buildReviewsTab();
      default:
        return BusinessOverviewTab(business: _b);
    }
  }

  Widget _buildVetTab() {
    if (_b.services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No services listed yet.', style: TextStyle(color: Color(0xFF8A93A0)))),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _b.services.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final s = _b.services[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
              const SizedBox(height: 4),
              Text(s.description, style: const TextStyle(fontSize: 13, color: Color(0xFF5A6473))),
              if (s.price != null) ...[
                const SizedBox(height: 8),
                Text('\$${s.price!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navWalkers)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreTab() {
    if (_b.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No products listed yet.', style: TextStyle(color: Color(0xFF8A93A0)))),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _b.products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = _b.products[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                    if (p.description != null) ...[
                      const SizedBox(height: 3),
                      Text(p.description!, style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0))),
                    ],
                    const SizedBox(height: 6),
                    Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navWalkers)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navWalkers,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Text('Reviews coming soon.', style: TextStyle(color: Color(0xFF8A93A0), fontSize: 14)),
      ),
    );
  }
}
