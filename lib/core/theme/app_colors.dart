import 'package:flutter/material.dart';

/// Central color palette for CHAINWATCH AI — a bright, clean
/// cybersecurity intelligence aesthetic with cool accent tones.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF0F4FA);
  static const Color border = Color(0xFFE1E8F2);
  static const Color borderSubtle = Color(0xFFEDF2F9);

  static const Color primary = Color(0xFF2F6FED);
  static const Color secondary = Color(0xFF12B0A0);

  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF54627A);
  static const Color textMuted = Color(0xFF97A2B8);

  // Risk levels
  static const Color riskLow = Color(0xFF17A567);
  static const Color riskMedium = Color(0xFFCB8A05);
  static const Color riskHigh = Color(0xFFE0672A);
  static const Color riskCritical = Color(0xFFE0304A);

  static Color riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return riskLow;
      case 'medium':
        return riskMedium;
      case 'high':
        return riskHigh;
      case 'critical':
        return riskCritical;
      default:
        return textMuted;
    }
  }

  static const List<Color> chartGradient = [
    Color(0xFF2F6FED),
    Color(0xFF12B0A0),
  ];

  static const Color success = Color(0xFF17A567);
  static const Color warning = Color(0xFFCB8A05);
  static const Color danger = Color(0xFFE0304A);
}
