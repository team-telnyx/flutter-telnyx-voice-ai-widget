import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:telnyx_webrtc/telnyx_client.dart';
import '../models/agent_status.dart';
import '../models/widget_state.dart';

/// Service that manages the Telnyx client and widget state
class WidgetService extends ChangeNotifier {
  final TelnyxClient _telnyxClient = TelnyxClient();
  
  WidgetState _widgetState = WidgetState.loading;
  AgentStatus _agentStatus = AgentStatus.idle;
  WidgetSettings? _widgetSettings;
  List<TranscriptItem> _transcript = [];
  bool _isMuted = false;
  bool _isCallActive = false;
  
  // Getters
  WidgetState get widgetState => _widgetState;
  AgentStatus get agentStatus => _agentStatus;
  WidgetSettings? get widgetSettings => _widgetSettings;
  List<TranscriptItem> get transcript => List.unmodifiable(_transcript);
  bool get isMuted => _isMuted;
  bool get isCallActive => _isCallActive;
  TelnyxClient get telnyxClient => _telnyxClient;

  /// Initialize the widget with assistant ID
  Future<void> initialize(String assistantId) async {
    try {
      _updateWidgetState(WidgetState.loading);
      
      // Set up socket message observer
      _observeResponses();
      
      // Perform anonymous login
      await _telnyxClient.anonymousLogin(targetId: assistantId);
      
    } catch (e) {
      debugPrint('Error initializing widget: $e');
      _updateWidgetState(WidgetState.error);
    }
  }

  /// Start a call
  Future<void> startCall() async {
    try {
      _updateWidgetState(WidgetState.connecting);
      
      // Make a call to a hardcoded destination
      await _telnyxClient.newInvite(
        callerName: 'AI Assistant User',
        callerNumber: 'anonymous',
        destinationNumber: 'xxx', // Hardcoded as per requirements
        clientState: 'ai_assistant_call',
      );
      
    } catch (e) {
      debugPrint('Error starting call: $e');
      _updateWidgetState(WidgetState.error);
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      await _telnyxClient.endCall();
      _isCallActive = false;
      _updateWidgetState(WidgetState.collapsed);
      _updateAgentStatus(AgentStatus.idle);
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    try {
      if (_isMuted) {
        await _telnyxClient.unmute();
      } else {
        await _telnyxClient.mute();
      }
      _isMuted = !_isMuted;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  /// Send a text message
  Future<void> sendMessage(String message) async {
    try {
      // Add user message to transcript
      _transcript.add(TranscriptItem(
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      
      // TODO: Implement sending message through Telnyx client
      // This would depend on the specific API available in the SDK
      
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  /// Observe socket responses
  void _observeResponses() {
    _telnyxClient.onSocketMessageReceived = (TelnyxMessage message) async {
      debugPrint('Socket message received: ${message.socketMethod}');
      
      switch (message.socketMethod) {
        case SocketMethod.clientReady:
          _handleClientReady();
          break;
        case SocketMethod.aiConversation:
          _handleAiConversation(message);
          break;
        case SocketMethod.answer:
          _handleCallAnswer();
          break;
        default:
          break;
      }
    };
  }

  /// Handle client ready response
  void _handleClientReady() {
    // Retrieve widget settings
    _widgetSettings = _telnyxClient.currentWidgetSettings;
    
    if (_widgetSettings != null) {
      _updateWidgetState(WidgetState.collapsed);
    } else {
      // If no settings, still show collapsed state with defaults
      _updateWidgetState(WidgetState.collapsed);
    }
  }

  /// Handle AI conversation messages
  void _handleAiConversation(TelnyxMessage message) {
    try {
      final data = message.message;
      if (data is Map<String, dynamic>) {
        final params = data['params'] as Map<String, dynamic>?;
        if (params != null) {
          final type = params['type'] as String?;
          
          if (type == 'widget_settings') {
            final settingsData = params['widget_settings'] as Map<String, dynamic>?;
            if (settingsData != null) {
              _widgetSettings = WidgetSettings.fromJson(settingsData);
              notifyListeners();
            }
          } else if (type == 'conversation.item.created') {
            // User finished speaking, agent is thinking
            _updateAgentStatus(AgentStatus.thinking);
          } else if (type == 'response.text.delta') {
            // Agent started responding, can be interrupted
            _updateAgentStatus(AgentStatus.waiting);
            
            // Add to transcript if it's a new message
            final content = params['content'] as String?;
            if (content != null && content.isNotEmpty) {
              // Check if this is a continuation of the last message
              if (_transcript.isNotEmpty && 
                  _transcript.last.role == 'assistant' &&
                  _transcript.last.isPartial == true) {
                // Update the last message
                _transcript.last.content = (_transcript.last.content ?? '') + content;
              } else {
                // Add new assistant message
                _transcript.add(TranscriptItem(
                  role: 'assistant',
                  content: content,
                  timestamp: DateTime.now(),
                  isPartial: true,
                ));
              }
              notifyListeners();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling AI conversation: $e');
    }
  }

  /// Handle call answer
  void _handleCallAnswer() {
    _isCallActive = true;
    _updateWidgetState(WidgetState.expanded);
    _updateAgentStatus(AgentStatus.waiting);
  }

  /// Update widget state
  void _updateWidgetState(WidgetState newState) {
    if (_widgetState != newState) {
      _widgetState = newState;
      notifyListeners();
    }
  }

  /// Public method to change widget state (for navigation)
  void changeWidgetState(WidgetState newState) {
    _updateWidgetState(newState);
  }

  /// Update agent status
  void _updateAgentStatus(AgentStatus newStatus) {
    if (_agentStatus != newStatus) {
      _agentStatus = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _telnyxClient.disconnect();
    super.dispose();
  }
}

/// Extension to add isPartial property to TranscriptItem
extension TranscriptItemExtension on TranscriptItem {
  bool get isPartial {
    // This is a workaround since we can't modify the SDK model
    // In a real implementation, this would be part of the SDK
    return false;
  }
  
  set isPartial(bool value) {
    // This is a workaround - in real implementation this would be part of the model
  }
}