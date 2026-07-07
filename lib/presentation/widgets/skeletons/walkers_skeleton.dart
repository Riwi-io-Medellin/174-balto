import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import 'skeleton_box.dart';

class WalkersSkeleton extends StatelessWidget {
  const WalkersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => _WalkerCardSkeleton(),
      ),
    );
  }
}

class _WalkerCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius20,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          const SkeletonBox(width: double.infinity, height: 180, radius: 0),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + price row
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 130, height: 16),
                    SkeletonBox(width: 60, height: 16),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating row
                const SkeletonBox(width: 160, height: 13),
                const SizedBox(height: 8),
                // Description
                const SkeletonBox(width: double.infinity, height: 13),
                const SizedBox(height: 4),
                const SkeletonBox(width: 200, height: 13),
                const SizedBox(height: 14),
                // Buttons row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: AppRadius.radius10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: AppRadius.radius10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
