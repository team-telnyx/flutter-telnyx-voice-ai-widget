import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import '../models/agent_status.dart';
import 'conversation_view.dart';

/// Full-screen conversation overlay that appears above everything else
class ConversationOverlay extends StatefulWidget {
  final List<TranscriptItem> transcript;
  final WidgetTheme theme;
  final VoidCallback onClose;
  final Function(String) onSendMessage;
  final String? avatarUrl;
  final WidgetSettings? settings;
  final AgentStatus agentStatus;
  final bool isMuted;
  final bool isCallActive;
  final List<double> audioLevels;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;

  const ConversationOverlay({
    super.key,
    required this.transcript,
    required this.theme,
    required this.onClose,
    required this.onSendMessage,
    this.avatarUrl,
    required this.settings,
    required this.agentStatus,
    required this.isMuted,
    required this.isCallActive,
    required this.audioLevels,
    required this.onToggleMute,
    required this.onEndCall,
  });

  @override
  State<ConversationOverlay> createState() => _ConversationOverlayState();
}

class _ConversationOverlayState extends State<ConversationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate out
    await _animationController.reverse();
    
    // Call the close callback
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Background overlay with fade animation
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                  ),
                ),
              ),
              
              // Main conversation content with slide animation
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.theme.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Conversation content
                          Expanded(
                            child: ConversationView(
                              transcript: widget.transcript,
                              theme: widget.theme,
                              onClose: _close,
                              onSendMessage: widget.onSendMessage,
                              isFullScreen: true,
                              avatarUrl: widget.avatarUrl,
                              settings: widget.settings,
                              agentStatus: widget.agentStatus,
                              isMuted: widget.isMuted,
                              isCallActive: widget.isCallActive,
                              audioLevels: widget.audioLevels,
                              onToggleMute: widget.onToggleMute,
                              onEndCall: widget.onEndCall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}