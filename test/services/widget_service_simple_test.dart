import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/services/widget_service.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/agent_status.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/widget_state.dart';

void main() {
  group('WidgetService', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    group('creation', () {
      test('should create service without throwing', () {
        expect(() => WidgetService(), returnsNormally);
      });
    });

    group('enums', () {
      test('AgentStatus should have expected values', () {
        expect(AgentStatus.values.length, greaterThan(0));
        expect(AgentStatus.values.contains(AgentStatus.idle), isTrue);
      });

      test('AssistantWidgetState should have expected values', () {
        expect(AssistantWidgetState.values.length, greaterThan(0));
        expect(AssistantWidgetState.values.contains(AssistantWidgetState.loading), isTrue);
      });
    });
  });
}