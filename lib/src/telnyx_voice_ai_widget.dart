import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import 'models/widget_theme.dart';
import 'models/widget_state.dart';
import 'models/logo_icon_settings.dart';
import 'models/icon_only_settings.dart';
import 'services/widget_service.dart';
import 'widgets/conversation_overlay.dart';
import 'widgets/loading_widget.dart';
import 'widgets/collapsed_widget.dart';
import 'widgets/connecting_widget.dart';
import 'widgets/expanded_widget.dart';
import 'widgets/error_widget.dart';
import 'widgets/icon_only_widget.dart';
import 'widgets/icon_only_loading_widget.dart';

/// Main Telnyx Voice AI Widget
class TelnyxVoiceAiWidget extends StatefulWidget {
  /// Assistant ID to connect to
  final String assistantId;

  /// Height of the widget in collapsed state (ignored in iconOnly mode)
  final double? height;

  /// Width of the widget in collapsed state (ignored in iconOnly mode)
  final double? width;

  /// Height of the widget in expanded state (ignored in iconOnly mode)
  final double? expandedHeight;

  /// Width of the widget in expanded state (ignored in iconOnly mode)
  final double? expandedWidth;

  /// Optional text styling for the start call text in collapsed state (ignored in iconOnly mode)
  final TextStyle? startCallTextStyling;

  /// Optional settings for customizing the logo/avatar icon
  final LogoIconSettings? logoIconSettings;

  /// Optional widget settings override that will override server-provided settings
  final WidgetSettings? widgetSettingOverride;

  /// Configuration for icon-only mode. When provided, the widget will render as a floating action button-style icon
  final IconOnlySettings? iconOnlySettings;

  /// Optional callback that receives the full conversation transcript (excluding partial messages)
  final void Function(List<TranscriptItem> transcript)? onTranscriptUpdate;

  /// Optional callback that provides access to overlay control functions
  final void Function(VoidCallback hideOverlay, VoidCallback showOverlay)?
      onOverlayControllerReady;

  const TelnyxVoiceAiWidget({
    super.key,
    required this.assistantId,
    this.height,
    this.width,
    this.expandedHeight,
    this.expandedWidth,
    this.startCallTextStyling,
    this.logoIconSettings,
    this.widgetSettingOverride,
    this.iconOnlySettings,
    this.onTranscriptUpdate,
    this.onOverlayControllerReady,
  }) : assert(
          (iconOnlySettings != null) || (height != null && width != null),
          'Either iconOnlySettings must be provided, or both height and width must be provided for regular mode',
        );

  @override
  State<TelnyxVoiceAiWidget> createState() => _TelnyxVoiceAiWidgetState();
}

class _TelnyxVoiceAiWidgetState extends State<TelnyxVoiceAiWidget> {
  late final WidgetService _widgetService;
  WidgetTheme _theme = WidgetTheme.light;

  /// Check if the widget is in icon-only mode
  bool get _isIconOnlyMode => widget.iconOnlySettings != null;

  @override
  void initState() {
    super.initState();
    _widgetService = WidgetService();
    _widgetService.addListener(_onWidgetServiceChanged);
    _initializeWidget();
  }

  void _initializeWidget() async {
    final widgetSettingOverride =
        widget.iconOnlySettings?.widgetSettingOverride ??
            widget.widgetSettingOverride;
    await _widgetService.initialize(widget.assistantId,
        widgetSettingOverride: widgetSettingOverride);

    // Set up transcript callback if provided
    if (widget.onTranscriptUpdate != null) {
      _widgetService.onTranscriptUpdate = (List<TranscriptItem> transcript) {
        widget.onTranscriptUpdate!(transcript);
      };
    }

    // Provide overlay control callbacks if requested
    if (widget.onOverlayControllerReady != null) {
      widget.onOverlayControllerReady!(
        _widgetService.hideConversationOverlay,
        _widgetService.showConversationOverlay,
      );
    }
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

  /// Handle tap in icon-only mode
  void _handleIconOnlyTap() {
    if (_widgetService.widgetState == AssistantWidgetState.error) {
      // Show error dialog instead of overlay
      _showErrorDialog();
    } else {
      // Start call in icon-only mode (will show loading indicator until answered)
      _widgetService.startIconOnlyCall();
    }
  }

  /// Show error dialog for icon-only mode
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: _theme.textColor,
                    ),
                  ),
                ),
                // Error widget content
                Flexible(
                  child: ErrorDisplayWidget(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.5,
                    theme: _theme,
                    onLaunchUrl: _launchAssistantSettingsUrl,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widgetService,
      builder: (context, child) {
        // Handle conversation overlay creation
        if (_widgetService.isConversationVisible &&
            _widgetService.widgetState != AssistantWidgetState.conversation) {
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

        // Handle icon-only mode
        if (_isIconOnlyMode) {
          final iconOnlySettings = widget.iconOnlySettings!;
          final logoIconSettings =
              iconOnlySettings.logoIconSettings ?? widget.logoIconSettings;

          // Show loading widget during initial loading or when connecting
          if (_widgetService.widgetState == AssistantWidgetState.loading ||
              _widgetService.isIconOnlyConnecting) {
            return IconOnlyLoadingWidget(
              size: iconOnlySettings.size,
              theme: _theme,
              logoIconSettings: logoIconSettings,
            );
          }

          return IconOnlyWidget(
            size: iconOnlySettings.size,
            theme: _theme,
            settings: _widgetService.widgetSettings,
            onTap: _handleIconOnlyTap,
            logoIconSettings: logoIconSettings,
            isError: _widgetService.widgetState == AssistantWidgetState.error,
          );
        }

        // Regular mode behavior
        switch (_widgetService.widgetState) {
          case AssistantWidgetState.loading:
            return LoadingWidget(
              width: widget.width!,
              height: widget.height!,
              theme: _theme,
            );
          case AssistantWidgetState.collapsed:
            return CollapsedWidget(
              width: widget.width!,
              height: widget.height!,
              theme: _theme,
              settings: _widgetService.widgetSettings,
              onTap: _widgetService.startCall,
              startCallTextStyling: widget.startCallTextStyling,
              logoIconSettings: widget.logoIconSettings,
            );
          case AssistantWidgetState.connecting:
            return ConnectingWidget(
              width: widget.width!,
              height: widget.height!,
              theme: _theme,
            );
          case AssistantWidgetState.expanded:
            return ExpandedWidget(
              width: widget.expandedWidth ?? widget.width!,
              height: widget.expandedHeight ?? (widget.height! * 2),
              theme: _theme,
              settings: _widgetService.widgetSettings,
              agentStatus: _widgetService.agentStatus,
              isMuted: _widgetService.isMuted,
              isCallActive: _widgetService.isCallActive,
              audioLevels: _widgetService.inboundAudioLevels,
              onTap: () => _widgetService
                  .changeWidgetState(AssistantWidgetState.conversation),
              onToggleMute: _widgetService.toggleMute,
              onEndCall: _widgetService.endCall,
            );
          case AssistantWidgetState.conversation:
            // This case should no longer be used as we use overlay instead
            return ExpandedWidget(
              width: widget.expandedWidth ?? widget.width!,
              height: widget.expandedHeight ?? (widget.height! * 2),
              theme: _theme,
              settings: _widgetService.widgetSettings,
              agentStatus: _widgetService.agentStatus,
              isMuted: _widgetService.isMuted,
              isCallActive: _widgetService.isCallActive,
              audioLevels: _widgetService.inboundAudioLevels,
              onTap: () => _widgetService
                  .changeWidgetState(AssistantWidgetState.conversation),
              onToggleMute: _widgetService.toggleMute,
              onEndCall: _widgetService.endCall,
            );
          case AssistantWidgetState.error:
            return ErrorDisplayWidget(
              width: widget.expandedWidth ?? widget.width!,
              height: widget.expandedHeight ?? (widget.height! * 2),
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

    final url =
        'https://portal.telnyx.com/#/ai/assistants/edit/$assistantId?tab=telephony';

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
