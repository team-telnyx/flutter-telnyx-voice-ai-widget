# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter package that provides a standalone voice AI assistant widget using the Telnyx WebRTC SDK. The widget supports multiple UI states (collapsed, connecting, expanded, conversation) with real-time voice interaction and transcript display.

## Development Commands

### Package Management
```bash
flutter packages get        # Install dependencies
flutter packages upgrade    # Update dependencies
```

### Development
```bash
flutter analyze            # Run static analysis
flutter test              # Run tests
```

### Example App
```bash
cd example
flutter run               # Run the demo app
flutter run -d chrome     # Run on web
```

## Architecture

### Core Components

- **TelnyxVoiceAiWidget**: Main widget that manages all UI states and user interactions
- **WidgetService**: Central service that handles Telnyx WebRTC client integration, call management, and state coordination
- **WidgetState**: Enum defining widget states (loading, collapsed, connecting, expanded, conversation, error)
- **WidgetTheme**: Theme system supporting light/dark modes with predefined color schemes

### State Management Flow

The widget follows this state progression:
1. `loading` → `collapsed` (after successful initialization)
2. `collapsed` → `connecting` (user taps to start call)
3. `connecting` → `expanded` (call connects)
4. `expanded` ↔ `conversation` (user can toggle between audio visualizer and transcript)
5. Any state → `error` (on failures)

### Key Integration Points

- **Telnyx WebRTC SDK**: Uses `telnyx_webrtc` package from GitHub (WEBRTC-2889 branch)
- **Anonymous Login**: Connects using assistant ID without user authentication
- **Real-time Updates**: Socket message handling for conversation updates and agent status
- **Transcript Management**: Handles both user and assistant messages with partial response support

### Widget Configuration

Widgets are configured through:
- Required parameters: `height`, `width`, `assistantId`
- Dynamic settings from Telnyx backend: theme, avatar, text labels, audio visualizer config
- Theme automatically switches between light/dark based on backend settings

### Audio Visualizer

- Supports multiple color schemes (verdant, blue, purple, red)
- Uses "roundBars" preset by default
- Responds to call activity state
- Configurable through backend widget settings

### File Structure Patterns

- Models in `lib/src/models/` (enums and data classes)
- Services in `lib/src/services/` (business logic and external integrations)
- UI components in `lib/src/widgets/` (reusable widgets)
- Main widget at `lib/src/telnyx_voice_ai_widget.dart`
- Public exports in `lib/flutter_telnyx_voice_ai_widget.dart`

## Testing Notes

- Current test file is a placeholder with sample calculator test
- Example app in `example/` directory demonstrates widget usage with different sizes
- Widget requires valid assistant ID for full functionality testing