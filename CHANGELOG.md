## [1.2.0](https://github.com/team-telnyx/flutter-telnyx-voice-ai-widget/releases/tag/1.2.0) (2026-03-08)

### Enhancement
- Bump `telnyx_webrtc` dependency from `^3.2.0` to `^4.1.0`, incorporating all SDK improvements through version 4.1.0.
- Added `conversationId` parameter to `CallParams`, enabling users to rejoin an existing AI assistant conversation. Pass a valid conversation ID to continue a previous interaction seamlessly.
- Automatic call quality reporting is now enabled by default (handled internally by the SDK). Reports are posted on call end to improve debugging and analytics.
- Improved TURN/STUN server configuration with UDP support for better connectivity.

## [1.1.0](https://github.com/team-telnyx/flutter-voice-commons/releases/tag/1.0.0) (2025-11-19)

### Enhancement
- Added support for widget setting URL parsing, creating an overflow menu for feedback, conversation history, and help links within the Flutter Telnyx Voice AI Widget.
- Bumped Voice SDK version, enhancing call quality and reconnection logic. 
- Added Camera Image Capture support for sending images from device camera to AI assistant during conversations.
- Added support for multiple images to be sent at once in a single conversation message to the AI assistant.
- Added processing_images state, so that users are aware when a pause is caused by image processing during conversations rather than being stuck. 

### Bug Fixes
- General agent state transition fixes (less likely to get stuck in thinking, listening or speaking states)
- Conversation transcript handling improvements (less fragmented text updates)

## [1.0.0](https://github.com/team-telnyx/flutter-voice-commons/releases/tag/1.0.0) (2025-10-29)

### Enhancement
- Initial release of the Flutter Telnyx Voice AI Widget package, allowing easy integration of a voice AI assistant into Flutter applications with multiple UI states and real-time voice interaction.