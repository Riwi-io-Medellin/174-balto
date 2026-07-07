import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared type scale. Covers the dominant (fontSize, fontWeight) combinations
/// found across the app (audited via grep over every `TextStyle(...)` call).
///
/// Each constant defaults to [AppColors.textPrimary] — call `.copyWith(color: ...)`
/// for any other color, exactly as you would with a raw TextStyle. Genuine
/// one-off sizes that don't recur anywhere else are intentionally left as
/// plain inline TextStyle at their call site rather than forced into a
/// mismatched preset.
class AppTextStyles {
  AppTextStyles._();

  // Display — hero numbers / big headline figures (28, rare 24-48 one-offs).
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // Headline — screen/greeting names.
  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Section headers, dialog titles.
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Card titles, list section titles.
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Sub-titles, prominent row titles.
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Emphasized body text (buttons, strong list rows).
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Default paragraph / row text.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Bold variant of body-size text.
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Labels, form field labels, tab labels.
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // Regular-weight small text.
  static const TextStyle labelRegular = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Captions, helper text, timestamps.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle captionStrong = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  // Micro text — badges, chip labels, tiny meta.
  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle microRegular = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
