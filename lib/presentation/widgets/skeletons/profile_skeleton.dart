import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header title ────────────────────────────────────
            const SkeletonBox(width: 80, height: 22),
            const SizedBox(height: 24),

            // ── Identity row: avatar + name + email ─────────────
            Center(
              child: Column(
                children: [
                  const SkeletonCircle(size: 80),
                  const SizedBox(height: 12),
                  const SkeletonBox(width: 150, height: 18),
                  const SizedBox(height: 6),
                  const SkeletonBox(width: 110, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Stats card ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatBox(),
                  _StatBox(),
                  _StatBox(),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Quick actions row ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionBox(),
                  _ActionBox(),
                  _ActionBox(),
                  _ActionBox(),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── My Pets section ──────────────────────────────────
            const SkeletonBox(width: 90, height: 14, radius: 4),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: List.generate(2, (i) => _petRow(i)),
              ),
            ),
            const SizedBox(height: 18),

            // ── Personal information ─────────────────────────────
            const SkeletonBox(width: 160, height: 14, radius: 4),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: List.generate(3, (i) => _infoRow(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _petRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: index == 0
          ? null
          : const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0)),
              ),
            ),
      child: const Row(
        children: [
          SkeletonCircle(size: 44),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100, height: 14),
                SizedBox(height: 5),
                SkeletonBox(width: 70, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 20, height: 20, radius: 4),
        ],
      ),
    );
  }

  Widget _infoRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: index == 0
          ? null
          : const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF0F0F0)),
              ),
            ),
      child: const Row(
        children: [
          SkeletonCircle(size: 36),
          SizedBox(width: 12),
          Expanded(child: SkeletonBox(height: 13)),
          SizedBox(width: 12),
          SkeletonBox(width: 70, height: 13),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(width: 40, height: 24),
        SizedBox(height: 4),
        SkeletonBox(width: 60, height: 12),
      ],
    );
  }
}

class _ActionBox extends StatelessWidget {
  const _ActionBox();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonCircle(size: 44),
        SizedBox(height: 6),
        SkeletonBox(width: 50, height: 11),
      ],
    );
  }
}
