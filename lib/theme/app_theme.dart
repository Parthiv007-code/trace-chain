import 'package:flutter/material.dart';

/// TraceChain uses a "control-room / audit ledger" visual language:
/// quiet neutrals, electric mint for verified state, amber for attention,
/// and red only for recalls. The palette is context-aware for dark mode.
class AppColors {
  static bool _dark = false;

  static void setDark(bool value) => _dark = value;

  static const primary = Color(0xFF0E8F83);
  static const primaryDark = Color(0xFF08645D);
  static const accent = Color(0xFF4F46E5);
  static const warning = Color(0xFFD89B18);
  static const danger = Color(0xFFE04B4B);
  static const success = Color(0xFF2EAD68);

  static Color get background =>
      _dark ? const Color(0xFF0B1012) : const Color(0xFFF4F7F6);
  static Color get surface =>
      _dark ? const Color(0xFF121A1D) : const Color(0xFFFFFFFF);
  static Color get surfaceRaised =>
      _dark ? const Color(0xFF172124) : const Color(0xFFFBFCFC);
  static Color get ink =>
      _dark ? const Color(0xFFE8F0EF) : const Color(0xFF10201F);
  static Color get inkMuted =>
      _dark ? const Color(0xFF91A6A3) : const Color(0xFF637774);
  static Color get border =>
      _dark ? const Color(0xFF263538) : const Color(0xFFDCE6E3);
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? const Color(0xFF0B1012) : const Color(0xFFF4F7F6);
    final surface = dark ? const Color(0xFF121A1D) : const Color(0xFFFFFFFF);
    final raised = dark ? const Color(0xFF172124) : const Color(0xFFFBFCFC);
    final ink = dark ? const Color(0xFFE8F0EF) : const Color(0xFF10201F);
    final muted = dark ? const Color(0xFF91A6A3) : const Color(0xFF637774);
    final border = dark ? const Color(0xFF263538) : const Color(0xFFDCE6E3);
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: dark ? const Color(0xFF0E3B37) : const Color(0xFFDDF3F0),
      onPrimaryContainer: dark ? const Color(0xFFB9FFF7) : const Color(0xFF073E39),
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: dark ? const Color(0xFF27234B) : const Color(0xFFEDEBFF),
      onSecondaryContainer: dark ? const Color(0xFFDCD8FF) : const Color(0xFF29215F),
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: raised,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
      error: AppColors.danger,
      onError: Colors.white,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark ? const Color(0xFFE8F0EF) : const Color(0xFF10201F),
      onInverseSurface: dark ? const Color(0xFF10201F) : Colors.white,
      inversePrimary: const Color(0xFF55C9BE),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.4),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: ink),
        bodyMedium: TextStyle(color: ink, height: 1.45),
        bodySmall: TextStyle(color: muted, height: 1.35),
        labelSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.7, color: muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: raised,
        side: BorderSide(color: border),
        labelStyle: TextStyle(fontSize: 12, color: ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFFE8F0EF) : const Color(0xFF10201F),
        contentTextStyle: TextStyle(color: dark ? const Color(0xFF10201F) : Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withOpacity(dark ? .22 : .12),
        labelTextStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
