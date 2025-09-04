# Flutter Telnyx Voice AI Widget

A Flutter widget that provides a standalone voice AI assistant interface using the Telnyx WebRTC SDK.

## Features

- **Configurable Dimensions**: Set custom height and width for the widget
- **Icon-Only Mode**: Floating action button-style interface for minimal UI footprint
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

#### Regular Mode

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

#### Icon-Only Mode

```dart
import 'package:flutter/material.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: TelnyxVoiceAiWidget(
          assistantId: 'your-assistant-id',
          iconOnlySettings: IconOnlySettings(
            size: 56.0,
            logoIconSettings: LogoIconSettings(
              size: 40.0,
              borderRadius: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
```

### Widget Parameters

#### Regular Mode Parameters
- `height` (required for regular mode): The height of the widget in its collapsed state
- `width` (required for regular mode): The width of the widget
- `assistantId` (required): The ID of the AI assistant to connect to
- `expandedHeight` (optional): The height of the widget in its expanded state
- `expandedWidth` (optional): The width of the widget in its expanded state
- `startCallTextStyling` (optional): Text styling for the start call text in collapsed state
- `logoIconSettings` (optional): Settings for customizing the logo/avatar icon
- `widgetSettingOverride` (optional): Widget settings override

#### Icon-Only Mode Parameters
- `assistantId` (required): The ID of the AI assistant to connect to
- `iconOnlySettings` (required for icon-only mode): Configuration for icon-only mode
  - `size` (required): Size of the circular icon widget
  - `logoIconSettings` (optional): Settings for customizing the logo/avatar icon
  - `widgetSettingOverride` (optional): Widget settings override

### Widget States

#### Regular Mode States
The widget automatically transitions between different states:

1. **Loading**: Shows a loading indicator while initializing
2. **Collapsed**: Initial state with assistant avatar and call-to-action text
3. **Connecting**: Shows loading while establishing the call
4. **Expanded**: Active call state with audio visualizer and controls
5. **Conversation**: Full transcript view with message history
6. **Error**: Error state if something goes wrong

#### Icon-Only Mode Behavior
In icon-only mode, the widget behavior is simplified:

1. **Loading**: Shows a loading indicator in circular form
2. **Normal State**: Shows the icon in a circular container with theme-based background
3. **Connecting State**: Shows a loading indicator while establishing the call connection
4. **Error State**: Shows a red warning icon in a circular container
5. **Call Flow**: Tapping the icon shows a loading indicator until the call is answered, then opens the conversation overlay
6. **Error Handling**: Tapping the error icon opens an error dialog instead of an overlay

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
│   │   ├── agent_status.dart        # Agent status enum (idle, thinking, waiting)
│   │   ├── widget_state.dart        # Widget state enum
│   │   ├── widget_theme.dart        # Theme configuration (light/dark)
│   │   ├── logo_icon_settings.dart  # Logo/avatar customization settings
│   │   └── icon_only_settings.dart  # Icon-only mode configuration
│   ├── services/
│   │   └── widget_service.dart      # Main service for Telnyx WebRTC integration
│   ├── widgets/
│   │   ├── audio_visualizer.dart    # Animated audio visualizer with gradients
│   │   ├── avatar_widget.dart       # Reusable avatar display component
│   │   ├── collapsed_widget.dart    # Regular mode collapsed state
│   │   ├── compact_call_widget.dart # Compact call controls for conversation view
│   │   ├── connecting_widget.dart   # Connection loading state
│   │   ├── control_button.dart      # Reusable control button component
│   │   ├── conversation_view.dart   # Full transcript view with compact controls
│   │   ├── error_display_widget.dart # Error state display
│   │   ├── expanded_widget.dart     # Regular mode expanded state with visualizer
│   │   ├── icon_only_widget.dart    # Icon-only mode implementation
│   │   ├── loading_widget.dart      # Initial loading state
│   │   └── message_content.dart     # Message bubble content renderer
│   └── telnyx_voice_ai_widget.dart  # Main widget controller
└── flutter_telnyx_voice_ai_widget.dart # Public API exports
```

### Key Components

#### Regular Mode Flow
1. **LoadingWidget**: Shows loading indicator during initialization
2. **CollapsedWidget**: Displays avatar and call-to-action text
3. **ConnectingWidget**: Shows connection progress
4. **ExpandedWidget**: Active call with audio visualizer and controls
5. **ConversationView**: Full transcript with CompactCallWidget header

#### Icon-Only Mode Flow
1. **IconOnlyWidget**: Circular FAB-style button
2. On tap: Shows loading indicator
3. On connect: Opens full-screen conversation overlay
4. On error: Shows red warning icon, tap for error dialog

#### Conversation View Features
- **CompactCallWidget**: Horizontal header with close button, mini visualizer, status text, and call controls
- **Transcript Display**: Scrollable message history with user/assistant bubbles
- **Message Input**: Text field for sending messages during conversation
- **Auto-scroll**: Automatically scrolls to latest messages

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
