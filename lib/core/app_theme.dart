import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

/// Konfigurasi tema global Flutter (Light & Dark Theme)
/// Mengimplementasikan sistem tipografi Plus Jakarta Sans dan spesifikasi komponen FindIT Campus.
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // 1. LIGHT THEME (TEMA TERANG UTAMA)
  // ===========================================================================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgCanvas,
      primaryColor: AppColors.actionPrimary,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.actionPrimary,
        onPrimary: AppColors.actionOnPrimary,
        secondary: AppColors.actionSecondary,
        onSecondary: AppColors.actionOnSecondary,
        error: AppColors.borderError,
        onError: AppColors.white,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
      ),

      // Tipografi Plus Jakarta Sans
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.actionOnPrimary,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Elevated Button Theme (Primary Button 54px r18 Bold 15)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionPrimary,
          foregroundColor: AppColors.actionOnPrimary,
          minimumSize: const Size.fromHeight(AppDimens.buttonPrimaryHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius18),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlined / Secondary Button Theme (40px r18)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.actionSecondary,
          foregroundColor: AppColors.actionOnSecondary,
          minimumSize: const Size.fromHeight(AppDimens.buttonSecondaryHeight),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius18),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Input Text Field Theme (48px r14 Stroke 1.5)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPlaceholder,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.borderDefault,
            width: AppDimens.borderDefaultStroke,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.borderDefault,
            width: AppDimens.borderDefaultStroke,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.borderFocus,
            width: AppDimens.borderFocusStroke,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: AppDimens.borderDefaultStroke,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.borderError,
            width: AppDimens.borderFocusStroke,
          ),
        ),
      ),

      // Card Theme (r20, Flat dengan custom box shadow)
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
        margin: EdgeInsets.zero,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.progressValue,
        linearTrackColor: AppColors.progressTrack,
        linearMinHeight: AppDimens.progressBarHeight,
      ),
    );
  }

  // ===========================================================================
  // 2. DARK THEME (USULAN TEMA GELAP DARI DOKUMEN FIGMA)
  // ===========================================================================
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgCanvas,
      primaryColor: AppColors.darkActionPrimary,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkActionPrimary,
        onPrimary: AppColors.darkActionOnPrimary,
        secondary: AppColors.darkActionSecondary,
        onSecondary: AppColors.darkActionOnSecondary,
        error: AppColors.darkBorderError,
        onError: AppColors.green950,
        surface: AppColors.darkBgSurface,
        onSurface: AppColors.darkTextPrimary,
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.darkTextPrimary,
          height: 1.2,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextSecondary,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkActionPrimary,
          foregroundColor: AppColors.darkActionOnPrimary,
          minimumSize: const Size.fromHeight(AppDimens.buttonPrimaryHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius18),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextPlaceholder,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.darkBorderDefault,
            width: AppDimens.borderDefaultStroke,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.darkBorderDefault,
            width: AppDimens.borderDefaultStroke,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius14),
          borderSide: const BorderSide(
            color: AppColors.darkBorderFocus,
            width: AppDimens.borderFocusStroke,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius20),
        ),
      ),
    );
  }
}

