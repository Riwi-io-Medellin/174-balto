import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const _kBase = Color(0xFFE0E0E0);
const _kHighlight = Color(0xFFF5F5F5);

/// Wraps [child] in a left-to-right shimmer. Use once per skeleton screen.
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _kBase,
      highlightColor: _kHighlight,
      child: child,
    );
  }
}

/// Grey rounded rectangle — place inside [SkeletonShimmer].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _kBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Grey circle — place inside [SkeletonShimmer].
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: _kBase, shape: BoxShape.circle),
    );
  }
}
