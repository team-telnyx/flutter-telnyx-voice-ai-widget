import 'package:flutter/material.dart';
import '../models/widget_theme.dart';
import '../models/logo_icon_settings.dart';

class IconOnlyLoadingWidget extends StatelessWidget {
  final double size;
  final WidgetTheme theme;
  final LogoIconSettings? logoIconSettings;

  const IconOnlyLoadingWidget({
    super.key,
    required this.size,
    required this.theme,
    this.logoIconSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.borderColor,
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
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      ),
    );
  }
}