import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Light ───────────────────────────────────────────────────────────────────

  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3A80C2),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD6E8F9),
      onPrimaryContainer: Color(0xFF0D2E50),
      secondary: Color(0xFF1BAA71),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD1F5E5),
      onSecondaryContainer: Color(0xFF09402A),
      tertiary: Color(0xFF4FC3D4),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFCDF4F9),
      onTertiaryContainer: Color(0xFF003740),
      error: Color(0xFFD05A24),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDDD0),
      onErrorContainer: Color(0xFF3E0A00),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1F2937),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF0F2F5),
      surfaceContainer: Color(0xFFE8EBF0),
      surfaceContainerHigh: Color(0xFFE0E4EC),
      surfaceContainerHighest: Color(0xFFD8DCE6),
      onSurfaceVariant: Color(0xFF5A6473),
      outline: Color(0xFFE0E4EC),
      outlineVariant: Color(0xFFF0F2F5),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF1F2937),
      onInverseSurface: Color(0xFFF0F2F5),
      inversePrimary: Color(0xFF9ECBF5),
    );

    return _build(cs);
  }

  // ─── Dark ────────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF3A80C2),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF0D2E50),
      onPrimaryContainer: Color(0xFFD6E8F9),
      secondary: Color(0xFF1BAA71),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF09402A),
      onSecondaryContainer: Color(0xFFD1F5E5),
      tertiary: Color(0xFF4FC3D4),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF003740),
      onTertiaryContainer: Color(0xFFCDF4F9),
      error: Color(0xFFD05A24),
      onError: Colors.white,
      errorContainer: Color(0xFF3E0A00),
      onErrorContainer: Color(0xFFFFDDD0),
      surface: Color(0xFF1A1F25),
      onSurface: Color(0xFFE8ECF0),
      surfaceContainerLowest: Color(0xFF0F1215),
      surfaceContainerLow: Color(0xFF141920),
      surfaceContainer: Color(0xFF1E252D),
      surfaceContainerHigh: Color(0xFF252C35),
      surfaceContainerHighest: Color(0xFF2D3540),
      onSurfaceVariant: Color(0xFF9BA5B2),
      outline: Color(0xFF2E3745),
      outlineVariant: Color(0xFF1E2A35),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE8ECF0),
      onInverseSurface: Color(0xFF1F2937),
      inversePrimary: Color(0xFF3A80C2),
    );

    return _build(cs);
  }

  // ─── Shared builder ───────────────────────────────────────────────────────────

  static ThemeData _build(ColorScheme cs) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: cs.onSurface),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : cs.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cs.primary : cs.surfaceContainerHigh,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            color: s.contains(WidgetState.selected) ? cs.primary : cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: cs.surface,
        textColor: cs.onSurface,
        iconColor: cs.onSurfaceVariant,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      fontFamilyFallback: const ['Ubuntu', 'Roboto'],
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme).apply(
        fontFamilyFallback: const ['Ubuntu', 'Roboto'],
      ),
    );
  }
}
