import 'package:flutter/material.dart';

/// Theme configuration for the voice AI widget
enum WidgetThemeType {
  light,
  dark,
}

/// Widget theme configuration
class WidgetTheme {
  final WidgetThemeType type;
  final Color backgroundColor;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color buttonColor;
  final Color borderColor;
  final Color shadowColor;

  const WidgetTheme({
    required this.type,
    required this.backgroundColor,
    required this.primaryColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.buttonColor,
    required this.borderColor,
    required this.shadowColor,
  });

  /// Light theme configuration
  static const light = WidgetTheme(
    type: WidgetThemeType.light,
    backgroundColor: Colors.white,
    primaryColor: Color(0xFF4F46E5),
    textColor: Color(0xFF1F2937),
    secondaryTextColor: Color(0xFF6B7280),
    buttonColor: Color(0xFFF3F4F6),
    borderColor: Color(0xFFE5E7EB),
    shadowColor: Color(0x1A000000),
  );

  /// Dark theme configuration
  static const dark = WidgetTheme(
    type: WidgetThemeType.dark,
    backgroundColor: Color(0xFF1F2937),
    primaryColor: Color(0xFF6366F1),
    textColor: Colors.white,
    secondaryTextColor: Color(0xFF9CA3AF),
    buttonColor: Color(0xFF374151),
    borderColor: Color(0xFF4B5563),
    shadowColor: Color(0x1AFFFFFF),
  );

  /// Create theme from string
  static WidgetTheme fromString(String? themeString) {
    switch (themeString?.toLowerCase()) {
      case 'dark':
        return dark;
      case 'light':
      default:
        return light;
    }
  }
}