import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/business.dart';

class BusinessOverviewTab extends StatelessWidget {
  const BusinessOverviewTab({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(title: 'About', child: Text(business.description, style: _bodyStyle)),
        if (business.address != null) _LocationSection(business: business),
        if (business.openingHours.isNotEmpty) _HoursSection(business: business),
        if (business.isVeterinary && business.services.isNotEmpty)
          _ServicesSection(business: business),
        if (business.isStore && business.products.isNotEmpty)
          _ProductsSection(business: business),
        if (business.facilities.isNotEmpty)
          _FacilitiesSection(business: business),
        const SizedBox(height: 20),
      ],
    );
  }
}

const _bodyStyle = TextStyle(fontSize: 14, color: Color(0xFF5A6473), height: 1.5);
const _labelStyle = TextStyle(fontSize: 13, color: Color(0xFF8A93A0));
const _valueStyle = TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w600);

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.navWalkers),
              const SizedBox(width: 6),
              Expanded(
                child: Text(business.address ?? '', style: _bodyStyle),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navWalkers,
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Open Maps', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              color: const Color(0xFFE8F5EE),
              child: const Center(
                child: Icon(Icons.map_outlined, size: 48, color: Color(0xFFB0B8C1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursSection extends StatelessWidget {
  const _HoursSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Opening Hours',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: business.openingHours.entries.map((e) {
            final isLast = e.key == business.openingHours.keys.last;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key, style: _labelStyle)),
                      Text(e.value, style: _valueStyle),
                    ],
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Divider(height: 1, color: Color(0xFFF1F3F6)),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Featured Service',
      child: Column(
        children: business.services.map((s) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  child: Image.network(
                    s.imageUrl ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFE8F5EE),
                      child: const Icon(Icons.medical_services_outlined, color: AppColors.navWalkers),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (s.tags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: s.tags
                                .map(
                                  (t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.navWalkers.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      t,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navWalkers,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 4),
                        Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                        const SizedBox(height: 2),
                        Text(s.description, style: _labelStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Best Sellers',
      child: Column(
        children: business.products.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    p.imageUrl ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFF0F2F5),
                      child: const Icon(Icons.inventory_2_outlined, color: Color(0xFFB0B8C1)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                      if (p.description != null) ...[
                        const SizedBox(height: 2),
                        Text(p.description!, style: _labelStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 6),
                      Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navWalkers)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navWalkers,
                    side: const BorderSide(color: AppColors.navWalkers),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FacilitiesSection extends StatelessWidget {
  const _FacilitiesSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Facilities',
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: business.facilities
            .map(
              (f) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppColors.navWalkers),
                  const SizedBox(width: 4),
                  Text(f, style: _bodyStyle),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
