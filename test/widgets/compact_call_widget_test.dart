import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/widgets/compact_call_widget.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/widget_theme.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/agent_status.dart';

void main() {
  group('CompactCallWidget Overflow Menu Tests', () {
    late WidgetTheme theme;

    setUp(() {
      theme = WidgetTheme.light();
    });

    testWidgets('should show overflow menu when URLs are provided', (WidgetTester tester) async {
      // Create mock widget settings with URLs
      final settings = WidgetSettings(
        giveFeedbackUrl: 'https://example.com/feedback',
        reportIssueUrl: 'https://example.com/report',
        viewHistoryUrl: 'https://example.com/history',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactCallWidget(
              theme: theme,
              settings: settings,
              agentStatus: AgentStatus.idle,
              isMuted: false,
              isCallActive: true,
              audioLevels: const [0.1, 0.2, 0.3],
              onClose: () {},
              onToggleMute: () {},
              onEndCall: () {},
              isExpanded: true, // Test expanded mode where overflow menu appears
            ),
          ),
        ),
      );

      // Look for the overflow menu button (more_vert icon)
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should not show overflow menu when no URLs are provided', (WidgetTester tester) async {
      // Create mock widget settings without URLs
      final settings = WidgetSettings();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactCallWidget(
              theme: theme,
              settings: settings,
              agentStatus: AgentStatus.idle,
              isMuted: false,
              isCallActive: true,
              audioLevels: const [0.1, 0.2, 0.3],
              onClose: () {},
              onToggleMute: () {},
              onEndCall: () {},
              isExpanded: true,
            ),
          ),
        ),
      );

      // Should not find the overflow menu button
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('should not show overflow menu in compact mode', (WidgetTester tester) async {
      // Create mock widget settings with URLs
      final settings = WidgetSettings(
        giveFeedbackUrl: 'https://example.com/feedback',
        reportIssueUrl: 'https://example.com/report',
        viewHistoryUrl: 'https://example.com/history',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactCallWidget(
              theme: theme,
              settings: settings,
              agentStatus: AgentStatus.idle,
              isMuted: false,
              isCallActive: true,
              audioLevels: const [0.1, 0.2, 0.3],
              onClose: () {},
              onToggleMute: () {},
              onEndCall: () {},
              isExpanded: false, // Compact mode - no overflow menu
            ),
          ),
        ),
      );

      // Should not find the overflow menu button in compact mode
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('should show popup menu when overflow button is tapped', (WidgetTester tester) async {
      // Create mock widget settings with all URLs
      final settings = WidgetSettings(
        giveFeedbackUrl: 'https://example.com/feedback',
        reportIssueUrl: 'https://example.com/report',
        viewHistoryUrl: 'https://example.com/history',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactCallWidget(
              theme: theme,
              settings: settings,
              agentStatus: AgentStatus.idle,
              isMuted: false,
              isCallActive: true,
              audioLevels: const [0.1, 0.2, 0.3],
              onClose: () {},
              onToggleMute: () {},
              onEndCall: () {},
              isExpanded: true,
            ),
          ),
        ),
      );

      // Tap the overflow menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Check that all menu items are present
      expect(find.text('Give Feedback'), findsOneWidget);
      expect(find.text('View History'), findsOneWidget);
      expect(find.text('Report Issue'), findsOneWidget);

      // Check that the correct icons are present
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should show only available menu items', (WidgetTester tester) async {
      // Create mock widget settings with only some URLs
      final settings = WidgetSettings(
        viewHistoryUrl: 'https://example.com/history',
        reportIssueUrl: 'https://example.com/report',
        // No giveFeedbackUrl
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactCallWidget(
              theme: theme,
              settings: settings,
              agentStatus: AgentStatus.idle,
              isMuted: false,
              isCallActive: true,
              audioLevels: const [0.1, 0.2, 0.3],
              onClose: () {},
              onToggleMute: () {},
              onEndCall: () {},
              isExpanded: true,
            ),
          ),
        ),
      );

      // Tap the overflow menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Check that only available menu items are present
      expect(find.text('Give Feedback'), findsNothing);
      expect(find.text('View History'), findsOneWidget);
      expect(find.text('Report Issue'), findsOneWidget);
    });
  });
}