import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';

void main() {
  group('TelnyxVoiceAiWidget', () {
    testWidgets('should render in loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TelnyxVoiceAiWidget(
              height: 60,
              width: 300,
              assistantId: 'test-assistant-id',
            ),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Should have correct dimensions
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 300);
    });

    testWidgets('widget should have correct dimensions', (WidgetTester tester) async {
      const testHeight = 80.0;
      const testWidth = 350.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TelnyxVoiceAiWidget(
              height: testHeight,
              width: testWidth,
              assistantId: 'test-assistant-id',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      
      // Verify dimensions are applied
      expect(container.constraints?.maxWidth, testWidth);
    });

    testWidgets('should apply theme colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TelnyxVoiceAiWidget(
              height: 60,
              width: 300,
              assistantId: 'test-assistant-id',
            ),
          ),
        ),
      );

      // Check that container has theme-based decoration
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration?.borderRadius, isNotNull);
      expect(decoration?.boxShadow, isNotNull);
    });

    testWidgets('should handle different widget sizes', (WidgetTester tester) async {
      // Test small widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TelnyxVoiceAiWidget(
              height: 50,
              width: 250,
              assistantId: 'test-assistant-id',
            ),
          ),
        ),
      );
      
      expect(find.byType(TelnyxVoiceAiWidget), findsOneWidget);
      
      // Test large widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TelnyxVoiceAiWidget(
              height: 100,
              width: 400,
              assistantId: 'test-assistant-id',
            ),
          ),
        ),
      );
      
      expect(find.byType(TelnyxVoiceAiWidget), findsOneWidget);
    });

    testWidgets('should require all parameters', (WidgetTester tester) async {
      // This test verifies that the widget constructor requires all parameters
      // The actual compilation would fail if parameters were missing
      const widget = TelnyxVoiceAiWidget(
        height: 60,
        width: 300,
        assistantId: 'test-id',
      );
      
      expect(widget.height, 60);
      expect(widget.width, 300);
      expect(widget.assistantId, 'test-id');
    });
  });

  group('Widget State Enum', () {
    test('should have all expected states', () {
      // Verify all widget states exist
      expect(AssistantWidgetState.values.length, 6);
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.loading));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.collapsed));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.connecting));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.expanded));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.conversation));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.error));
    });
  });

  group('Agent Status Enum', () {
    test('should have all expected statuses', () {
      // Verify all agent statuses exist
      expect(AgentStatus.values.length, 3);
      expect(AgentStatus.values, contains(AgentStatus.idle));
      expect(AgentStatus.values, contains(AgentStatus.thinking));
      expect(AgentStatus.values, contains(AgentStatus.waiting));
    });

    test('should have correct display text', () {
      expect(AgentStatus.idle.displayText, 'Idle');
      expect(AgentStatus.thinking.displayText, 'Agent is thinking...');
      expect(AgentStatus.waiting.displayText, 'Speak to interrupt');
    });
  });

  group('Widget Theme', () {
    test('should have light and dark themes', () {
      const lightTheme = WidgetTheme.light;
      const darkTheme = WidgetTheme.dark;
      
      // Light theme tests
      expect(lightTheme.type, WidgetThemeType.light);
      expect(lightTheme.backgroundColor, Colors.white);
      expect(lightTheme.textColor, const Color(0xFF1F2937));
      
      // Dark theme tests
      expect(darkTheme.type, WidgetThemeType.dark);
      expect(darkTheme.backgroundColor, const Color(0xFF1F2937));
      expect(darkTheme.textColor, Colors.white);
    });

    test('should create theme from string', () {
      expect(WidgetTheme.fromString('light'), WidgetTheme.light);
      expect(WidgetTheme.fromString('dark'), WidgetTheme.dark);
      expect(WidgetTheme.fromString(null), WidgetTheme.light);
      expect(WidgetTheme.fromString('invalid'), WidgetTheme.light);
    });
  });
}
