import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/call.dart';
import 'package:telnyx_webrtc/model/call_quality_metrics.dart';
import 'package:telnyx_webrtc/model/socket_method.dart';
import 'package:telnyx_webrtc/model/telnyx_message.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import 'package:telnyx_webrtc/telnyx_client.dart';
import 'package:telnyx_webrtc/model/telnyx_socket_error.dart';
import 'package:uuid/uuid.dart';
import '../models/agent_status.dart';
import '../models/widget_state.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';

/// Service that manages the Telnyx client and widget state
class WidgetService extends ChangeNotifier {
  final TelnyxClient _telnyxClient = TelnyxClient();
  final _uuid = const Uuid();

  AssistantWidgetState _widgetState = AssistantWidgetState.loading;
  AgentStatus _agentStatus = AgentStatus.idle;
  WidgetSettings? _widgetSettings;
  List<TranscriptItem> _transcript = [];
  bool _isMuted = false;
  bool _isCallActive = false;
  String? _assistantId;

  // Audio visualization data
  final List<double> _inboundAudioLevels = [];
  final List<double> _processedAudioLevels = [];
  CallQualityMetrics? _callQualityMetrics;

  // Audio processing configuration
  static const int maxAudioLevels = 100;
  static const double _audioSensitivity = 2.0; // Boost factor for low levels
  static const double _noiseGate = 0.05; // Minimum level to register

  // Overlay management
  OverlayEntry? _conversationOverlay;
  bool _isConversationVisible = false;

  // Icon-only mode state tracking
  bool _isIconOnlyConnecting = false;

  // Transcript callback for external consumers
  void Function(List<TranscriptItem> transcript)? onTranscriptUpdate;

  // Track previous transcript to detect new/changed messages
  List<TranscriptItem> _previousTranscript = [];

  Call? get currentCall {
    return _telnyxClient.calls.values.firstOrNull;
  }

  // Getters
  AssistantWidgetState get widgetState => _widgetState;

  AgentStatus get agentStatus => _agentStatus;

  WidgetSettings? get widgetSettings =>
      _widgetSettingOverride ?? _widgetSettings;

  List<TranscriptItem> get transcript => List.unmodifiable(_transcript);

  bool get isMuted => _isMuted;

  bool get isCallActive => _isCallActive;

  TelnyxClient get telnyxClient => _telnyxClient;

  bool get isConversationVisible => _isConversationVisible;

  String? get assistantId => _assistantId;

  bool get isIconOnlyConnecting => _isIconOnlyConnecting;

  /// Gets the current processed audio levels for visualization (preferred)
  List<double> get inboundAudioLevels =>
      List.unmodifiable(_processedAudioLevels.isNotEmpty
          ? _processedAudioLevels
          : _inboundAudioLevels);

  /// Gets the raw inbound audio levels
  List<double> get rawInboundAudioLevels =>
      List.unmodifiable(_inboundAudioLevels);

  /// Gets the current call quality metrics
  CallQualityMetrics? get callQualityMetrics => _callQualityMetrics;

  WidgetSettings? _widgetSettingOverride;

  /// Initialize the widget with assistant ID
  Future<void> initialize(String assistantId,
      {WidgetSettings? widgetSettingOverride}) async {
    try {
      _assistantId = assistantId;
      _widgetSettingOverride = widgetSettingOverride;
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
      final call = _telnyxClient.newInvite(
          'AI Assistant User', // callerName
          'anonymous', // callerNumber
          'xxx', // destinationNumber
          '', // clientState
          debug: true);

      // Set up call quality metrics observation
      _observeCallQuality(call);
    } catch (e) {
      debugPrint('Error starting call: $e');
      _updateWidgetState(AssistantWidgetState.error);
    }
  }

  /// Start a call in icon-only mode
  Future<void> startIconOnlyCall() async {
    try {
      _isIconOnlyConnecting = true;
      notifyListeners();

      // Make a call to a hardcoded destination
      final call = _telnyxClient.newInvite(
          'AI Assistant User', // callerName
          'anonymous', // callerNumber
          'xxx', // destinationNumber
          '', // clientState
          debug: true);

      // Set up call quality metrics observation
      _observeCallQuality(call);
    } catch (e) {
      debugPrint('Error starting icon-only call: $e');
      _isIconOnlyConnecting = false;
      _updateWidgetState(AssistantWidgetState.error);
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      currentCall?.endCall();
      _isCallActive = false;
      _isIconOnlyConnecting = false; // Reset icon-only connecting state
      _updateWidgetState(AssistantWidgetState.collapsed);
      _updateAgentStatus(AgentStatus.idle);

      // Clear transcript when call ends
      _transcript.clear();
      _telnyxClient.clearTranscript();

      // Clear audio levels and metrics
      _inboundAudioLevels.clear();
      _processedAudioLevels.clear();
      _callQualityMetrics = null;

      // Update overlay if it's visible to reflect cleared transcript
      if (_conversationOverlay != null) {
        _conversationOverlay!.markNeedsBuild();
      }

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

  /// Send a text message with optional image
  Future<void> sendMessage(String message, {String? base64Image}) async {
    try {
      currentCall?.sendConversationMessage(message, base64Image: base64Image);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  /// Observe socket responses
  void _observeResponses() {
    _telnyxClient.onSocketMessageReceived = (TelnyxMessage message) async {
      debugPrint('📨 Socket message received: ${message.socketMethod}');

      switch (message.socketMethod) {
        case SocketMethod.clientReady:
          debugPrint('✅ Client ready');
          _handleClientReady();
          break;
        case SocketMethod.aiConversation:
          debugPrint('AI CONVERSATION MESSAGE :: ${message.message}');
          _handleAiConversation(message);
          break;
        case SocketMethod.answer:
          debugPrint('📞 Call answered');
          _handleCallAnswer();
          break;
        case SocketMethod.bye:
          debugPrint('📞 Call ended');
          _isCallActive = false;
          _isIconOnlyConnecting = false; // Reset icon-only connecting state

          // Close conversation overlay if it's open
          hideConversationOverlay();

          // clear transcript and audio levels when call ends
          _transcript.clear();
          _inboundAudioLevels.clear();

          _updateWidgetState(AssistantWidgetState.collapsed);
          _updateAgentStatus(AgentStatus.idle);
          break;
        default:
          debugPrint('❓ Unknown socket method: ${message.socketMethod}');
          break;
      }
    };

    // Use the SDK's built-in transcript management
    _telnyxClient.onTranscriptUpdate = (List<TranscriptItem> transcriptItems) {
      _transcript = List.from(transcriptItems);

      // Filter out partial messages
      final fullTranscript =
          _transcript.where((item) => item.isPartial != true).toList();

      // Detect new or changed messages by comparing with previous transcript
      if (onTranscriptUpdate != null) {
        // Find messages that are new or have changed content
        final newOrChangedMessages = <TranscriptItem>[];

        for (final item in fullTranscript) {
          // Skip empty messages
          if (item.content.trim().isEmpty) {
            continue;
          }

          final previousItem = _previousTranscript.firstWhere(
            (prev) => prev.id == item.id,
            orElse: () => TranscriptItem(
              role: '',
              content: '',
              timestamp: DateTime.now(),
              id: '',
            ),
          );

          // Add if it's a new message (not found) or content has changed
          if (previousItem.id.isEmpty || previousItem.content != item.content) {
            newOrChangedMessages.add(item);
          }
        }

        // Only emit if there are new or changed messages
        if (newOrChangedMessages.isNotEmpty) {
          onTranscriptUpdate!(newOrChangedMessages);
        }

        // Update previous transcript for next comparison
        _previousTranscript = List.from(fullTranscript);
      }

      notifyListeners();
    };

    // Handle socket errors
    _telnyxClient.onSocketErrorReceived = (TelnyxSocketError error) {
      debugPrint('❌ Socket error: ${error.errorMessage} (${error.errorCode})');
      _updateWidgetState(AssistantWidgetState.error);
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
      // Use the SDK's properly parsed AI conversation params
      final aiParams = message.message.aiConversationParams;

      if (aiParams == null) {
        debugPrint('❌ AI conversation params are null');
        return;
      }

      final type = aiParams.type;
      debugPrint('🔍 AI Conversation message received - Type: $type');

      switch (type) {
        case 'widget_settings':
          _handleWidgetSettings(aiParams);
          break;
        case 'conversation.item.created':
          _handleConversationItemCreated(aiParams);
          break;
        case 'response.text.delta':
          _handleResponseTextDelta(aiParams);
          break;
        case 'response.done':
        case 'response.text.done':
          _handleResponseDone(aiParams);
          break;
        case 'response.created':
          _handleResponseCreated(aiParams);
          break;
        case 'response.output_item.added':
          _handleResponseOutputItemAdded(aiParams);
          break;
        case 'response.content_part.added':
          _handleResponseContentPartAdded(aiParams);
          break;
        default:
          debugPrint('❓ Unknown AI conversation type: $type');
          break;
      }
    } catch (e) {
      debugPrint('Error handling AI conversation: $e');
    }
  }

  void _handleWidgetSettings(AiConversationParams params) {
    if (params.widgetSettings != null) {
      // Store WidgetSettings object directly
      _widgetSettings = params.widgetSettings!;
      debugPrint('✅ Widget settings updated');
      notifyListeners();
    }
  }

  void _handleConversationItemCreated(AiConversationParams params) {
    final item = params.item;
    if (item != null) {
      if (item.role == 'user') {
        // User finished speaking, agent is thinking
        debugPrint('🤔 User finished speaking - Agent thinking');
        _updateAgentStatus(AgentStatus.thinking);

        // Add user message to transcript if it has content
        if (item.content != null && item.content!.isNotEmpty) {
          final content = item.content!.first;
          if (content.transcript != null && content.transcript!.isNotEmpty) {
            _addTranscriptItem(TranscriptItem(
              role: 'user',
              content: content.transcript!,
              timestamp: DateTime.now(),
              id: item.id ?? _uuid.v4(),
            ));
          }
        }
      } else if (item.role == 'assistant') {
        // Assistant item created
        debugPrint('🤖 Assistant item created');
      }
    }
  }

  void _handleResponseTextDelta(AiConversationParams params) {
    // Agent started responding, can be interrupted
    debugPrint('💬 AI started responding - Agent waiting');
    _updateAgentStatus(AgentStatus.waiting);

    // Handle delta text for building transcript
    if (params.delta != null && params.delta!.isNotEmpty) {
      _handleAssistantTextDelta(
          params.delta!, params.itemId, params.responseId);
    }
  }

  void _handleResponseDone(AiConversationParams params) {
    // Response is complete, agent is idle
    debugPrint('✅ Response complete - Agent idle');
    _updateAgentStatus(AgentStatus.idle);

    // Mark any partial response as complete
    if (params.responseId != null) {
      _finalizeAssistantResponse(params.responseId!);
    }
  }

  void _handleResponseCreated(AiConversationParams params) {
    debugPrint('🔄 Response created');
    // Response generation started - this usually means the agent is about to respond
    _updateAgentStatus(AgentStatus.waiting);
  }

  void _handleResponseOutputItemAdded(AiConversationParams params) {
    debugPrint('📤 Response output item added');
    // Response output item added - response is being prepared
  }

  void _handleResponseContentPartAdded(AiConversationParams params) {
    debugPrint('📝 Response content part added');
    // Content part added to response
  }

  /// Handle assistant text delta for building transcript
  void _handleAssistantTextDelta(
      String delta, String? itemId, String? responseId) {
    if (itemId == null) return;

    // Find existing assistant message or create new one
    final existingIndex = _transcript.indexWhere((item) => item.id == itemId);

    if (existingIndex != -1) {
      // Update existing message
      final existing = _transcript[existingIndex];
      _transcript[existingIndex] = TranscriptItem(
        role: existing.role,
        content: existing.content + delta,
        timestamp: existing.timestamp,
        id: existing.id,
        isPartial: true,
      );

      // Update overlay if it's visible
      if (_conversationOverlay != null) {
        _conversationOverlay!.markNeedsBuild();
      }

      notifyListeners();
    } else {
      // Create new assistant message
      _addTranscriptItem(TranscriptItem(
        role: 'assistant',
        content: delta,
        timestamp: DateTime.now(),
        id: itemId,
        isPartial: true,
      ));
    }
  }

  /// Add transcript item to the list
  void _addTranscriptItem(TranscriptItem item) {
    _transcript.add(item);

    // If this is a full message (not partial), emit to callback
    if (item.isPartial != true) {
      final fullTranscript = _transcript
          .where((transcriptItem) => transcriptItem.isPartial != true)
          .toList();
      if (onTranscriptUpdate != null) {
        onTranscriptUpdate!(fullTranscript);
      }
    }

    // Update overlay if it's visible
    if (_conversationOverlay != null) {
      _conversationOverlay!.markNeedsBuild();
    }

    notifyListeners();
  }

  /// Finalize assistant response by marking it as complete
  void _finalizeAssistantResponse(String responseId) {
    // Find all partial responses with this response ID and mark them as complete
    for (int i = 0; i < _transcript.length; i++) {
      final item = _transcript[i];
      if (item.role == 'assistant' && item.isPartial == true) {
        // We need to create a new TranscriptItem since it's immutable
        _transcript[i] = TranscriptItem(
          role: item.role,
          content: item.content,
          timestamp: item.timestamp,
          id: item.id,
          isPartial: false,
        );
      }
    }

    // Emit full transcript to callback after finalizing responses
    final fullTranscript =
        _transcript.where((item) => item.isPartial != true).toList();
    if (onTranscriptUpdate != null) {
      onTranscriptUpdate!(fullTranscript);
    }

    // Update overlay if it's visible
    if (_conversationOverlay != null) {
      _conversationOverlay!.markNeedsBuild();
    }

    notifyListeners();
  }

  /// Handle call answer
  void _handleCallAnswer() {
    _isCallActive = true;

    // If we were in icon-only connecting mode, show the conversation overlay
    if (_isIconOnlyConnecting) {
      _isIconOnlyConnecting = false;
      showConversationOverlay();
    } else {
      _updateWidgetState(AssistantWidgetState.expanded);
    }

    _updateAgentStatus(
        AgentStatus.idle); // Start idle, let conversation flow control status

    // Set up call quality observation when call is answered
    final call = currentCall;
    if (call != null) {
      _observeCallQuality(call);
    }
  }

  /// Observe call quality metrics for audio visualization
  void _observeCallQuality(Call call) {
    // Set up call quality callback to receive metrics every 100ms
    call.onCallQualityChange = (CallQualityMetrics metrics) {
      _callQualityMetrics = metrics;

      // Store raw audio level
      _inboundAudioLevels.add(metrics.inboundAudioLevel);
      while (_inboundAudioLevels.length > maxAudioLevels) {
        _inboundAudioLevels.removeAt(0);
      }

      // Process audio level for better visualization
      final processedLevel = _processAudioLevel(metrics.inboundAudioLevel);
      _processedAudioLevels.add(processedLevel);
      while (_processedAudioLevels.length > maxAudioLevels) {
        _processedAudioLevels.removeAt(0);
      }

      notifyListeners();
    };
  }

  /// Process raw audio level for better visualization
  double _processAudioLevel(double rawLevel) {
    // Apply noise gate
    if (rawLevel < _noiseGate) {
      return 0.0;
    }

    // Apply sensitivity boost for low levels
    double processed = rawLevel * _audioSensitivity;

    // Apply dynamic range compression using power curve
    processed = math.pow(processed, 0.8).toDouble();

    // Clamp to valid range
    return processed.clamp(0.0, 1.0);
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
  void createConversationOverlay(
      BuildContext context, Widget Function() widgetBuilder) {
    if (_conversationOverlay != null) {
      // Update existing overlay instead of creating a new one
      _conversationOverlay!.markNeedsBuild();
      return;
    }

    _conversationOverlay = OverlayEntry(
      builder: (context) => widgetBuilder(),
    );

    Overlay.of(context).insert(_conversationOverlay!);
  }

  /// Update agent status
  void _updateAgentStatus(AgentStatus newStatus) {
    if (_agentStatus != newStatus) {
      debugPrint('📊 Agent status: $_agentStatus → $newStatus');
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
