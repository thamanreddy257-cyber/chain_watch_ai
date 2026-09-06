import 'package:flutter/material.dart';

/// Central color palette for CHAINWATCH AI — a dark, premium
/// cybersecurity intelligence aesthetic.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF121826);
  static const Color surfaceElevated = Color(0xFF161D2C);
  static const Color border = Color(0xFF1E2733);
  static const Color borderSubtle = Color(0xFF17202B);

  static const Color primary = Color(0xFF00E5FF);
  static const Color secondary = Color(0xFF00FF9C);

  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B98A9);
  static const Color textMuted = Color(0xFF5A6677);

  // Risk levels
  static const Color riskLow = Color(0xFF00E676);
  static const Color riskMedium = Color(0xFFFFD54F);
  static const Color riskHigh = Color(0xFFFF6D00);
  static const Color riskCritical = Color(0xFFFF1744);

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
    Color(0xFF00E5FF),
    Color(0xFF00FF9C),
  ];

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD54F);
  static const Color danger = Color(0xFFFF1744);
}
