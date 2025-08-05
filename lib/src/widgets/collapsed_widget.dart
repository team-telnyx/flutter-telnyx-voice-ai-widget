import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import '../models/logo_icon_settings.dart';
import 'avatar_widget.dart';

class CollapsedWidget extends StatelessWidget {
  final double width;
  final double height;
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final VoidCallback onTap;
  final TextStyle? startCallTextStyling;
  final LogoIconSettings? logoIconSettings;

  const CollapsedWidget({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    required this.settings,
    required this.onTap,
    this.startCallTextStyling,
    this.logoIconSettings,
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
              padding: logoIconSettings?.padding ?? const EdgeInsets.all(8.0),
              child: AvatarWidget(
                avatarUrl: logoIconSettings?.avatarUrl ?? settings?.logoIconUrl,
                size: logoIconSettings?.size ?? (height - 16),
                borderRadius: logoIconSettings?.borderRadius ?? ((logoIconSettings?.size ?? (height - 16)) / 2),
                backgroundColor: logoIconSettings?.backgroundColor,
                borderColor: logoIconSettings?.borderColor,
                borderWidth: logoIconSettings?.borderWidth,
                fit: logoIconSettings?.fit,
              ),
            ),
            
            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  startCallText,
                  style: startCallTextStyling ?? TextStyle(
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