import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import 'skeleton_box.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GreetingHeader ──────────────────────────────────
            const Row(
              children: [
                SkeletonCircle(size: 48),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 100, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 140, height: 18),
                    ],
                  ),
                ),
                SkeletonCircle(size: 40),
              ],
            ),
            const SizedBox(height: 20),

            // ── PetHeroCard ─────────────────────────────────────
            const SkeletonBox(width: double.infinity, height: 220, radius: 20),
            const SizedBox(height: 16),

            // ── DailyTipCard ────────────────────────────────────
            const SkeletonBox(width: double.infinity, height: 88, radius: 16),
            const SizedBox(height: 26),

            // ── Section title: Walks ─────────────────────────────
            const SkeletonBox(width: 80, height: 18),
            const SizedBox(height: 12),

            // ── 3 WalkCard skeletons ─────────────────────────────
            ..._walkCards(),
            const SizedBox(height: 26),

            // ── Section title: Quick care ────────────────────────
            const SkeletonBox(width: 110, height: 18),
            const SizedBox(height: 12),

            // ── 2×2 QuickCare tiles ──────────────────────────────
            _quickCareGrid(),
          ],
        ),
      ),
    );
  }

  List<Widget> _walkCards() {
    return List.generate(
      3,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radius14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: const Row(
            children: [
              SkeletonBox(width: 4, height: 48, radius: 2),
              SizedBox(width: 10),
              SkeletonBox(width: 48, height: 48, radius: 10),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonBox(width: 140, height: 13),
                    SizedBox(height: 6),
                    SkeletonBox(width: 90, height: 11),
                  ],
                ),
              ),
              SkeletonBox(width: 20, height: 20, radius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickCareGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(4, (_) {
        return SizedBox(
          width:
              (MediaQueryData.fromView(
                    WidgetsBinding.instance.platformDispatcher.views.first,
                  ).size.width -
                  40 -
                  12) /
              2,
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radius16,
            ),
            padding: const EdgeInsets.all(14),
            child: const Row(
              children: [
                SkeletonCircle(size: 44),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(height: 13),
                      SizedBox(height: 6),
                      SkeletonBox(width: 60, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
