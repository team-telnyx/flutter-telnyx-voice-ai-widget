import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import '../models/logo_icon_settings.dart';
import 'avatar_widget.dart';

class IconOnlyWidget extends StatelessWidget {
  final double size;
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final VoidCallback onTap;
  final LogoIconSettings? logoIconSettings;
  final bool isError;

  const IconOnlyWidget({
    super.key,
    required this.size,
    required this.theme,
    required this.settings,
    required this.onTap,
    this.logoIconSettings,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isError ? Colors.red : theme.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isError ? Colors.red.shade700 : theme.borderColor,
            width: logoIconSettings?.borderWidth ?? 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isError
            ? Icon(
                Icons.warning,
                color: Colors.white,
                size: size * 0.6,
              )
            : Padding(
                padding: logoIconSettings?.padding ?? const EdgeInsets.all(8.0),
                child: AvatarWidget(
                  avatarUrl: logoIconSettings?.avatarUrl ?? settings?.logoIconUrl,
                  size: size - 16,
                  borderRadius: logoIconSettings?.borderRadius ?? ((size - 16) / 2),
                  backgroundColor: logoIconSettings?.backgroundColor,
                  borderColor: logoIconSettings?.borderColor,
                  borderWidth: logoIconSettings?.borderWidth,
                  fit: logoIconSettings?.fit,
                ),
              ),
      ),
    );
  }
}