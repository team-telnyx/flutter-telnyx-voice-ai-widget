import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';

void main() {
  group('TelnyxVoiceAiWidget', () {
    test('should be importable', () {
      // Simple test to verify the widget class exists
      expect(TelnyxVoiceAiWidget, isNotNull);
    });
  });

  group('Agent Status Enum', () {
    test('should have all expected values', () {
      expect(AgentStatus.values, contains(AgentStatus.idle));
      expect(AgentStatus.values, contains(AgentStatus.thinking));
      expect(AgentStatus.values, contains(AgentStatus.waiting));
    });

    test('should have correct display text', () {
      expect(AgentStatus.idle.displayText, '');
      expect(AgentStatus.thinking.displayText, 'Agent is thinking...');
      expect(AgentStatus.waiting.displayText, 'Speak to interrupt');
    });
  });

  group('Widget Theme', () {
    test('should have light and dark themes', () {
      expect(WidgetTheme.light, isNotNull);
      expect(WidgetTheme.dark, isNotNull);
      expect(WidgetTheme.light.backgroundColor, isNotNull);
      expect(WidgetTheme.dark.backgroundColor, isNotNull);
    });

    test('should have different colors for light and dark themes', () {
      expect(WidgetTheme.light.backgroundColor, isNot(equals(WidgetTheme.dark.backgroundColor)));
      expect(WidgetTheme.light.textColor, isNot(equals(WidgetTheme.dark.textColor)));
    });
  });

  group('Widget State Enum', () {
    test('should have all expected values', () {
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.loading));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.collapsed));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.connecting));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.expanded));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.conversation));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.error));
    });
  });

  group('Logo Icon Settings', () {
    test('should create with default values', () {
      const settings = LogoIconSettings();
      expect(settings.avatarUrl, isNull);
      expect(settings.size, isNull);
      expect(settings.borderRadius, isNull);
    });

    test('should create with custom values', () {
      const settings = LogoIconSettings(
        avatarUrl: 'https://example.com/avatar.png',
        size: 32.0,
        borderRadius: 16.0,
      );
      expect(settings.avatarUrl, 'https://example.com/avatar.png');
      expect(settings.size, 32.0);
      expect(settings.borderRadius, 16.0);
    });
  });
}