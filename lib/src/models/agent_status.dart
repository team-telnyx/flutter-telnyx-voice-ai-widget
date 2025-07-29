/// Represents the current status of the AI agent
enum AgentStatus {
  /// Agent is processing user input and thinking
  thinking,
  
  /// Agent is waiting and can be interrupted
  waiting,
  
  /// Agent is idle/not active
  idle,
}

/// Extension to provide default display text for agent status
/// Note: In practice, use the config-aware text methods in widgets instead
extension AgentStatusExtension on AgentStatus {
  String get displayText {
    switch (this) {
      case AgentStatus.thinking:
        return 'Agent is thinking...'; // Default fallback
      case AgentStatus.waiting:
        return 'Speak to interrupt'; // Default fallback
      case AgentStatus.idle:
        return '';
    }
  }
  
  /// Check if the agent is in a state where it can be interrupted
  bool get canBeInterrupted {
    return this == AgentStatus.waiting;
  }
  
  /// Check if the agent is actively processing
  bool get isProcessing {
    return this == AgentStatus.thinking;
  }
}