import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/widgets/control_button.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/widget_theme.dart';

void main() {
  group('ControlButton', () {
    testWidgets('should render with correct properties', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () => pressed = true,
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      // Should find the control button
      expect(find.byType(ControlButton), findsOneWidget);
      
      // Should find the icon button
      expect(find.byType(IconButton), findsOneWidget);
      
      // Should find the phone icon
      expect(find.byIcon(Icons.phone), findsOneWidget);
      
      // Should have correct dimensions
      expect(find.byType(SizedBox), findsWidgets);
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.any((box) => box.width == 64 && box.height == 64), isTrue);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () => pressed = true,
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Should have called the callback
      expect(pressed, true);
    });

    testWidgets('should apply theme colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.phone,
              backgroundColor: Colors.red,
              iconColor: Colors.blue,
              theme: WidgetTheme.dark,
            ),
          ),
        ),
      );

      // Find the container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ControlButton),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border, isA<Border>());
      
      // Check border color from theme
      final border = decoration.border as Border;
      expect(border.top.color, WidgetTheme.dark.borderColor);
    });

    testWidgets('should render different icons correctly', (WidgetTester tester) async {
      // Test with phone icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.phone), findsOneWidget);

      // Test with mic icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.mic,
              backgroundColor: Colors.blue,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsNothing);
    });

    testWidgets('should have correct icon size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 24);
    });

    testWidgets('should have correct container dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ControlButton),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, 56);
      expect(container.constraints?.maxHeight, 56);
    });

    testWidgets('should work with both light and dark themes', (WidgetTester tester) async {
      // Test light theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      expect(find.byType(ControlButton), findsOneWidget);

      // Test dark theme
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlButton(
              onPressed: () {},
              icon: Icons.phone,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
              theme: WidgetTheme.dark,
            ),
          ),
        ),
      );

      expect(find.byType(ControlButton), findsOneWidget);
    });
  });
}