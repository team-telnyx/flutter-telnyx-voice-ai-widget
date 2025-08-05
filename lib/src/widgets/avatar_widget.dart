import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final double borderRadius;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.size,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        ),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SvgPicture.asset(
        'assets/images/default_avatar.svg',
        package: 'flutter_telnyx_voice_ai_widget',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}