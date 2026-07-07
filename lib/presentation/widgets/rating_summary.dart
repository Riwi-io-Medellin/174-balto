import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_radius.dart';
import '../../domain/entities/feedback_summary.dart';

class RatingSummary extends StatelessWidget {
  const RatingSummary({super.key, required this.summary});

  final FeedbackSummary summary;

  List<double> get _distribution {
    if (summary.totalReviews == 0) return [0, 0, 0, 0, 0];
    final counts = <int>[0, 0, 0, 0, 0];
    for (final r in summary.reviews) {
      final idx = max(0, min(4, r.rating - 1));
      counts[idx]++;
    }
    return counts.map((c) => c / summary.totalReviews).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dist = _distribution;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < summary.averageRating.round()
                        ? const Color(0xFFF6C86A)
                        : const Color(0xFFE0E4EC),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${summary.totalReviews} REVIEWS',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A93A0),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final fraction = dist[star - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A93A0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppRadius.radius4,
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFF0F2F5),
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
