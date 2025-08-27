import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/widgets/loading_widget.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/widget_theme.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should render with correct dimensions', (WidgetTester tester) async {
      const testWidth = 300.0;
      const testHeight = 60.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: testWidth,
              height: testHeight,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      // Should find the loading widget
      expect(find.byType(LoadingWidget), findsOneWidget);
      
      // Should find the circular progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Check container dimensions
      expect(find.byType(Container), findsWidgets);
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.constraints?.maxWidth == testWidth), isTrue);
    });

    testWidgets('should apply light theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
      final containers = tester.widgetList<Container>(find.byType(Container));
      final decoratedContainer = containers.firstWhere((c) => c.decoration != null);
      final decoration = decoratedContainer.decoration as BoxDecoration;
      
      expect(decoration.color, WidgetTheme.light.backgroundColor);
      expect(decoration.borderRadius, BorderRadius.circular(30)); // height / 2
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow!.first.color, WidgetTheme.light.shadowColor);
      expect(decoration.boxShadow!.first.blurRadius, 8);
      expect(decoration.boxShadow!.first.offset, const Offset(0, 2));
    });

    testWidgets('should apply dark theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.dark,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
      final containers = tester.widgetList<Container>(find.byType(Container));
      final decoratedContainer = containers.firstWhere((c) => c.decoration != null);
      final decoration = decoratedContainer.decoration as BoxDecoration;
      
      expect(decoration.color, WidgetTheme.dark.backgroundColor);
      expect(decoration.boxShadow!.first.color, WidgetTheme.dark.shadowColor);
    });

    testWidgets('should have correct progress indicator properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      expect(progressIndicator.strokeWidth, 2);
      expect(progressIndicator.valueColor, isA<AlwaysStoppedAnimation<Color>>());
      
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, WidgetTheme.light.primaryColor);
    });

    testWidgets('should have correct progress indicator size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(LoadingWidget),
          matching: find.byType(SizedBox),
        ),
      );
      
      expect(sizedBox.width, 20);
      expect(sizedBox.height, 20);
    });

    testWidgets('should center the progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      // Should find a Center widget
      expect(find.byType(Center), findsOneWidget);
      
      // Progress indicator should be inside the center widget
      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should handle different dimensions', (WidgetTester tester) async {
      // Test small widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 200,
              height: 40,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingWidget), findsOneWidget);
      
      expect(find.byType(Container), findsWidgets);
      var containers = tester.widgetList<Container>(find.byType(Container));
      var decoratedContainer = containers.firstWhere((c) => c.decoration != null);
      var decoration = decoratedContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20)); // 40 / 2

      // Test large widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 400,
              height: 80,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      containers = tester.widgetList<Container>(find.byType(Container));
      decoratedContainer = containers.firstWhere((c) => c.decoration != null);
      decoration = decoratedContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(40)); // 80 / 2
    });

    testWidgets('should work with both theme types', (WidgetTester tester) async {
      // Test with light theme
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.light,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Test with dark theme
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              width: 300,
              height: 60,
              theme: WidgetTheme.dark,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, WidgetTheme.dark.primaryColor);
    });
  });
}