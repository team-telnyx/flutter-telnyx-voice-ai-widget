import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_telnyx_voice_ai_widget/src/models/agent_status.dart';

void main() {
  group('AgentStatus', () {
    test('should have all expected values', () {
      expect(AgentStatus.values.length, 4);
      expect(AgentStatus.values, contains(AgentStatus.thinking));
      expect(AgentStatus.values, contains(AgentStatus.waiting));
      expect(AgentStatus.values, contains(AgentStatus.idle));
      expect(AgentStatus.values, contains(AgentStatus.processingImage));
    });

    group('displayText extension', () {
      test('should return correct display text for thinking', () {
        expect(AgentStatus.thinking.displayText, 'Agent is thinking...');
      });

      test('should return correct display text for waiting', () {
        expect(AgentStatus.waiting.displayText, 'Speak to interrupt');
      });

      test('should return empty string for idle', () {
        expect(AgentStatus.idle.displayText, '');
      });

      test('should return correct display text for processingImage', () {
        expect(AgentStatus.processingImage.displayText, 'Processing image...');
      });
    });

    group('canBeInterrupted extension', () {
      test('should return true only for waiting status', () {
        expect(AgentStatus.waiting.canBeInterrupted, true);
        expect(AgentStatus.thinking.canBeInterrupted, false);
        expect(AgentStatus.idle.canBeInterrupted, false);
        expect(AgentStatus.processingImage.canBeInterrupted, false);
      });
    });

    group('isProcessing extension', () {
      test('should return true only for thinking status', () {
        expect(AgentStatus.thinking.isProcessing, true);
        expect(AgentStatus.waiting.isProcessing, false);
        expect(AgentStatus.idle.isProcessing, false);
        expect(AgentStatus.processingImage.isProcessing, false);
      });
    });
  });
}