import 'package:flutter/material.dart';

class AppTheme {
  // M3 Seed Color - Antique Gold (warm luxury)
  static const Color seedColor = Color(0xFFD4AF37);

  // Brand palette constants (for direct use)
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryGoldDark = Color(0xFFAA820A);
  static const Color accentGold = Color(0xFFFFDF73);

  // Status semantic colors
  static const Color statusWaiting = Color(0xFFF59E0B);
  static const Color statusCutting = Color(0xFF10B981);
  static const Color statusDone = Color(0xFF6B7280);

  // M3 color scheme built from seed
  static ColorScheme get _darkColorScheme => ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFFE8C84A),
        onPrimary: const Color(0xFF1A1400),
        primaryContainer: const Color(0xFF3D2F00),
        onPrimaryContainer: const Color(0xFFFFDF73),
        secondary: const Color(0xFFD4AA5A),
        onSecondary: const Color(0xFF1A1100),
        secondaryContainer: const Color(0xFF2E2200),
        onSecondaryContainer: const Color(0xFFFFDFA6),
        tertiary: const Color(0xFF9ECAFF),
        onTertiary: const Color(0xFF003258),
        error: const Color(0xFFFF6B6B),
        onError: const Color(0xFF1A0000),
        errorContainer: const Color(0xFF4D0000),
        onErrorContainer: const Color(0xFFFFB4B4),
        surface: const Color(0xFF111318),
        onSurface: const Color(0xFFE5E1D8),
        surfaceContainerLowest: const Color(0xFF0C0E12),
        surfaceContainerLow: const Color(0xFF15181F),
        surfaceContainer: const Color(0xFF1B1E26),
        surfaceContainerHigh: const Color(0xFF23272F),
        surfaceContainerHighest: const Color(0xFF2C3039),
        onSurfaceVariant: const Color(0xFFC5C0B5),
        outline: const Color(0xFF4A4740),
        outlineVariant: const Color(0xFF2A2820),
        inverseSurface: const Color(0xFFE5E1D8),
        onInverseSurface: const Color(0xFF2C2B27),
        inversePrimary: const Color(0xFF6B5400),
        shadow: Colors.black,
        scrim: Colors.black,
      );

  static ThemeData get darkTheme {
    final cs = _darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      fontFamily: 'Cairo',

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: cs.primary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontFamily: 'Cairo',
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: cs.primary,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: cs.primary,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
        prefixIconColor: cs.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      // FilledButton (M3 primary action)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        selectedColor: cs.primaryContainer,
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: cs.onSurface),
        secondaryLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: cs.onPrimaryContainer),
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: cs.onSurfaceVariant,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: cs.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // List tile
      listTileTheme: ListTileThemeData(
        tileColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: cs.onSurfaceVariant,
        ),
        iconColor: cs.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: cs.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: cs.onSurfaceVariant.withValues(alpha: 0.4),
      ),

      scaffoldBackgroundColor: cs.surface,
    );
  }

  // Convenience getters for status colors with M3 container style
  static Color statusWaitingContainer = const Color(0xFF3D2C00);
  static Color statusCuttingContainer = const Color(0xFF003D29);
  static Color statusDoneContainer = const Color(0xFF232323);

  // Text styles
  static const TextStyle textLight = TextStyle(color: Color(0xFFE5E1D8));
  static const TextStyle textMuted = TextStyle(color: Color(0xFFC5C0B5));
}
