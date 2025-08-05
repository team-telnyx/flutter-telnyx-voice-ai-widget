import 'package:flutter/material.dart';

/// Settings for customizing the logo/avatar icon in the widget
class LogoIconSettings {
  /// Custom avatar URL to override the default
  final String? avatarUrl;
  
  /// Size of the avatar icon
  final double? size;
  
  /// Border radius for the avatar
  final double? borderRadius;
  
  /// Background color for the avatar container
  final Color? backgroundColor;
  
  /// Border color for the avatar
  final Color? borderColor;
  
  /// Border width for the avatar
  final double? borderWidth;
  
  /// Padding around the avatar
  final EdgeInsets? padding;
  
  /// Box fit for the avatar image
  final BoxFit? fit;

  const LogoIconSettings({
    this.avatarUrl,
    this.size,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.fit,
  });

  /// Create a copy of this LogoIconSettings with some fields replaced
  LogoIconSettings copyWith({
    String? avatarUrl,
    double? size,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    EdgeInsets? padding,
    BoxFit? fit,
  }) {
    return LogoIconSettings(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      padding: padding ?? this.padding,
      fit: fit ?? this.fit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LogoIconSettings &&
        other.avatarUrl == avatarUrl &&
        other.size == size &&
        other.borderRadius == borderRadius &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding &&
        other.fit == fit;
  }

  @override
  int get hashCode {
    return Object.hash(
      avatarUrl,
      size,
      borderRadius,
      backgroundColor,
      borderColor,
      borderWidth,
      padding,
      fit,
    );
  }

  @override
  String toString() {
    return 'LogoIconSettings('
        'avatarUrl: $avatarUrl, '
        'size: $size, '
        'borderRadius: $borderRadius, '
        'backgroundColor: $backgroundColor, '
        'borderColor: $borderColor, '
        'borderWidth: $borderWidth, '
        'padding: $padding, '
        'fit: $fit'
        ')';
  }
}