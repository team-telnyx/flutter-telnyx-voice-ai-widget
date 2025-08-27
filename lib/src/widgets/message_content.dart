import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import '../models/widget_theme.dart';

class MessageContent extends StatelessWidget {
  final TranscriptItem item;
  final bool isUser;
  final WidgetTheme theme;

  const MessageContent({
    super.key,
    required this.item,
    required this.isUser,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Always show the message content, whether partial or complete
    return Text(
      item.content,
      style: TextStyle(
        // Slightly reduce opacity for partial messages to indicate they're still being received
        color: (isUser ? Colors.white : theme.textColor).withOpacity(
          item.isPartial == true ? 0.8 : 1.0,
        ),
        fontSize: 14,
      ),
    );
  }
}