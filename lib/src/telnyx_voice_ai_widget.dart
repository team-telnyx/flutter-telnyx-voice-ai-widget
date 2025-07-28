import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/widget_theme.dart';
import 'models/widget_state.dart';
import 'models/agent_status.dart';
import 'services/widget_service.dart';
import 'widgets/audio_visualizer.dart';
import 'widgets/conversation_view.dart';

/// Main Telnyx Voice AI Widget
class TelnyxVoiceAiWidget extends StatefulWidget {
  /// Height of the widget
  final double height;
  
  /// Width of the widget
  final double width;
  
  /// Assistant ID to connect to
  final String assistantId;

  const TelnyxVoiceAiWidget({
    super.key,
    required this.height,
    required this.width,
    required this.assistantId,
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
        switch (_widgetService.widgetState) {
          case WidgetState.loading:
            return _buildLoadingWidget();
          case WidgetState.collapsed:
            return _buildCollapsedWidget();
          case WidgetState.connecting:
            return _buildConnectingWidget();
          case WidgetState.expanded:
            return _buildExpandedWidget();
          case WidgetState.conversation:
            return _buildConversationWidget();
          case WidgetState.error:
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
              child: CircleAvatar(
                radius: (widget.height - 16) / 2,
                backgroundColor: _theme.primaryColor,
                backgroundImage: settings?.logoIconUrl?.isNotEmpty == true
                    ? NetworkImage(settings!.logoIconUrl!)
                    : null,
                child: settings?.logoIconUrl?.isEmpty != false
                    ? Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (widget.height - 16) / 3,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
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

    final audioVisualizerColor = _getAudioVisualizerColor(settings);

    return GestureDetector(
      onTap: () {
        _widgetService.changeWidgetState(WidgetState.conversation);
      },
      child: Container(
        width: widget.width,
        height: widget.height * 2, // Expanded height
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
                  color: audioVisualizerColor,
                  width: widget.width - 32,
                  height: 60,
                  preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                  isActive: _widgetService.isCallActive,
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
                  IconButton(
                    onPressed: _widgetService.toggleMute,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _widgetService.isMuted 
                            ? Colors.red 
                            : _theme.buttonColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: _theme.borderColor),
                      ),
                      child: Icon(
                        _widgetService.isMuted ? Icons.mic_off : Icons.mic,
                        color: _widgetService.isMuted 
                            ? Colors.white 
                            : _theme.textColor,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // End call button
                  IconButton(
                    onPressed: _widgetService.endCall,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationWidget() {
    return SizedBox(
      width: widget.width,
      height: widget.height * 3, // Full conversation height
      child: ConversationView(
        transcript: _widgetService.transcript,
        theme: _theme,
        onClose: () {
          _widgetService.changeWidgetState(WidgetState.expanded);
        },
        onSendMessage: _widgetService.sendMessage,
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

  Color _getAudioVisualizerColor(dynamic settings) {
    final colorName = settings?.audioVisualizerConfig?.color;
    switch (colorName?.toLowerCase()) {
      case 'verdant':
        return const Color(0xFF10B981);
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'red':
        return const Color(0xFFEF4444);
      default:
        return _theme.primaryColor;
    }
  }
}

