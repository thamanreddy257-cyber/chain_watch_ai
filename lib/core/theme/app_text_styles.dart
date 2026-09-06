import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system: Inter for body copy, Space Grotesk for headers,
/// numbers, and wallet addresses — gives the app a "terminal/intel" feel.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _inter => GoogleFonts.inter();
  static TextStyle get _mono => GoogleFonts.spaceGrotesk();
  static TextStyle get _jetbrainsMono => GoogleFonts.jetBrainsMono();

  static TextStyle get displayLarge => _mono.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.05,
      );

  static TextStyle get displayMedium => _mono.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get headlineLarge => _mono.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => _mono.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => _mono.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => _inter.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _inter.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _inter.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get label => _inter.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      );

  static TextStyle get mono => _jetbrainsMono.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoSmall => _jetbrainsMono.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get statNumber => _mono.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get button => _inter.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.background,
      );
}
