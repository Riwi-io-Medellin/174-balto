import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import 'skeleton_box.dart';

/// A column of skeleton booking-card rows.
/// Wrap in [SliverToBoxAdapter] when used inside a [CustomScrollView].
class WalksSkeleton extends StatelessWidget {
  const WalksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(),
            const SizedBox(height: 10),
            ..._cards(3),
            const SizedBox(height: 24),
            _sectionLabel(),
            const SizedBox(height: 10),
            ..._cards(2),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel() {
    return const SkeletonBox(width: 110, height: 13, radius: 6);
  }

  List<Widget> _cards(int count) {
    return List.generate(
      count,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radius16,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: AppRadius.radius10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 80, height: 20, radius: 10),
                        SizedBox(height: 6),
                        SkeletonBox(width: 130, height: 13),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  SkeletonBox(width: 70, height: 12),
                  SizedBox(width: 16),
                  SkeletonBox(width: 50, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
