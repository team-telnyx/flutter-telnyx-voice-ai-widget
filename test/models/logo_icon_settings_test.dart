import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/logo_icon_settings.dart';

void main() {
  group('LogoIconSettings', () {
    group('constructor', () {
      test('should create with default null values', () {
        const settings = LogoIconSettings();
        
        expect(settings.avatarUrl, null);
        expect(settings.size, null);
        expect(settings.borderRadius, null);
        expect(settings.backgroundColor, null);
        expect(settings.borderColor, null);
        expect(settings.borderWidth, null);
        expect(settings.padding, null);
        expect(settings.fit, null);
      });

      test('should create with provided values', () {
        const settings = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
          borderRadius: 25.0,
          backgroundColor: Colors.blue,
          borderColor: Colors.red,
          borderWidth: 2.0,
          padding: EdgeInsets.all(8.0),
          fit: BoxFit.cover,
        );
        
        expect(settings.avatarUrl, 'https://example.com/avatar.png');
        expect(settings.size, 50.0);
        expect(settings.borderRadius, 25.0);
        expect(settings.backgroundColor, Colors.blue);
        expect(settings.borderColor, Colors.red);
        expect(settings.borderWidth, 2.0);
        expect(settings.padding, const EdgeInsets.all(8.0));
        expect(settings.fit, BoxFit.cover);
      });
    });

    group('copyWith', () {
      test('should return new instance with updated values', () {
        const original = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
          borderRadius: 25.0,
        );
        
        final updated = original.copyWith(
          size: 60.0,
          backgroundColor: Colors.green,
        );
        
        expect(updated.avatarUrl, 'https://example.com/avatar.png');
        expect(updated.size, 60.0);
        expect(updated.borderRadius, 25.0);
        expect(updated.backgroundColor, Colors.green);
        expect(updated.borderColor, null);
      });

      test('should preserve original values when not specified', () {
        const original = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
          borderRadius: 25.0,
          backgroundColor: Colors.blue,
          borderColor: Colors.red,
          borderWidth: 2.0,
          padding: EdgeInsets.all(8.0),
          fit: BoxFit.cover,
        );
        
        final updated = original.copyWith(size: 60.0);
        
        expect(updated.avatarUrl, original.avatarUrl);
        expect(updated.size, 60.0);
        expect(updated.borderRadius, original.borderRadius);
        expect(updated.backgroundColor, original.backgroundColor);
        expect(updated.borderColor, original.borderColor);
        expect(updated.borderWidth, original.borderWidth);
        expect(updated.padding, original.padding);
        expect(updated.fit, original.fit);
      });

      test('should handle null values correctly', () {
        const original = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
        );
        
        final updated = original.copyWith(
          backgroundColor: Colors.blue,
        );
        
        expect(updated.avatarUrl, 'https://example.com/avatar.png'); // copyWith doesn't set to null unless explicitly passed
        expect(updated.size, 50.0);
        expect(updated.backgroundColor, Colors.blue);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        const settings1 = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
          borderRadius: 25.0,
          backgroundColor: Colors.blue,
        );
        
        const settings2 = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
          borderRadius: 25.0,
          backgroundColor: Colors.blue,
        );
        
        expect(settings1, equals(settings2));
        expect(settings1.hashCode, equals(settings2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const settings1 = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
        );
        
        const settings2 = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 60.0,
        );
        
        expect(settings1, isNot(equals(settings2)));
        expect(settings1.hashCode, isNot(equals(settings2.hashCode)));
      });

      test('should handle null values in equality', () {
        const settings1 = LogoIconSettings();
        const settings2 = LogoIconSettings();
        
        expect(settings1, equals(settings2));
        expect(settings1.hashCode, equals(settings2.hashCode));
      });

      test('should be equal to itself', () {
        const settings = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
        );
        
        expect(settings, equals(settings));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const settings = LogoIconSettings(
          avatarUrl: 'https://example.com/avatar.png',
          size: 50.0,
          borderRadius: 25.0,
          backgroundColor: Colors.blue,
          borderColor: Colors.red,
          borderWidth: 2.0,
          padding: EdgeInsets.all(8.0),
          fit: BoxFit.cover,
        );
        
        final result = settings.toString();
        
        expect(result, contains('LogoIconSettings('));
        expect(result, contains('avatarUrl: https://example.com/avatar.png'));
        expect(result, contains('size: 50.0'));
        expect(result, contains('borderRadius: 25.0'));
        expect(result, contains('backgroundColor: ${Colors.blue}'));
        expect(result, contains('borderColor: ${Colors.red}'));
        expect(result, contains('borderWidth: 2.0'));
        expect(result, contains('padding: ${const EdgeInsets.all(8.0)}'));
        expect(result, contains('fit: ${BoxFit.cover}'));
      });

      test('should handle null values in toString', () {
        const settings = LogoIconSettings();
        
        final result = settings.toString();
        
        expect(result, contains('LogoIconSettings('));
        expect(result, contains('avatarUrl: null'));
        expect(result, contains('size: null'));
        expect(result, contains('borderRadius: null'));
        expect(result, contains('backgroundColor: null'));
        expect(result, contains('borderColor: null'));
        expect(result, contains('borderWidth: null'));
        expect(result, contains('padding: null'));
        expect(result, contains('fit: null'));
      });
    });
  });
}