import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

/// Shared dialog shell + the most common confirm/cancel pattern, which was
/// copy-pasted (title + message + Cancel/destructive TextButton) across ~14
/// call sites (delete pet, cancel booking, sign out, clear chat history...).
class BaltoDialog extends StatelessWidget {
  const BaltoDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  /// Shows a plain custom dialog with the shared shape.
  static Future<T?> show<T>(
    BuildContext context, {
    Widget? title,
    Widget? content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => BaltoDialog(title: title, content: content, actions: actions),
    );
  }

  /// Shows a title + message confirmation dialog with a Cancel action and a
  /// confirm action, returning `true` only if the user confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => BaltoDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: destructive
                ? TextButton.styleFrom(foregroundColor: AppColors.alert)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.radius16),
      title: title,
      content: content,
      actions: actions,
    );
  }
}
