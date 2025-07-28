/// Represents the current status of the AI agent
enum AgentStatus {
  /// Agent is processing user input and thinking
  thinking,
  
  /// Agent is waiting and can be interrupted
  waiting,
  
  /// Agent is idle/not active
  idle,
}

/// Extension to provide display text for agent status
extension AgentStatusExtension on AgentStatus {
  String get displayText {
    switch (this) {
      case AgentStatus.thinking:
        return 'Agent is thinking...';
      case AgentStatus.waiting:
        return 'Speak to interrupt';
      case AgentStatus.idle:
        return '';
    }
  }
}