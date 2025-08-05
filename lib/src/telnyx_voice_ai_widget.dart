import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import 'models/widget_theme.dart';
import 'models/widget_state.dart';
import 'models/logo_icon_settings.dart';
import 'services/widget_service.dart';
import 'widgets/conversation_overlay.dart';
import 'widgets/loading_widget.dart';
import 'widgets/collapsed_widget.dart';
import 'widgets/connecting_widget.dart';
import 'widgets/expanded_widget.dart';
import 'widgets/error_widget.dart';

/// Main Telnyx Voice AI Widget
class TelnyxVoiceAiWidget extends StatefulWidget {
  /// Height of the widget in collapsed state
  final double height;
  
  /// Width of the widget in collapsed state
  final double width;
  
  /// Height of the widget in expanded state
  final double? expandedHeight;
  
  /// Width of the widget in expanded state
  final double? expandedWidth;
  
  /// Assistant ID to connect to
  final String assistantId;
  
  /// Optional text styling for the start call text in collapsed state
  final TextStyle? startCallTextStyling;
  
  /// Optional settings for customizing the logo/avatar icon
  final LogoIconSettings? logoIconSettings;
  
  /// Optional widget settings override that will override server-provided settings
  final WidgetSettings? widgetSettingOverride;

  const TelnyxVoiceAiWidget({
    super.key,
    required this.height,
    required this.width,
    required this.assistantId,
    this.expandedHeight,
    this.expandedWidth,
    this.startCallTextStyling,
    this.logoIconSettings,
    this.widgetSettingOverride,
  });

  @override
  State<TelnyxVoiceAiWidget> createState() => _TelnyxVoiceAiWidgetState();
}

class _TelnyxVoiceAiWidgetState extends State<TelnyxVoiceAiWidget> {
  late final WidgetService _widgetService;
  WidgetTheme _theme = WidgetTheme.light;

  @override
  void initState() {
    super.initState();
    _widgetService = WidgetService();
    _widgetService.addListener(_onWidgetServiceChanged);
    _initializeWidget();
  }

  void _initializeWidget() async {
    await _widgetService.initialize(widget.assistantId, widgetSettingOverride: widget.widgetSettingOverride);
  }

  void _onWidgetServiceChanged() {
    setState(() {
      // Update theme based on widget settings
      final settings = _widgetService.widgetSettings;
      if (settings?.theme != null) {
        _theme = WidgetTheme.fromString(settings!.theme!);
      }
    });
  }

  @override
  void dispose() {
    _widgetService.removeListener(_onWidgetServiceChanged);
    _widgetService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widgetService,
      builder: (context, child) {
        // Handle conversation overlay creation
        if (_widgetService.isConversationVisible && _widgetService.widgetState != AssistantWidgetState.conversation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _widgetService.createConversationOverlay(context, () {
              return ConversationOverlay(
                transcript: _widgetService.transcript,
                theme: _theme,
                onClose: _widgetService.hideConversationOverlay,
                onSendMessage: _widgetService.sendMessage,
                avatarUrl: _widgetService.widgetSettings?.logoIconUrl,
                settings: _widgetService.widgetSettings,
                agentStatus: _widgetService.agentStatus,
                isMuted: _widgetService.isMuted,
                isCallActive: _widgetService.isCallActive,
                audioLevels: _widgetService.inboundAudioLevels,
                onToggleMute: _widgetService.toggleMute,
                onEndCall: _widgetService.endCall,
              );
            });
          });
        }
        
        switch (_widgetService.widgetState) {
          case AssistantWidgetState.loading:
            return LoadingWidget(
              width: widget.width,
              height: widget.height,
              theme: _theme,
            );
          case AssistantWidgetState.collapsed:
            return CollapsedWidget(
              width: widget.width,
              height: widget.height,
              theme: _theme,
              settings: _widgetService.widgetSettings,
              onTap: _widgetService.startCall,
              startCallTextStyling: widget.startCallTextStyling,
              logoIconSettings: widget.logoIconSettings,
            );
          case AssistantWidgetState.connecting:
            return ConnectingWidget(
              width: widget.width,
              height: widget.height,
              theme: _theme,
            );
          case AssistantWidgetState.expanded:
            return ExpandedWidget(
              width: widget.expandedWidth ?? widget.width,
              height: widget.expandedHeight ?? (widget.height * 2),
              theme: _theme,
              settings: _widgetService.widgetSettings,
              agentStatus: _widgetService.agentStatus,
              isMuted: _widgetService.isMuted,
              isCallActive: _widgetService.isCallActive,
              audioLevels: _widgetService.inboundAudioLevels,
              onTap: () => _widgetService.changeWidgetState(AssistantWidgetState.conversation),
              onToggleMute: _widgetService.toggleMute,
              onEndCall: _widgetService.endCall,
            );
          case AssistantWidgetState.conversation:
            // This case should no longer be used as we use overlay instead
            return ExpandedWidget(
              width: widget.expandedWidth ?? widget.width,
              height: widget.expandedHeight ?? (widget.height * 2),
              theme: _theme,
              settings: _widgetService.widgetSettings,
              agentStatus: _widgetService.agentStatus,
              isMuted: _widgetService.isMuted,
              isCallActive: _widgetService.isCallActive,
              audioLevels: _widgetService.inboundAudioLevels,
              onTap: () => _widgetService.changeWidgetState(AssistantWidgetState.conversation),
              onToggleMute: _widgetService.toggleMute,
              onEndCall: _widgetService.endCall,
            );
          case AssistantWidgetState.error:
            return ErrorDisplayWidget(
              width: widget.expandedWidth ?? widget.width,
              height: widget.expandedHeight ?? (widget.height * 2),
              theme: _theme,
              onLaunchUrl: _launchAssistantSettingsUrl,
            );
        }
      },
    );
  }








  /// Launch the Telnyx assistant settings URL
  Future<void> _launchAssistantSettingsUrl() async {
    final assistantId = _widgetService.assistantId;
    if (assistantId == null) return;
    
    final url = 'https://portal.telnyx.com/#/ai/assistants/edit/$assistantId?tab=telephony';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }


}

