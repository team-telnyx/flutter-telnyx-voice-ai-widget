import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/call.dart';
import 'package:telnyx_webrtc/model/socket_method.dart';
import 'package:telnyx_webrtc/model/telnyx_message.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import 'package:telnyx_webrtc/telnyx_client.dart';
import 'package:uuid/uuid.dart';
import '../models/agent_status.dart';
import '../models/widget_state.dart';

/// Service that manages the Telnyx client and widget state
class WidgetService extends ChangeNotifier {
  final TelnyxClient _telnyxClient = TelnyxClient();
  final _uuid = const Uuid();

  AssistantWidgetState _widgetState = AssistantWidgetState.loading;
  AgentStatus _agentStatus = AgentStatus.idle;
  dynamic _widgetSettings;
  List<TranscriptItem> _transcript = [];
  bool _isMuted = false;
  bool _isCallActive = false;
  
  // Overlay management
  OverlayEntry? _conversationOverlay;
  bool _isConversationVisible = false;

  Call? get currentCall {
    return _telnyxClient.calls.values.firstOrNull;
  }

  // Getters
  AssistantWidgetState get widgetState => _widgetState;

  AgentStatus get agentStatus => _agentStatus;

  dynamic get widgetSettings => _widgetSettings;

  List<TranscriptItem> get transcript => List.unmodifiable(_transcript);

  bool get isMuted => _isMuted;

  bool get isCallActive => _isCallActive;

  TelnyxClient get telnyxClient => _telnyxClient;
  
  bool get isConversationVisible => _isConversationVisible;

  /// Initialize the widget with assistant ID
  Future<void> initialize(String assistantId) async {
    try {
      _updateWidgetState(AssistantWidgetState.loading);

      // Set up socket message observer
      _observeResponses();

      // Perform anonymous login
      await _telnyxClient.anonymousLogin(targetId: assistantId);
    } catch (e) {
      debugPrint('Error initializing widget: $e');
      _updateWidgetState(AssistantWidgetState.error);
    }
  }

  /// Start a call
  Future<void> startCall() async {
    try {
      _updateWidgetState(AssistantWidgetState.connecting);

      // Make a call to a hardcoded destination
      await _telnyxClient.newInvite(
        'AI Assistant User', // callerName
        'anonymous', // callerNumber
        'xxx', // destinationNumber
        '', // clientState
        debug: true
      );
    } catch (e) {
      debugPrint('Error starting call: $e');
      _updateWidgetState(AssistantWidgetState.error);
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      currentCall?.endCall();
      _isCallActive = false;
      _updateWidgetState(AssistantWidgetState.collapsed);
      _updateAgentStatus(AgentStatus.idle);
      
      // Clear transcript when call ends
      _transcript.clear();
      _telnyxClient.clearTranscript();
      notifyListeners();
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    try {
      if (_isMuted) {
        currentCall?.onMuteUnmutePressed();
      } else {
        currentCall?.onMuteUnmutePressed();
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
      _transcript.add(
        TranscriptItem(
          role: 'user',
          content: message,
          timestamp: DateTime.now(),
          id: _uuid.v4(),
        ),
      );
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

    // Use the SDK's built-in transcript management
    _telnyxClient.onTranscriptUpdate = (List<TranscriptItem> transcriptItems) {
      _transcript = transcriptItems;
      notifyListeners();
    };
  }

  /// Handle client ready response
  void _handleClientReady() {
    // Retrieve widget settings
    _widgetSettings = _telnyxClient.currentWidgetSettings;

    if (_widgetSettings != null) {
      _updateWidgetState(AssistantWidgetState.collapsed);
    } else {
      // If no settings, still show collapsed state with defaults
      _updateWidgetState(AssistantWidgetState.collapsed);
    }
  }

  /// Handle AI conversation messages
  void _handleAiConversation(TelnyxMessage message) {
    try {
      // The message.message property contains the actual data
      // We need to handle it as a dynamic type since the SDK doesn't provide specific types
      final messageData = message.message;
      Map<String, dynamic>? params;
      
      // Try to extract params from the message data
      if (messageData != null) {
        // The message data might have a params property
        try {
          // Use dynamic access since we don't have the exact type
          params = (messageData as dynamic).params as Map<String, dynamic>?;
        } catch (_) {
          // If that doesn't work, the message data might be the params directly
          try {
            params = Map<String, dynamic>.from(messageData as Map);
          } catch (_) {
            debugPrint('Unable to extract params from AI conversation message');
            return;
          }
        }
      }
      
      if (params != null) {
        final type = params['type'] as String?;

        if (type == 'widget_settings') {
          final settingsData =
              params['widget_settings'] as Map<String, dynamic>?;
          if (settingsData != null) {
            // Store widget settings as a dynamic map since WidgetSettings is not available
            _widgetSettings = settingsData;
            notifyListeners();
          }
        } else if (type == 'conversation.item.created') {
          // User finished speaking, agent is thinking
          _updateAgentStatus(AgentStatus.thinking);
        } else if (type == 'response.text.delta') {
          // Agent started responding, can be interrupted
          _updateAgentStatus(AgentStatus.waiting);
        } else if (type == 'response.done' || type == 'response.text.done') {
          // Response is complete, agent is idle
          _updateAgentStatus(AgentStatus.idle);
        }
      }
    } catch (e) {
      debugPrint('Error handling AI conversation: $e');
    }
  }

  /// Handle call answer
  void _handleCallAnswer() {
    _isCallActive = true;
    _updateWidgetState(AssistantWidgetState.expanded);
    _updateAgentStatus(AgentStatus.waiting);
  }

  /// Update widget state
  void _updateWidgetState(AssistantWidgetState newState) {
    if (_widgetState != newState) {
      _widgetState = newState;
      notifyListeners();
    }
  }

  /// Public method to change widget state (for navigation)
  void changeWidgetState(AssistantWidgetState newState) {
    if (newState == AssistantWidgetState.conversation) {
      // Don't change the internal state, just show the overlay
      showConversationOverlay();
    } else {
      _updateWidgetState(newState);
    }
  }
  
  /// Show full-screen conversation overlay
  void showConversationOverlay() {
    if (_isConversationVisible || _conversationOverlay != null) {
      return; // Already showing
    }
    
    // This will be implemented when we have the BuildContext
    _isConversationVisible = true;
    notifyListeners();
  }
  
  /// Hide conversation overlay
  void hideConversationOverlay() {
    if (_conversationOverlay != null) {
      _conversationOverlay!.remove();
      _conversationOverlay = null;
    }
    _isConversationVisible = false;
    notifyListeners();
  }
  
  /// Create and show the conversation overlay with context
  void createConversationOverlay(BuildContext context, Widget Function() widgetBuilder) {
    if (_conversationOverlay != null) {
      return; // Already exists
    }
    
    _conversationOverlay = OverlayEntry(
      builder: (context) => widgetBuilder(),
    );
    
    Overlay.of(context).insert(_conversationOverlay!);
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
    // Clean up overlay if it exists
    hideConversationOverlay();
    _telnyxClient.disconnect();
    super.dispose();
  }
}
