import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import '../models/agent_status.dart';
import 'audio_visualizer.dart';

class CompactCallWidget extends StatelessWidget {
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final AgentStatus agentStatus;
  final bool isMuted;
  final bool isCallActive;
  final List<double> audioLevels;
  final VoidCallback onClose;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;
  final bool isExpanded;
  final Color? backgroundColor;

  const CompactCallWidget({
    super.key,
    required this.theme,
    required this.settings,
    required this.agentStatus,
    required this.isMuted,
    required this.isCallActive,
    required this.audioLevels,
    required this.onClose,
    required this.onToggleMute,
    required this.onEndCall,
    this.isExpanded = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = _getAgentStatusText(settings, agentStatus);
    final audioVisualizerConfig = _getAudioVisualizerConfig(settings);

    if (isExpanded) {
      // Expanded mode - similar to ExpandedWidget layout
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.backgroundColor,
        ),
        child: Column(
          children: [
            // Close button at the top
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  _CompactControlButton(
                    onPressed: onClose,
                    icon: Icons.close,
                    backgroundColor: theme.buttonColor,
                    iconColor: theme.textColor,
                    theme: theme,
                  ),
                ],
              ),
            ),
            
            // Audio Visualizer (prominently in the middle)
            Expanded(
              flex: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: AudioVisualizer(
                      color: audioVisualizerConfig['fallbackColor'],
                      gradientName: audioVisualizerConfig['gradientName'],
                      width: constraints.maxWidth - 64,
                      height: 80,
                      preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                      isActive: isCallActive,
                      audioLevels: audioLevels,
                    ),
                  );
                },
              ),
            ),
            
            // Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                statusText,
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Controls at the bottom
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mute button
                  _ExpandedControlButton(
                    onPressed: onToggleMute,
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    backgroundColor: isMuted ? Colors.red : theme.buttonColor,
                    iconColor: isMuted ? Colors.white : theme.textColor,
                    theme: theme,
                  ),

                  const SizedBox(width: 24),
                  // End call button
                  _ExpandedControlButton(
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
      );
    } else {
      // Compact mode - original layout
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.backgroundColor,
          border: Border(
            bottom: BorderSide(color: theme.borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Close button
            _CompactControlButton(
              onPressed: onClose,
              icon: Icons.close,
              backgroundColor: theme.buttonColor,
              iconColor: theme.textColor,
              theme: theme,
            ),
            const SizedBox(width: 16),
            
            // Audio Visualizer with status text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AudioVisualizer(
                    color: audioVisualizerConfig['fallbackColor'],
                    gradientName: audioVisualizerConfig['gradientName'],
                    width: 120,
                    height: 30,
                    preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                    isActive: isCallActive,
                    audioLevels: audioLevels,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Mute button
            _CompactControlButton(
              onPressed: onToggleMute,
              icon: isMuted ? Icons.mic_off : Icons.mic,
              backgroundColor: isMuted ? Colors.red : theme.buttonColor,
              iconColor: isMuted ? Colors.white : theme.textColor,
              theme: theme,
            ),
            const SizedBox(width: 8),
            
            // End call button
            _CompactControlButton(
              onPressed: onEndCall,
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              theme: theme,
            ),
          ],
        ),
      );
    }
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
    }
    // Idle state - no text
    return 'Speak to interrupt';
  }
}

// Compact version of the control button
class _CompactControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final WidgetTheme theme;

  const _CompactControlButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.borderColor, width: 0.5),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// Expanded version of the control button (larger for expanded mode)
class _ExpandedControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final WidgetTheme theme;

  const _ExpandedControlButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.borderColor, width: 0.5),
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
}