import 'package:flutter/widgets.dart';

/// Shared layout dimensions. Fixes the audit finding of inconsistent
/// `SliverAppBar.expandedHeight` values (120 / 200 / 220 / undefined)
/// scattered across detail screens.
class AppDimens {
  AppDimens._();

  /// Root tab header (BaltoHeader) height — used by Home/Walks/Services/Walkers/Coach/Profile.
  static const double headerHeight = 64;

  /// Compact hero header for list-style root tabs (e.g. My Walks).
  static const double heroCompact = 120;

  /// Regular hero header for single-entity detail pages (e.g. walk detail/summary).
  static const double heroRegular = 200;

  /// Large hero header for profile-style pages with a cover photo (business/walker/provider profile).
  static const double heroLarge = 220;

  /// Shared horizontal screen padding used across root tabs on regular phones.
  static const double screenPaddingH = 20;

  /// Content beyond this width just adds margin instead of stretching —
  /// keeps text/cards readable on tablets and large-screen/foldable phones.
  static const double maxContentWidth = 560;

  /// Shared top padding below the header/safe area.
  static const double screenPaddingTop = 16;

  /// Horizontal padding that grows on wide screens instead of letting content
  /// stretch edge-to-edge. Use in place of the flat [screenPaddingH] on any
  /// screen whose content should stay readable on tablets/foldables.
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= maxContentWidth) return screenPaddingH;
    return screenPaddingH + (width - maxContentWidth) / 2;
  }

  /// Bottom padding that clears the floating [BaltoBottomNavBar] plus the
  /// device's own system gesture/nav bar, so the last items in a scrollable
  /// root-tab body are never visually covered by either.
  static double bottomSafePadding(BuildContext context) {
    return 90 + MediaQuery.paddingOf(context).bottom;
  }
}
