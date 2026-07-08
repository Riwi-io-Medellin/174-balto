import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Shared skeleton for the 5 bottom-nav root tabs (Home, Walks, Services,
/// Coach, Profile).
///
/// Before this widget, each tab resolved the safe area and top header in a
/// different way (manual `SafeArea` + padding, a pinned `SliverAppBar`, or a
/// real `Scaffold.appBar`) — the root cause of the inconsistent "top of the
/// screen" reported across screenshots. Every tab now shares the same
/// `Scaffold -> SafeArea -> [header, body]` structure, the same background,
/// and the same top/horizontal padding, via [AppDimens].
///
/// [header] is static and never scrolls. [body] owns any scrolling and its
/// own horizontal padding (it is rendered full-bleed by this scaffold, same
/// as before this refactor).
class BaltoScreenScaffold extends StatelessWidget {
  const BaltoScreenScaffold({
    super.key,
    required this.header,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor = AppColors.background,
  });

  final Widget header;
  final Widget body;
  final Widget? floatingActionButton;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.horizontalPadding(context),
                AppDimens.screenPaddingTop,
                AppDimens.horizontalPadding(context),
                0,
              ),
              child: header,
            ),
            const SizedBox(height: 16),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
