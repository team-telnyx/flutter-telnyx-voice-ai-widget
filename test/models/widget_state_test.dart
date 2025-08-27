import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/widget_state.dart';

void main() {
  group('AssistantWidgetState', () {
    test('should have all expected states', () {
      expect(AssistantWidgetState.values.length, 6);
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.loading));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.collapsed));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.connecting));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.expanded));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.conversation));
      expect(AssistantWidgetState.values, contains(AssistantWidgetState.error));
    });

    test('should have correct enum values', () {
      expect(AssistantWidgetState.loading.index, 0);
      expect(AssistantWidgetState.collapsed.index, 1);
      expect(AssistantWidgetState.connecting.index, 2);
      expect(AssistantWidgetState.expanded.index, 3);
      expect(AssistantWidgetState.conversation.index, 4);
      expect(AssistantWidgetState.error.index, 5);
    });

    test('should be able to compare states', () {
      expect(AssistantWidgetState.loading == AssistantWidgetState.loading, true);
      expect(AssistantWidgetState.loading == AssistantWidgetState.collapsed, false);
      expect(AssistantWidgetState.error != AssistantWidgetState.loading, true);
    });

    test('should have correct string representation', () {
      expect(AssistantWidgetState.loading.toString(), 'AssistantWidgetState.loading');
      expect(AssistantWidgetState.collapsed.toString(), 'AssistantWidgetState.collapsed');
      expect(AssistantWidgetState.connecting.toString(), 'AssistantWidgetState.connecting');
      expect(AssistantWidgetState.expanded.toString(), 'AssistantWidgetState.expanded');
      expect(AssistantWidgetState.conversation.toString(), 'AssistantWidgetState.conversation');
      expect(AssistantWidgetState.error.toString(), 'AssistantWidgetState.error');
    });
  });
}