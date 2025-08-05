import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import '../models/widget_theme.dart';
import 'avatar_widget.dart';
import 'message_content.dart';

/// Widget that displays the conversation transcript
class ConversationView extends StatefulWidget {
  final List<TranscriptItem> transcript;
  final WidgetTheme theme;
  final VoidCallback onClose;
  final Function(String) onSendMessage;
  final bool isFullScreen;
  final String? avatarUrl;

  const ConversationView({
    super.key,
    required this.transcript,
    required this.theme,
    required this.onClose,
    required this.onSendMessage,
    this.isFullScreen = false,
    this.avatarUrl,
  });

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transcript.length != oldWidget.transcript.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        // Header (only show when not in full screen mode)
        if (!widget.isFullScreen)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: widget.theme.borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Conversation',
                  style: TextStyle(
                    color: widget.theme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close,
                    color: widget.theme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

        // Transcript
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.transcript.length,
            itemBuilder: (context, index) {
              final item = widget.transcript[index];
              final isUser = item.role == 'user';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      AvatarWidget(
                        avatarUrl: widget.avatarUrl,
                        size: 32,
                        borderRadius: 16,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isUser
                                  ? widget.theme.primaryColor
                                  : widget.theme.buttonColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MessageContent(
                          item: item,
                          isUser: isUser,
                          theme: widget.theme,
                        ),
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: widget.theme.buttonColor,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: widget.theme.textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Message input
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: widget.theme.borderColor, width: 1),
              ),
            ),
            child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: widget.theme.secondaryTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: widget.theme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: widget.theme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: widget.theme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: TextStyle(color: widget.theme.textColor),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendMessage,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
      ],
    );

    // Wrap in container with decoration only if not in full screen mode
    if (widget.isFullScreen) {
      return content;
    } else {
      return Container(
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.theme.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: content,
      );
    }
  }



}
