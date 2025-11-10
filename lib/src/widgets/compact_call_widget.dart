import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/telnyx_webrtc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/widget_theme.dart';
import '../models/agent_status.dart';
import 'audio_visualizer.dart';

class CompactCallWidget extends StatelessWidget {
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final AgentStatus agentStatus;
  final bool isMuted;
  final bool isCallActive;
  final List<double> audioLevels;
  final VoidCallback onClose;
  final VoidCallback onToggleMute;
  final VoidCallback onEndCall;
  final bool isExpanded;
  final Color? backgroundColor;
  final OverlayState? overlayState;

  const CompactCallWidget({
    super.key,
    required this.theme,
    required this.settings,
    required this.agentStatus,
    required this.isMuted,
    required this.isCallActive,
    required this.audioLevels,
    required this.onClose,
    required this.onToggleMute,
    required this.onEndCall,
    this.isExpanded = false,
    this.backgroundColor,
    this.overlayState,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = _getAgentStatusText(settings, agentStatus);
    final audioVisualizerConfig = _getAudioVisualizerConfig(settings);

    if (isExpanded) {
      // Expanded mode - similar to ExpandedWidget layout
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.backgroundColor,
        ),
        child: Column(
          children: [
            // Close button and overflow menu at the top
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Overflow menu (only show if URLs are available)
                  if (_hasMenuUrls(settings))
                    _OverflowMenuButton(
                      theme: theme,
                      settings: settings,
                      overlayState: overlayState,
                    ),
                  const Spacer(),
                  _CompactControlButton(
                    onPressed: onClose,
                    icon: Icons.close,
                    backgroundColor: theme.buttonColor,
                    iconColor: theme.textColor,
                    theme: theme,
                  ),
                ],
              ),
            ),
            
            // Audio Visualizer (prominently in the middle)
            Expanded(
              flex: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: AudioVisualizer(
                      color: audioVisualizerConfig['fallbackColor'],
                      gradientName: audioVisualizerConfig['gradientName'],
                      width: constraints.maxWidth - 64,
                      height: 80,
                      preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                      isActive: isCallActive,
                      audioLevels: audioLevels,
                    ),
                  );
                },
              ),
            ),
            
            // Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                statusText,
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Controls at the bottom
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mute button
                  _ExpandedControlButton(
                    onPressed: onToggleMute,
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    backgroundColor: isMuted ? Colors.red : theme.buttonColor,
                    iconColor: isMuted ? Colors.white : theme.textColor,
                    theme: theme,
                  ),

                  const SizedBox(width: 24),
                  // End call button
                  _ExpandedControlButton(
                    onPressed: onEndCall,
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Compact mode - original layout
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.backgroundColor,
          border: Border(
            bottom: BorderSide(color: theme.borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Close button
            _CompactControlButton(
              onPressed: onClose,
              icon: Icons.close,
              backgroundColor: theme.buttonColor,
              iconColor: theme.textColor,
              theme: theme,
            ),
            const SizedBox(width: 16),
            
            // Audio Visualizer with status text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AudioVisualizer(
                    color: audioVisualizerConfig['fallbackColor'],
                    gradientName: audioVisualizerConfig['gradientName'],
                    width: 120,
                    height: 30,
                    preset: settings?.audioVisualizerConfig?.preset ?? 'roundBars',
                    isActive: isCallActive,
                    audioLevels: audioLevels,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Mute button
            _CompactControlButton(
              onPressed: onToggleMute,
              icon: isMuted ? Icons.mic_off : Icons.mic,
              backgroundColor: isMuted ? Colors.red : theme.buttonColor,
              iconColor: isMuted ? Colors.white : theme.textColor,
              theme: theme,
            ),
            const SizedBox(width: 8),
            
            // End call button
            _CompactControlButton(
              onPressed: onEndCall,
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              theme: theme,
            ),
          ],
        ),
      );
    }
  }

  Map<String, dynamic> _getAudioVisualizerConfig(WidgetSettings? settings) {
    final colorName = settings?.audioVisualizerConfig?.color?.toLowerCase();
    
    // Check if we have a supported gradient
    const supportedGradients = ['verdant', 'twilight', 'bloom', 'mystic', 'flare', 'glacier'];
    
    if (colorName != null && supportedGradients.contains(colorName)) {
      return {
        'gradientName': colorName,
        'fallbackColor': _getGradientFallbackColor(colorName),
      };
    }
    
    // For non-gradient colors or unsupported ones, use solid colors
    Color fallbackColor;
    switch (colorName) {
      case 'blue':
        fallbackColor = const Color(0xFF3B82F6);
        break;
      case 'purple':  
        fallbackColor = const Color(0xFF8B5CF6);
        break;
      case 'red':
        fallbackColor = const Color(0xFFEF4444);
        break;
      default:
        fallbackColor = theme.primaryColor;
        break;
    }
    
    return {
      'gradientName': null,
      'fallbackColor': fallbackColor,
    };
  }
  
  Color _getGradientFallbackColor(String gradientName) {
    // Return a representative color for each gradient as fallback
    switch (gradientName) {
      case 'verdant':
        return const Color(0xFF10B981);
      case 'twilight':
        return const Color(0xFF81B9FF);
      case 'bloom':
        return const Color(0xFFFFD4FE);
      case 'mystic':
        return const Color(0xFFCA76FF);
      case 'flare':
        return const Color(0xFFFC5F00);
      case 'glacier':
        return const Color(0xFF4CE5F2);
      default:
        return theme.primaryColor;
    }
  }
  
  String _getAgentStatusText(WidgetSettings? settings, AgentStatus agentStatus) {
    // Match TypeScript logic: show different text based on agent status
    if (agentStatus == AgentStatus.thinking) {
      // Agent is thinking - show thinking text
      return settings?.agentThinkingText?.isNotEmpty == true
          ? settings!.agentThinkingText!
          : 'Agent is thinking...'; // Default fallback
    } else if (agentStatus == AgentStatus.waiting) {
      // Agent is waiting/can be interrupted - show interrupt text
      return settings?.speakToInterruptText?.isNotEmpty == true
          ? settings!.speakToInterruptText!
          : 'Speak to interrupt'; // Default fallback
    }
    // Idle state - no text
    return 'Speak to interrupt';
  }

  /// Check if any menu URLs are available
  bool _hasMenuUrls(WidgetSettings? settings) {
    if (settings == null) return false;
    return (settings.giveFeedbackUrl?.isNotEmpty == true) ||
           (settings.reportIssueUrl?.isNotEmpty == true) ||
           (settings.viewHistoryUrl?.isNotEmpty == true);
  }
}

// Compact version of the control button
class _CompactControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final WidgetTheme theme;

  const _CompactControlButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.borderColor, width: 0.5),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// Expanded version of the control button (larger for expanded mode)
class _ExpandedControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final WidgetTheme theme;

  const _ExpandedControlButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: theme.borderColor, width: 0.5),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Overflow menu button with state management to prevent multiple menus
class _OverflowMenuButton extends StatefulWidget {
  final WidgetTheme theme;
  final WidgetSettings? settings;
  final OverlayState? overlayState;

  const _OverflowMenuButton({
    required this.theme,
    required this.settings,
    this.overlayState,
  });

  @override
  State<_OverflowMenuButton> createState() => _OverflowMenuButtonState();
}

class _OverflowMenuButtonState extends State<_OverflowMenuButton> {
  bool _isMenuOpen = false;
  OverlayEntry? _menuOverlayEntry;

  /// Show the overflow menu with available options
  Future<void> _showOverflowMenuWithAnchor(BuildContext anchorContext) async {
    // If overlayState is provided, use manual OverlayEntry for proper z-ordering
    if (widget.overlayState != null) {
      return _showCustomOverlayMenu(anchorContext);
    }

    // Otherwise fall back to standard showMenu
    // Prevent opening multiple menus
    if (_isMenuOpen) return;
    if (widget.settings == null) return;

    setState(() {
      _isMenuOpen = true;
    });

    try {
      final List<PopupMenuEntry<String>> menuItems = [];

      // Add Give Feedback option
      if (widget.settings!.giveFeedbackUrl?.isNotEmpty == true) {
        menuItems.add(
          PopupMenuItem<String>(
            value: 'give_feedback',
            child: Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  color: widget.theme.textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Give Feedback',
                  style: TextStyle(color: widget.theme.textColor),
                ),
              ],
            ),
          ),
        );
      }

      // Add View History option
      if (widget.settings!.viewHistoryUrl?.isNotEmpty == true) {
        menuItems.add(
          PopupMenuItem<String>(
            value: 'view_history',
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: widget.theme.textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'View History',
                  style: TextStyle(color: widget.theme.textColor),
                ),
              ],
            ),
          ),
        );
      }

      // Add Report Issue option
      if (widget.settings!.reportIssueUrl?.isNotEmpty == true) {
        menuItems.add(
          PopupMenuItem<String>(
            value: 'report_issue',
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: widget.theme.textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Report Issue',
                  style: TextStyle(color: widget.theme.textColor),
                ),
              ],
            ),
          ),
        );
      }

      if (menuItems.isEmpty) {
        setState(() {
          _isMenuOpen = false;
        });
        return;
      }

      // Get the render box for positioning relative to the button
      final RenderBox renderBox = anchorContext.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      // Use root navigator context to show menu above everything (including overlays)
      if (!mounted) return;

      // Get the root navigator context
      final BuildContext rootContext = Navigator.of(anchorContext, rootNavigator: true).context;

      final String? value = await showMenu<String>(
        context: rootContext,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + renderBox.size.height, // Position below the button
          offset.dx + renderBox.size.width,
          offset.dy + renderBox.size.height,
        ),
        color: widget.theme.backgroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: widget.theme.borderColor),
        ),
        items: menuItems,
      );

      if (value != null) {
        _handleMenuAction(value);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMenuOpen = false;
        });
      }
    }
  }

  /// Show menu using manual OverlayEntry for proper z-ordering
  void _showCustomOverlayMenu(BuildContext anchorContext) {
    // Prevent opening multiple menus
    if (_isMenuOpen) return;
    if (widget.settings == null) return;
    if (widget.overlayState == null) return;

    setState(() {
      _isMenuOpen = true;
    });

    // Get the render box for positioning
    final RenderBox renderBox = anchorContext.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Build menu items
    final List<Widget> menuItems = [];

    if (widget.settings!.giveFeedbackUrl?.isNotEmpty == true) {
      menuItems.add(
        _buildMenuItem(
          icon: Icons.thumb_up,
          label: 'Give Feedback',
          onTap: () {
            _closeCustomMenu();
            _handleMenuAction('give_feedback');
          },
        ),
      );
    }

    if (widget.settings!.viewHistoryUrl?.isNotEmpty == true) {
      menuItems.add(
        _buildMenuItem(
          icon: Icons.history,
          label: 'View History',
          onTap: () {
            _closeCustomMenu();
            _handleMenuAction('view_history');
          },
        ),
      );
    }

    if (widget.settings!.reportIssueUrl?.isNotEmpty == true) {
      menuItems.add(
        _buildMenuItem(
          icon: Icons.warning,
          label: 'Report Issue',
          onTap: () {
            _closeCustomMenu();
            _handleMenuAction('report_issue');
          },
        ),
      );
    }

    if (menuItems.isEmpty) {
      setState(() {
        _isMenuOpen = false;
      });
      return;
    }

    // Create the overlay entry
    _menuOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to close menu when tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeCustomMenu,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          // The actual menu
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 8,
            child: Material(
              color: widget.theme.backgroundColor,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: widget.theme.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: menuItems,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Insert the overlay entry at the top level
    widget.overlayState!.insert(_menuOverlayEntry!);
  }

  /// Build a menu item widget
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: widget.theme.textColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: widget.theme.textColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Close the custom overlay menu
  void _closeCustomMenu() {
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
    if (mounted) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  void dispose() {
    // Don't call setState during dispose
    _menuOverlayEntry?.remove();
    _menuOverlayEntry = null;
    _isMenuOpen = false;
    super.dispose();
  }

  /// Handle menu action selection
  void _handleMenuAction(String action) {
    String? url;

    switch (action) {
      case 'give_feedback':
        url = widget.settings?.giveFeedbackUrl;
        break;
      case 'view_history':
        url = widget.settings?.viewHistoryUrl;
        break;
      case 'report_issue':
        url = widget.settings?.reportIssueUrl;
        break;
    }

    if (url?.isNotEmpty == true) {
      _launchUrl(url!);
    }
  }

  /// Launch URL in external browser
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Try to launch with external application mode first
      bool launched = false;

      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Failed to launch with external application mode: $e');
      }

      // If that fails, try with platform default mode
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          debugPrint('Failed to launch with platform default mode: $e');
        }
      }

      if (!launched) {
        debugPrint('Could not launch URL: $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Builder to get the proper anchor context
    return Builder(
      builder: (BuildContext anchorContext) {
        return _CompactControlButton(
          onPressed: () => _showOverflowMenuWithAnchor(anchorContext),
          icon: Icons.more_vert,
          backgroundColor: widget.theme.buttonColor,
          iconColor: widget.theme.textColor,
          theme: widget.theme,
        );
      },
    );
  }
}