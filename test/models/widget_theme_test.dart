import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/widget_theme.dart';

void main() {
  group('WidgetThemeType', () {
    test('should have light and dark values', () {
      expect(WidgetThemeType.values.length, 2);
      expect(WidgetThemeType.values, contains(WidgetThemeType.light));
      expect(WidgetThemeType.values, contains(WidgetThemeType.dark));
    });
  });

  group('WidgetTheme', () {
    group('light theme', () {
      test('should have correct properties', () {
        const theme = WidgetTheme.light;
        
        expect(theme.type, WidgetThemeType.light);
        expect(theme.backgroundColor, Colors.white);
        expect(theme.primaryColor, const Color(0xFF4F46E5));
        expect(theme.textColor, const Color(0xFF1F2937));
        expect(theme.secondaryTextColor, const Color(0xFF6B7280));
        expect(theme.buttonColor, const Color(0xFFF3F4F6));
        expect(theme.borderColor, const Color(0xFFE5E7EB));
        expect(theme.shadowColor, const Color(0x1A000000));
      });
    });

    group('dark theme', () {
      test('should have correct properties', () {
        const theme = WidgetTheme.dark;
        
        expect(theme.type, WidgetThemeType.dark);
        expect(theme.backgroundColor, const Color(0xFF1F2937));
        expect(theme.primaryColor, const Color(0xFF6366F1));
        expect(theme.textColor, Colors.white);
        expect(theme.secondaryTextColor, const Color(0xFF9CA3AF));
        expect(theme.buttonColor, const Color(0xFF374151));
        expect(theme.borderColor, const Color(0xFF4B5563));
        expect(theme.shadowColor, const Color(0x1AFFFFFF));
      });
    });

    group('fromString', () {
      test('should return light theme for "light"', () {
        final theme = WidgetTheme.fromString('light');
        expect(theme, WidgetTheme.light);
      });

      test('should return dark theme for "dark"', () {
        final theme = WidgetTheme.fromString('dark');
        expect(theme, WidgetTheme.dark);
      });

      test('should return light theme for null', () {
        final theme = WidgetTheme.fromString(null);
        expect(theme, WidgetTheme.light);
      });

      test('should return light theme for invalid string', () {
        final theme = WidgetTheme.fromString('invalid');
        expect(theme, WidgetTheme.light);
      });

      test('should be case insensitive', () {
        expect(WidgetTheme.fromString('DARK'), WidgetTheme.dark);
        expect(WidgetTheme.fromString('Dark'), WidgetTheme.dark);
        expect(WidgetTheme.fromString('LIGHT'), WidgetTheme.light);
        expect(WidgetTheme.fromString('Light'), WidgetTheme.light);
      });

      test('should handle empty string', () {
        final theme = WidgetTheme.fromString('');
        expect(theme, WidgetTheme.light);
      });
    });

    group('constructor', () {
      test('should create theme with all required properties', () {
        const customTheme = WidgetTheme(
          type: WidgetThemeType.light,
          backgroundColor: Colors.red,
          primaryColor: Colors.blue,
          textColor: Colors.black,
          secondaryTextColor: Colors.grey,
          buttonColor: Colors.green,
          borderColor: Colors.yellow,
          shadowColor: Colors.purple,
        );

        expect(customTheme.type, WidgetThemeType.light);
        expect(customTheme.backgroundColor, Colors.red);
        expect(customTheme.primaryColor, Colors.blue);
        expect(customTheme.textColor, Colors.black);
        expect(customTheme.secondaryTextColor, Colors.grey);
        expect(customTheme.buttonColor, Colors.green);
        expect(customTheme.borderColor, Colors.yellow);
        expect(customTheme.shadowColor, Colors.purple);
      });
    });
  });
}