import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Central primary color used across the app. Change this one value to affect UI.
  static const Color primary = Color(0xFFFD7E14);
}

class AppTheme {
  static ThemeData lightTheme() {
    // Start from a generated color scheme but enforce the exact primary color
    final generated = ColorScheme.fromSeed(seedColor: AppColors.primary);
    final colorScheme = generated.copyWith(primary: AppColors.primary, onPrimary: Colors.white);

    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.grey[50],
      // Use Google Fonts Inter for the entire app (falls back if needed)
      textTheme: GoogleFonts.interTextTheme(),
      // Buttons: show a subtle tint and ripple on interaction without darkening
      // overlayColor is resolved per state so pressed/hover get a light tint of primary
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.primary),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) return AppColors.primary.withOpacity(0.12);
            if (states.contains(MaterialState.hovered)) return AppColors.primary.withOpacity(0.08);
            if (states.contains(MaterialState.focused)) return AppColors.primary.withOpacity(0.06);
            return null;
          }),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(AppColors.primary),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) return AppColors.primary.withOpacity(0.12);
            if (states.contains(MaterialState.hovered)) return AppColors.primary.withOpacity(0.08);
            if (states.contains(MaterialState.focused)) return AppColors.primary.withOpacity(0.06);
            return null;
          }),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(AppColors.primary),
          side: MaterialStateProperty.all(BorderSide(color: AppColors.primary)),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) return AppColors.primary.withOpacity(0.12);
            if (states.contains(MaterialState.hovered)) return AppColors.primary.withOpacity(0.08);
            if (states.contains(MaterialState.focused)) return AppColors.primary.withOpacity(0.06);
            return null;
          }),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        splashColor: AppColors.primary.withOpacity(0.12),
        hoverColor: AppColors.primary.withOpacity(0.08),
        focusColor: AppColors.primary.withOpacity(0.06),
      ),
    );
  }
}
