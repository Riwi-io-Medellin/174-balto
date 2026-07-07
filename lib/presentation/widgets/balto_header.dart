import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';

/// Shared root-tab header row: an optional leading icon badge, a title,
/// and trailing actions — all at a fixed [AppDimens.headerHeight].
///
/// This replaces the three incompatible top-of-screen patterns the audit
/// found across the bottom-nav tabs (manual SafeArea header, a pinned
/// SliverAppBar, and a real Scaffold.appBar): every tab now renders the
/// same static, non-scrolling header inside [BaltoScreenScaffold].
class BaltoHeader extends StatelessWidget {
  const BaltoHeader({
    super.key,
    this.leading,
    required this.title,
    this.actions = const [],
  });

  /// Convenience constructor matching the icon-badge + bold title layout
  /// used by Walks / Services / Walkers / Coach.
  factory BaltoHeader.iconTitle({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required String title,
    List<Widget> actions = const [],
  }) {
    return BaltoHeader(
      key: key,
      leading: BaltoHeaderIconBadge(icon: icon, color: iconColor),
      title: Text(title, style: AppTextStyles.h3),
      actions: actions,
    );
  }

  final Widget? leading;
  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.headerHeight,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(child: title),
          ...actions,
        ],
      ),
    );
  }
}

/// The circular icon badge used as [BaltoHeader.leading] across root tabs.
class BaltoHeaderIconBadge extends StatelessWidget {
  const BaltoHeaderIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 36,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// A trailing header icon button (search, filter, refresh...) with the
/// visual density every root tab already used ad-hoc.
class BaltoHeaderAction extends StatelessWidget {
  const BaltoHeaderAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.textPrimary,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }
}
