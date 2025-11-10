import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import '../models/widget_theme.dart';
import '../models/agent_status.dart';
import 'avatar_widget.dart';
import 'message_content.dart';
import 'compact_call_widget.dart';

/// Widget that displays the conversation transcript
class ConversationView extends StatefulWidget {
  final List<TranscriptItem> transcript;
  final WidgetTheme theme;
  final VoidCallback onClose;
  final Function(String message, {String? base64Image}) onSendMessage;
  final bool isFullScreen;
  final String? avatarUrl;
  final WidgetSettings? settings;
  final AgentStatus agentStatus;
  final bool isMuted;
  final bool isCallActive;
  final List<double> audioLevels;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;
  final OverlayState? overlayState;

  const ConversationView({
    super.key,
    required this.transcript,
    required this.theme,
    required this.onClose,
    required this.onSendMessage,
    this.isFullScreen = false,
    this.avatarUrl,
    required this.settings,
    required this.agentStatus,
    required this.isMuted,
    required this.isCallActive,
    required this.audioLevels,
    required this.onToggleMute,
    required this.onEndCall,
    this.overlayState,
  });

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _selectedImageBase64;

  @override
  void didUpdateWidget(ConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transcript.length != oldWidget.transcript.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(imageBytes);

        setState(() {
          _selectedImage = imageFile;
          _selectedImageBase64 = base64String;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image. Please check permissions and try again.',
              style: TextStyle(color: widget.theme.textColor),
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBase64 = null;
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty || _selectedImageBase64 != null) {
      final messageText = message.isNotEmpty ? message : 'Image attached';
      widget.onSendMessage(messageText, base64Image: _selectedImageBase64);
      _messageController.clear();
      _removeImage();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on theme
    final bool isDarkMode = widget.theme.type == WidgetThemeType.dark ||
        widget.theme.backgroundColor == Colors.black;

    final Color topSectionColor = isDarkMode
        ? const Color(0xFF000000) // Dark mode: black
        : const Color(0xFFFFFDF4); // Light mode: #fffdf4

    final Color bottomSectionColor = isDarkMode
        ? const Color(0xFF38383A) // Dark mode: #38383a
        : const Color(0xFFE3E0CE); // Light mode: #e3e0ce

    final Color textBoxColor = isDarkMode
        ? const Color(0xFF222127) // Dark mode: #222127
        : const Color(0xFFFFFDF4); // Light mode: #fffdf4

    // Filter out only empty messages
    // Deduplicate by ID - keep only the latest version of each message
    final seenIds = <String>{};
    final filteredTranscript = widget.transcript
        .where((item) => item.content.trim().isNotEmpty)
        .toList();

    final displayTranscript = filteredTranscript
        .reversed // Process in reverse to keep the latest version
        .where((item) {
          if (seenIds.contains(item.id)) {
            return false; // Skip duplicate
          }
          seenIds.add(item.id);
          return true;
        })
        .toList()
        .reversed // Reverse back to original order
        .toList();

    Widget content = Column(
      children: [
        // Expanded call widget at the top (takes 40% of the space)
        Expanded(
          flex: 2, // 40% of the space (2 out of 5 total flex)
          child: Container(
            color: topSectionColor,
            child: CompactCallWidget(
              theme: widget.theme,
              settings: widget.settings,
              agentStatus: widget.agentStatus,
              isMuted: widget.isMuted,
              isCallActive: widget.isCallActive,
              audioLevels: widget.audioLevels,
              onClose: widget.onClose,
              onToggleMute: widget.onToggleMute,
              onEndCall: widget.onEndCall,
              isExpanded: true,
              // New parameter to indicate expanded mode
              backgroundColor: topSectionColor,
              overlayState: widget.overlayState,
            ),
          ),
        ),

        // Conversation section (takes 60% of the space with rounded corners and overlap effect)
        Expanded(
          flex: 3, // 60% of the space (3 out of 5 total flex)
          child: Stack(
            children: [
              // Background extension to fill the gap
              Container(
                color: topSectionColor,
                height: 20, // Height of the border radius
              ),
              // Main conversation container with rounded corners
              Container(
                decoration: BoxDecoration(
                  color: bottomSectionColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Transcript
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: displayTranscript.length,
                        itemBuilder: (context, index) {
                          final item = displayTranscript[index];
                          final isUser = item.role == 'user';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  AvatarWidget(
                                    avatarUrl: widget.avatarUrl,
                                    size: 32,
                                    borderRadius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? widget.theme.primaryColor
                                          : widget.theme.buttonColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: MessageContent(
                                      item: item,
                                      isUser: isUser,
                                      theme: widget.theme,
                                    ),
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: widget.theme.buttonColor,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: widget.theme.textColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Message input
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Image preview
                            if (_selectedImage != null) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: textBoxColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: widget.theme.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Image selected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: widget.theme.textColor,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _removeImage,
                                      icon: const Icon(Icons.close, size: 20),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                                        foregroundColor: Colors.red,
                                        minimumSize: const Size(32, 32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Input row
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.image),
                                  style: IconButton.styleFrom(
                                    backgroundColor: widget.theme.buttonColor,
                                    foregroundColor: widget.theme.textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      hintStyle: TextStyle(
                                        color: widget.theme.secondaryTextColor,
                                      ),
                                      filled: true,
                                      fillColor: textBoxColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide(
                                            color: widget.theme.borderColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide(
                                            color: widget.theme.borderColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide(
                                            color: widget.theme.primaryColor),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    style: TextStyle(color: widget.theme.textColor),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _sendMessage,
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: widget.theme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.send,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Wrap in container with decoration only if not in full screen mode
    if (widget.isFullScreen) {
      return content;
    } else {
      return Container(
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.theme.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: content,
      );
    }
  }
}
