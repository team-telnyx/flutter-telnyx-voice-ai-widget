import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import '../models/widget_theme.dart';
import 'typing_indicator.dart';

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
    // Show typing indicator for partial assistant messages
    if (!isUser && item.isPartial == true) {
      return TypingIndicator(
        dotColor: theme.textColor,
        dotSize: 6,
        spacing: 3,
      );
    }

    // Show regular text for all other messages
    return Text(
      item.content,
      style: TextStyle(
        color: isUser ? Colors.white : theme.textColor,
        fontSize: 14,
      ),
    );
  }
}