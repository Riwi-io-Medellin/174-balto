import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class ServicesSkeleton extends StatelessWidget {
  const ServicesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => _BusinessCardSkeleton(),
      ),
    );
  }
}

class _BusinessCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          const SkeletonBox(width: double.infinity, height: 160, radius: 0),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + name row
                const Row(
                  children: [
                    SkeletonCircle(size: 44),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 140, height: 16),
                        SizedBox(height: 6),
                        SkeletonBox(width: 90, height: 13),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Description
                const SkeletonBox(width: double.infinity, height: 13),
                const SizedBox(height: 4),
                const SkeletonBox(width: 180, height: 13),
                const SizedBox(height: 12),
                // Feature chips row
                const Row(
                  children: [
                    SkeletonBox(width: 60, height: 24, radius: 12),
                    SizedBox(width: 8),
                    SkeletonBox(width: 70, height: 24, radius: 12),
                    SizedBox(width: 8),
                    SkeletonBox(width: 55, height: 24, radius: 12),
                  ],
                ),
                const SizedBox(height: 12),
                // Full-width button
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
