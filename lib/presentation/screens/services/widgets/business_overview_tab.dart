import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/business.dart';

const _bodyStyle = TextStyle(fontSize: 13.5, color: Color(0xFF5A6473), height: 1.5);

class BusinessOverviewTab extends StatelessWidget {
  const BusinessOverviewTab({super.key, required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (business.description != null && business.description!.isNotEmpty)
            _Section(title: 'About', child: Text(business.description!, style: _bodyStyle)),
          if (business.address != null && business.address!.isNotEmpty) _LocationSection(business: business),
          if (business.openingHours.isNotEmpty) _HoursSection(business: business),
          if (business.services.isNotEmpty) _ServicesSection(business: business),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
          const SizedBox(height: 10),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_rounded, size: 18, color: AppColors.navWalkers),
          const SizedBox(width: 8),
          Expanded(child: Text(business.address ?? '', style: _bodyStyle)),
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
    final sorted = [...business.openingHours]
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    return _Section(
      title: 'Opening Hours',
      child: Column(
        children: sorted.map((h) {
          final isLast = h == sorted.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(h.dayLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                ),
                Expanded(
                  child: Text(
                    h.isActive ? '${_fmt(h.startTime)} - ${_fmt(h.endTime)}' : 'Closed',
                    style: TextStyle(
                      fontSize: 13,
                      color: h.isActive ? const Color(0xFF5A6473) : const Color(0xFFB6BEC9),
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

  String _fmt(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    return '${parts[0]}:${parts[1]}';
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Services',
      child: Column(
        children: business.services.map((s) {
          final isLast = s == business.services.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.serviceType, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                      if (s.description != null && s.description!.isNotEmpty)
                        Text(s.description!, style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A0))),
                    ],
                  ),
                ),
                Text('\$${s.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navWalkers)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
