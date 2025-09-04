# Telnyx Voice AI Widget Example

This example demonstrates how to use the Flutter Telnyx Voice AI Widget in both regular and icon-only modes.

## Features

The example app provides:
- **Interactive Configuration**: Adjust widget dimensions and mode in real-time
- **Mode Selection**: Toggle between regular mode and icon-only (FAB-style) mode
- **Live Preview**: See the configured widget immediately after creation
- **Dimension Controls**: Set custom width, height, and expanded dimensions
- **Permissions Handling**: Automatic microphone permission request

## Running the Example

```bash
cd example
flutter run
```

## Usage

1. Enter your Telnyx Assistant ID
2. Choose between Regular or Icon-Only mode:
   - **Regular Mode**: Configure width, height, and optional expanded dimensions
   - **Icon-Only Mode**: Configure the icon size for a floating action button style
3. Click "Create Widget" to display the voice AI assistant
4. Tap the widget to start a voice conversation

## Requirements

- Valid Telnyx Assistant ID
- Microphone permissions (requested automatically)
- Active internet connection