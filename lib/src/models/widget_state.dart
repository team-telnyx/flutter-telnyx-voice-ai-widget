/// Represents the current state of the voice AI widget
enum WidgetState {
  /// Widget is loading/initializing
  loading,
  
  /// Widget is in collapsed state (initial state)
  collapsed,
  
  /// Widget is connecting to the call
  connecting,
  
  /// Widget is in expanded state during active call
  expanded,
  
  /// Widget is showing the conversation transcript
  conversation,
  
  /// Widget encountered an error
  error,
}