# Flutter Telnyx Voice AI Widget

A Flutter widget that provides a standalone voice AI assistant interface using the Telnyx WebRTC SDK.

## Features

- **Configurable Dimensions**: Set custom height and width for the widget
- **Multiple UI States**: 
  - Collapsed (initial state)
  - Connecting (during call setup)
  - Expanded (active call with audio visualizer)
  - Conversation (full transcript view)
- **Agent Status Indicators**: Shows when the agent is thinking or waiting for interruption
- **Audio Visualizer**: Animated bars that respond to call activity
- **Theme Support**: Light and dark theme configurations
- **Call Controls**: Mute/unmute and end call functionality
- **Conversation View**: Full transcript with message history
- **Responsive Design**: Adapts to different screen sizes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_telnyx_voice_ai_widget:
    git:
      url: https://github.com/team-telnyx/flutter-telnyx-voice-ai-widget.git
      ref: main
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TelnyxVoiceAiWidget(
            height: 60,
            width: 300,
            assistantId: 'your-assistant-id',
          ),
        ),
      ),
    );
  }
}
```

### Widget Parameters

- `height` (required): The height of the widget in its collapsed state
- `width` (required): The width of the widget
- `assistantId` (required): The ID of the AI assistant to connect to

### Widget States

The widget automatically transitions between different states:

1. **Loading**: Shows a loading indicator while initializing
2. **Collapsed**: Initial state with assistant avatar and call-to-action text
3. **Connecting**: Shows loading while establishing the call
4. **Expanded**: Active call state with audio visualizer and controls
5. **Conversation**: Full transcript view with message history
6. **Error**: Error state if something goes wrong

### Theming

The widget supports light and dark themes that are automatically applied based on the assistant configuration:

```dart
// Themes are automatically applied based on widget settings
// Light theme: Clean white background with blue accents
// Dark theme: Dark background with purple accents
```

### Audio Visualizer

The widget includes an animated audio visualizer that:
- Shows activity during active calls
- Supports different color schemes (verdant, blue, purple, red)
- Uses rounded bars preset for a modern look
- Responds to call audio activity

### Agent Status

The widget displays different agent statuses:
- **Thinking**: Agent is processing user input
- **Waiting**: Agent is speaking and can be interrupted
- **Idle**: Agent is not active

## Example

See the `example/` directory for a complete example app that demonstrates:
- Multiple widget sizes
- Different configurations
- Interactive assistant ID input
- Usage instructions

To run the example:

```bash
cd example
flutter run
```

## Integration with Telnyx WebRTC SDK

This widget integrates with the Telnyx WebRTC SDK to provide:
- Anonymous login with assistant ID
- WebRTC call management
- Real-time transcript handling
- Audio controls (mute/unmute)
- Call state management

## Requirements

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0.0 or higher
- Telnyx WebRTC SDK access

## Development

### Project Structure

```
lib/
├── src/
│   ├── models/
│   │   ├── agent_status.dart      # Agent status enum
│   │   ├── widget_state.dart      # Widget state enum
│   │   └── widget_theme.dart      # Theme configuration
│   ├── services/
│   │   └── widget_service.dart    # Main service for Telnyx integration
│   ├── widgets/
│   │   ├── audio_visualizer.dart  # Animated audio visualizer
│   │   └── conversation_view.dart # Conversation transcript view
│   └── telnyx_voice_ai_widget.dart # Main widget
└── flutter_telnyx_voice_ai_widget.dart # Library exports
```

### Building

```bash
flutter packages get
flutter analyze
flutter test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the Telnyx development team or create an issue in the repository.
