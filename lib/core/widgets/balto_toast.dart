import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

/// Variants for branded toast messages.
enum BaltoToastType { success, error, warning, info }

/// Displays a styled, branded toast snackbar.
///
/// Usage:
///   BaltoToast.success(context, 'Saved!');
///   BaltoToast.error(context, 'Something went wrong.');
///   BaltoToast.warning(context, 'Please accept the terms.');
///   BaltoToast.info(context, 'Loading your profile...');
class BaltoToast {
  BaltoToast._();

  static void success(BuildContext context, String message) =>
      _show(context, message, BaltoToastType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, BaltoToastType.error);

  static void warning(BuildContext context, String message) =>
      _show(context, message, BaltoToastType.warning);

  static void info(BuildContext context, String message) =>
      _show(context, message, BaltoToastType.info);

  static void _show(
    BuildContext context,
    String message,
    BaltoToastType type,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    // Prevent stacking identical messages
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: _durationFor(type),
        content: _BaltoToastContent(message: message, type: type),
      ),
    );
  }

  static Duration _durationFor(BaltoToastType type) {
    switch (type) {
      case BaltoToastType.success:
        return const Duration(milliseconds: 2800);
      case BaltoToastType.info:
        return const Duration(milliseconds: 3200);
      case BaltoToastType.warning:
        return const Duration(milliseconds: 4000);
      case BaltoToastType.error:
        return const Duration(milliseconds: 4500);
    }
  }
}

class _BaltoToastContent extends StatelessWidget {
  const _BaltoToastContent({required this.message, required this.type});

  final String message;
  final BaltoToastType type;

  Color get _bg {
    switch (type) {
      case BaltoToastType.success:
        return const Color(0xFFE8F8F2);
      case BaltoToastType.error:
        return const Color(0xFFFEECE8);
      case BaltoToastType.warning:
        return const Color(0xFFFFF8E6);
      case BaltoToastType.info:
        return const Color(0xFFEBF3FB);
    }
  }

  Color get _accent {
    switch (type) {
      case BaltoToastType.success:
        return AppColors.navWalkers; // #1BAA71
      case BaltoToastType.error:
        return const Color(0xFFD05A24);
      case BaltoToastType.warning:
        return AppColors.navProfile; // #E8A84C
      case BaltoToastType.info:
        return AppColors.navWalks; // #3A80C2
    }
  }

  IconData get _icon {
    switch (type) {
      case BaltoToastType.success:
        return Icons.check_circle_rounded;
      case BaltoToastType.error:
        return Icons.error_rounded;
      case BaltoToastType.warning:
        return Icons.warning_rounded;
      case BaltoToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: AppRadius.radius14,
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radius14,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(width: 4, color: _accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(_icon, color: _accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Subtle paw branding
                        Icon(
                          Icons.pets_rounded,
                          size: 14,
                          color: _accent.withValues(alpha: 0.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
