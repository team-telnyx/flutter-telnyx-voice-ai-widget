import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import '../models/agent_status.dart';
import 'audio_visualizer.dart';
import 'control_button.dart';

class ExpandedWidget extends StatelessWidget {
  final double width;
  final double height;
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final AgentStatus agentStatus;
  final bool isMuted;
  final bool isCallActive;
  final List<double> audioLevels;
  final VoidCallback onTap;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;

  const ExpandedWidget({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    required this.settings,
    required this.agentStatus,
    required this.isMuted,
    required this.isCallActive,
    required this.audioLevels,
    required this.onTap,
    required this.onToggleMute,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = _getAgentStatusText(settings, agentStatus);
    final audioVisualizerConfig = _getAudioVisualizerConfig(settings);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
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
                  width: width - 32,
                  height: 60,
                  preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                  isActive: isCallActive,
                  audioLevels: audioLevels,
                ),
              ),
            ),
            
            // Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                statusText,
                style: TextStyle(
                  color: theme.secondaryTextColor,
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
                  ControlButton(
                    onPressed: onToggleMute,
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    backgroundColor: isMuted ? Colors.red : theme.buttonColor,
                    iconColor: isMuted ? Colors.white : theme.textColor,
                    theme: theme,
                  ),
                  
                  // End call button
                  ControlButton(
                    onPressed: onEndCall,
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getAudioVisualizerConfig(WidgetSettings? settings) {
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
        fallbackColor = theme.primaryColor;
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
        return theme.primaryColor;
    }
  }
  
  String _getAgentStatusText(WidgetSettings? settings, AgentStatus agentStatus) {
    // Match TypeScript logic: show different text based on agent status
    if (agentStatus == AgentStatus.thinking) {
      // Agent is thinking - show thinking text
      return settings?.agentThinkingText?.isNotEmpty == true
          ? settings!.agentThinkingText!
          : 'Agent is thinking...'; // Default fallback
    } else if (agentStatus == AgentStatus.waiting) {
      // Agent is waiting/can be interrupted - show interrupt text
      return settings?.speakToInterruptText?.isNotEmpty == true
          ? settings!.speakToInterruptText!
          : 'Speak to interrupt'; // Default fallback
    } else if (agentStatus == AgentStatus.processingImage) {
      // Agent is processing an image - show processing text (not overridable)
      return 'Processing image...';
    }
    // Idle state - no text
    return 'Speak to interrupt';
  }
}