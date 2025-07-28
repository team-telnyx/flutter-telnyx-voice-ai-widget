import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'models/widget_theme.dart';
import 'models/widget_state.dart';
import 'models/agent_status.dart';
import 'services/widget_service.dart';
import 'widgets/audio_visualizer.dart';
import 'widgets/conversation_overlay.dart';

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

  const TelnyxVoiceAiWidget({
    super.key,
    required this.height,
    required this.width,
    required this.assistantId,
    this.expandedHeight,
    this.expandedWidth,
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
    await _widgetService.initialize(widget.assistantId);
  }

  void _onWidgetServiceChanged() {
    setState(() {
      // Update theme based on widget settings
      final settings = _widgetService.widgetSettings;
      if (settings?.theme != null) {
        _theme = WidgetTheme.fromString(settings!.theme);
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
              );
            });
          });
        }
        
        switch (_widgetService.widgetState) {
          case AssistantWidgetState.loading:
            return _buildLoadingWidget();
          case AssistantWidgetState.collapsed:
            return _buildCollapsedWidget();
          case AssistantWidgetState.connecting:
            return _buildConnectingWidget();
          case AssistantWidgetState.expanded:
            return _buildExpandedWidget();
          case AssistantWidgetState.conversation:
            // This case should no longer be used as we use overlay instead
            return _buildExpandedWidget();
          case AssistantWidgetState.error:
            return _buildErrorWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _theme.backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
        boxShadow: [
          BoxShadow(
            color: _theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_theme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedWidget() {
    final settings = _widgetService.widgetSettings;
    final startCallText = settings?.startCallText?.isNotEmpty == true 
        ? settings!.startCallText! 
        : "Let's chat";

    return GestureDetector(
      onTap: _widgetService.startCall,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _theme.backgroundColor,
          borderRadius: BorderRadius.circular(widget.height / 2),
          border: Border.all(color: _theme.borderColor),
          boxShadow: [
            BoxShadow(
              color: _theme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: widget.height - 16,
                height: widget.height - 16,
                child: settings?.logoIconUrl?.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular((widget.height - 16) / 2),
                        child: Image.network(
                          settings!.logoIconUrl!,
                          width: widget.height - 16,
                          height: widget.height - 16,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
            
            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  startCallText,
                  style: TextStyle(
                    color: _theme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _theme.backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
        border: Border.all(color: _theme.borderColor),
        boxShadow: [
          BoxShadow(
            color: _theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_theme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedWidget() {
    final settings = _widgetService.widgetSettings;
    final speakToInterruptText = settings?.speakToInterruptText?.isNotEmpty == true
        ? settings!.speakToInterruptText!
        : _widgetService.agentStatus.displayText;

    final audioVisualizerConfig = _getAudioVisualizerConfig(settings);
    
    // Use provided expanded dimensions or default to 2x the base size
    final expandedWidth = widget.expandedWidth ?? widget.width;
    final expandedHeight = widget.expandedHeight ?? (widget.height * 2);

    return GestureDetector(
      onTap: () {
        _widgetService.changeWidgetState(AssistantWidgetState.conversation);
      },
      child: Container(
        width: expandedWidth,
        height: expandedHeight,
        decoration: BoxDecoration(
          color: _theme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _theme.borderColor),
          boxShadow: [
            BoxShadow(
              color: _theme.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Audio Visualizer
            Expanded(
              flex: 2,
              child: Center(
                child: AudioVisualizer(
                  color: audioVisualizerConfig['fallbackColor'],
                  gradientName: audioVisualizerConfig['gradientName'],
                  width: expandedWidth - 32,
                  height: 60,
                  preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                  isActive: _widgetService.isCallActive,
                  audioLevels: _widgetService.inboundAudioLevels,
                ),
              ),
            ),
            
            // Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                speakToInterruptText,
                style: TextStyle(
                  color: _theme.secondaryTextColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    onPressed: _widgetService.toggleMute,
                    icon: _widgetService.isMuted ? Icons.mic_off : Icons.mic,
                    backgroundColor: _widgetService.isMuted 
                        ? Colors.red 
                        : _theme.buttonColor,
                    iconColor: _widgetService.isMuted 
                        ? Colors.white 
                        : _theme.textColor,
                  ),
                  
                  // End call button
                  _buildControlButton(
                    onPressed: _widgetService.endCall,
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return SizedBox(
      width: 64,
      height: 64,
      child: IconButton(
        onPressed: onPressed,
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: _theme.borderColor),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }


  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _theme.backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
        border: Border.all(color: Colors.red),
        boxShadow: [
          BoxShadow(
            color: _theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: widget.height / 2,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular((widget.height - 16) / 2),
      child: SvgPicture.asset(
        'assets/images/default_avatar.svg',
        package: 'flutter_telnyx_voice_ai_widget',
        width: widget.height - 16,
        height: widget.height - 16,
        fit: BoxFit.cover,
      ),
    );
  }

  Map<String, dynamic> _getAudioVisualizerConfig(dynamic settings) {
    final colorName = settings?.audioVisualizerConfig?.color?.toLowerCase();
    
    // Check if we have a supported gradient
    const supportedGradients = ['verdant', 'twilight', 'bloom', 'mystic', 'flare', 'glacier'];
    
    if (colorName != null && supportedGradients.contains(colorName)) {
      return {
        'gradientName': colorName,
        'fallbackColor': _getGradientFallbackColor(colorName),
      };
    }
    
    // For non-gradient colors or unsupported ones, use solid colors
    Color fallbackColor;
    switch (colorName) {
      case 'blue':
        fallbackColor = const Color(0xFF3B82F6);
        break;
      case 'purple':  
        fallbackColor = const Color(0xFF8B5CF6);
        break;
      case 'red':
        fallbackColor = const Color(0xFFEF4444);
        break;
      default:
        fallbackColor = _theme.primaryColor;
        break;
    }
    
    return {
      'gradientName': null,
      'fallbackColor': fallbackColor,
    };
  }
  
  Color _getGradientFallbackColor(String gradientName) {
    // Return a representative color for each gradient as fallback
    switch (gradientName) {
      case 'verdant':
        return const Color(0xFF10B981);
      case 'twilight':
        return const Color(0xFF81B9FF);
      case 'bloom':
        return const Color(0xFFFFD4FE);
      case 'mystic':
        return const Color(0xFFCA76FF);
      case 'flare':
        return const Color(0xFFFC5F00);
      case 'glacier':
        return const Color(0xFF4CE5F2);
      default:
        return _theme.primaryColor;
    }
  }
}

