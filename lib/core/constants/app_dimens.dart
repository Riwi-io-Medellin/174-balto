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

  /// Shared horizontal screen padding used across root tabs.
  static const double screenPaddingH = 20;

  /// Shared top padding below the header/safe area.
  static const double screenPaddingTop = 16;
}
