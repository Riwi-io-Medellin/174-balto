import 'package:flutter/material.dart';

/// Shared elevation/shadow tokens. Consolidates the ~11 near-duplicate
/// inline BoxShadow definitions found across the app into one small scale,
/// modeled on the alpha/blur/offset clusters actually in use.
class AppShadows {
  AppShadows._();

  /// Faint separation for flat surfaces resting on the background (e.g. chips, small tiles).
  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Default resting shadow for cards in lists/grids.
  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  /// Raised/hover state, hero cards, floating summary panels.
  static final List<BoxShadow> raised = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Sheets and pinned bars that sit above content and cast a shadow
  /// upward or downward onto it (bottom sheets, pinned app bars).
  static final List<BoxShadow> sheet = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];
}
