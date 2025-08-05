import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import 'avatar_widget.dart';

class CollapsedWidget extends StatelessWidget {
  final double width;
  final double height;
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final VoidCallback onTap;

  const CollapsedWidget({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    required this.settings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startCallText = settings?.startCallText?.isNotEmpty == true 
        ? settings!.startCallText! 
        : "Let's chat";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: theme.borderColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
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
              child: AvatarWidget(
                avatarUrl: settings?.logoIconUrl,
                size: height - 16,
                borderRadius: (height - 16) / 2,
              ),
            ),
            
            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  startCallText,
                  style: TextStyle(
                    color: theme.textColor,
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
}