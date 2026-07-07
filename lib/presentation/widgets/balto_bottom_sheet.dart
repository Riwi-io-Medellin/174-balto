import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

/// Shared bottom-sheet shell: rounded top corners, a drag handle, and
/// consistent padding — replacing the hand-rolled `Container` (white bg +
/// `BorderRadius.vertical(top: Radius.circular(24))` + 40x4 handle) repeated
/// across ~8 `showModalBottomSheet` call sites.
class BaltoBottomSheet {
  BaltoBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool showDragHandle = true,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(24, 16, 24, 40),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r24)),
        ),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.radius2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            builder(ctx),
          ],
        ),
      ),
    );
  }
}
