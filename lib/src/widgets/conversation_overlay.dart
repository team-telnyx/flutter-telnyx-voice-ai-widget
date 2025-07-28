import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import '../models/widget_theme.dart';
import 'conversation_view.dart';

/// Full-screen conversation overlay that appears above everything else
class ConversationOverlay extends StatefulWidget {
  final List<TranscriptItem> transcript;
  final WidgetTheme theme;
  final VoidCallback onClose;
  final Function(String) onSendMessage;

  const ConversationOverlay({
    super.key,
    required this.transcript,
    required this.theme,
    required this.onClose,
    required this.onSendMessage,
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
                          // Handle bar
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: widget.theme.borderColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          
                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Conversation',
                                  style: TextStyle(
                                    color: widget.theme.textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _close,
                                  icon: Icon(
                                    Icons.close,
                                    color: widget.theme.textColor,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Divider(height: 1),
                          
                          // Conversation content
                          Expanded(
                            child: ConversationView(
                              transcript: widget.transcript,
                              theme: widget.theme,
                              onClose: _close,
                              onSendMessage: widget.onSendMessage,
                              isFullScreen: true,
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