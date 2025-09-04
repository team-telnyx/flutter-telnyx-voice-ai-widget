import 'package:flutter/material.dart';
import 'logo_icon_settings.dart';

/// Configuration for icon-only mode of the TelnyxVoiceAiWidget
/// In this mode, the widget appears as a floating action button-style icon
class IconOnlySettings {
  /// Size of the circular icon widget
  final double size;
  
  /// Settings for customizing the logo/avatar icon
  final LogoIconSettings? logoIconSettings;
  
  /// Optional widget settings override that will override server-provided settings
  final dynamic widgetSettingOverride;

  const IconOnlySettings({
    required this.size,
    this.logoIconSettings,
    this.widgetSettingOverride,
  });

  /// Create a copy of this IconOnlySettings with some fields replaced
  IconOnlySettings copyWith({
    double? size,
    LogoIconSettings? logoIconSettings,
    dynamic widgetSettingOverride,
  }) {
    return IconOnlySettings(
      size: size ?? this.size,
      logoIconSettings: logoIconSettings ?? this.logoIconSettings,
      widgetSettingOverride: widgetSettingOverride ?? this.widgetSettingOverride,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is IconOnlySettings &&
        other.size == size &&
        other.logoIconSettings == logoIconSettings &&
        other.widgetSettingOverride == widgetSettingOverride;
  }

  @override
  int get hashCode {
    return Object.hash(
      size,
      logoIconSettings,
      widgetSettingOverride,
    );
  }

  @override
  String toString() {
    return 'IconOnlySettings('
        'size: $size, '
        'logoIconSettings: $logoIconSettings, '
        'widgetSettingOverride: $widgetSettingOverride'
        ')';
  }
}