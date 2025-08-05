import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BoxFit? fit;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.size,
    required this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;
    
    if (avatarUrl?.isNotEmpty == true) {
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        ),
      );
    } else {
      avatarContent = _buildDefaultAvatar();
    }

    // Wrap with container for background color and border if specified
    if (backgroundColor != null || borderColor != null || borderWidth != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null && borderWidth != null
              ? Border.all(color: borderColor!, width: borderWidth!)
              : null,
        ),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildDefaultAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SvgPicture.asset(
        'assets/images/default_avatar.svg',
        package: 'flutter_telnyx_voice_ai_widget',
        width: size,
        height: size,
        fit: fit ?? BoxFit.cover,
      ),
    );
  }
}