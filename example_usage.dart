import 'package:flutter/material.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';

/// Example usage of the TelnyxVoiceAiWidget with the new parameters
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TelnyxVoiceAiWidget(
          height: 60,
          width: 200,
          assistantId: 'your-assistant-id',
          expandedHeight: 400,
          expandedWidth: 300,
          
          // New parameter 1: Custom text styling for start call text
          startCallTextStyling: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          
          // New parameter 2: Custom logo/avatar settings
          logoIconSettings: const LogoIconSettings(
            avatarUrl: 'https://example.com/custom-avatar.png',
            size: 50,
            borderRadius: 25,
            backgroundColor: Colors.white,
            borderColor: Colors.blue,
            borderWidth: 2,
            padding: EdgeInsets.all(4),
            fit: BoxFit.cover,
          ),
          
          // New parameter 3: Widget settings override
          widgetSettingOverride: WidgetSettings(
            theme: 'dark',
            startCallText: 'Start Custom Call',
            logoIconUrl: 'https://example.com/override-logo.png',
            // Add other WidgetSettings properties as needed
          ),
        ),
      ),
    );
  }
}