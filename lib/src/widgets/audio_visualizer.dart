import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Audio visualizer widget that displays animated bars based on real audio data
class AudioVisualizer extends StatefulWidget {
  final Color? color; // Fallback color for backward compatibility
  final String? gradientName; // Name of gradient to use (verdant, twilight, etc.)
  final double height;
  final double width;
  final String preset;
  final bool isActive;
  final List<double> audioLevels;

  const AudioVisualizer({
    super.key,
    this.color,
    this.gradientName,
    this.height = 60,
    this.width = 200,
    this.preset = 'roundBars',
    this.isActive = false,
    this.audioLevels = const [],
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _updateController;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;
  
  final int _barCount = 12;
  final math.Random _random = math.Random();
  
  // Dynamic bar state
  List<double> _barTargets = [];
  List<double> _barCurrents = [];
  List<double> _barPeaks = [];
  List<int> _peakHoldCounters = [];
  
  // Audio processing state
  double _lastAudioLevel = 0.0;
  final List<double> _audioHistory = [];
  
  // Configuration
  static const int _peakHoldFrames = 8; // How long to hold peaks
  static const double _decayRate = 0.85; // How fast bars fall (0.85 = moderate decay)
  static const double _noiseFloor = 0.15; // Minimum activity level
  static const int _historyLength = 5; // Smoothing window
  
  // Gradient definitions matching the TypeScript implementation
  static const Map<String, List<Color>> _gradients = {
    'verdant': [
      Color(0xFFD3FFA6), // Light green
      Color(0xFF036B5B), // Dark teal
      Color(0xFFD3FFA6), // Light green
    ],
    'twilight': [
      Color(0xFF81B9FF), // Light blue
      Color(0xFF371A5E), // Dark purple
      Color(0xFF81B9FF), // Light blue
    ],
    'bloom': [
      Color(0xFFFFD4FE), // Light pink
      Color(0xFFFD05F9), // Bright magenta
      Color(0xFFFFD4FE), // Light pink
    ],
    'mystic': [
      Color(0xFF1F023A), // Dark purple
      Color(0xFFCA76FF), // Light purple
      Color(0xFF1F023A), // Dark purple
    ],
    'flare': [
      Color(0xFFFFFFFF), // White
      Color(0xFFFC5F00), // Orange
      Color(0xFFFFFFFF), // White
    ],
    'glacier': [
      Color(0xFF4CE5F2), // Light cyan
      Color(0xFF005A98), // Dark blue
      Color(0xFF4CE5F2), // Light cyan
    ],
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize bar state arrays
    _barTargets = List.filled(_barCount, _noiseFloor);
    _barCurrents = List.filled(_barCount, _noiseFloor);
    _barPeaks = List.filled(_barCount, _noiseFloor);
    _peakHoldCounters = List.filled(_barCount, 0);
    
    // Main update controller - drives the visualization
    _updateController = AnimationController(
      duration: const Duration(milliseconds: 50), // 20 FPS updates
      vsync: this,
    );
    
    // Individual bar animation controllers for smooth transitions
    _barControllers = List.generate(_barCount, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 100 + _random.nextInt(50)), // Varying speeds
        vsync: this,
      );
    });
    
    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
    // Process new audio data when it changes
    if (widget.audioLevels != oldWidget.audioLevels && widget.audioLevels.isNotEmpty) {
      _processAudioData();
    }
  }

  void _startAnimation() {
    _updateController.repeat();
    for (var controller in _barControllers) {
      controller.forward();
    }
  }

  void _stopAnimation() {
    _updateController.stop();
    for (var controller in _barControllers) {
      controller.reset();
    }
    // Reset all bar states to noise floor
    for (int i = 0; i < _barCount; i++) {
      _barTargets[i] = _noiseFloor;
      _barCurrents[i] = _noiseFloor;
      _barPeaks[i] = _noiseFloor;
      _peakHoldCounters[i] = 0;
    }
  }

  @override
  void dispose() {
    _updateController.dispose();
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Process incoming audio data and update bar targets
  void _processAudioData() {
    if (widget.audioLevels.isEmpty) return;
    
    // Get the latest audio level and smooth it
    final currentLevel = widget.audioLevels.last.clamp(0.0, 1.0);
    _audioHistory.add(currentLevel);
    
    // Keep history limited
    if (_audioHistory.length > _historyLength) {
      _audioHistory.removeAt(0);
    }
    
    // Calculate smoothed audio level
    final smoothedLevel = _audioHistory.reduce((a, b) => a + b) / _audioHistory.length;
    
    // Amplify low levels for better visual response
    final amplifiedLevel = _amplifyAudioLevel(smoothedLevel);
    
    // Update bar targets based on frequency simulation
    _updateBarTargetsFromAudio(amplifiedLevel);
    
    // Update the animation system
    _updateBarAnimations();
  }
  
  /// Amplify low audio levels for better visual response
  double _amplifyAudioLevel(double level) {
    // Apply dynamic range compression and sensitivity boost
    final boosted = math.pow(level, 0.7).toDouble(); // Compress dynamic range
    final amplified = boosted * 1.5; // Boost sensitivity
    return math.min(1.0, amplified);
  }
  
  /// Simulate frequency bands from single audio level
  void _updateBarTargetsFromAudio(double audioLevel) {
    for (int i = 0; i < _barCount; i++) {
      // Create frequency-like response curves
      final frequency = i / (_barCount - 1); // 0.0 to 1.0
      
      // Different frequency bands respond differently
      double response;
      if (frequency < 0.2) {
        // Bass: Strong response, slower decay
        response = audioLevel * (1.2 - frequency * 0.5);
      } else if (frequency < 0.6) {
        // Midrange: Moderate response with some randomness
        response = audioLevel * (0.8 + _random.nextDouble() * 0.4);
      } else {
        // Treble: Sharp response, quick changes
        response = audioLevel * (0.6 + math.sin(DateTime.now().millisecondsSinceEpoch * 0.01 + i) * 0.3);
      }
      
      // Add some random variation for organic feel
      response *= (0.8 + _random.nextDouble() * 0.4);
      
      // Ensure minimum activity and clamp
      _barTargets[i] = math.max(_noiseFloor, math.min(1.0, response));
    }
  }
  
  /// Update bar animations with momentum and decay
  void _updateBarAnimations() {
    for (int i = 0; i < _barCount; i++) {
      final target = _barTargets[i];
      final current = _barCurrents[i];
      
      // Smooth approach to target with momentum
      if (target > current) {
        // Rising: Quick response
        _barCurrents[i] = current + (target - current) * 0.4;
      } else {
        // Falling: Apply decay
        _barCurrents[i] = math.max(_noiseFloor, current * _decayRate);
      }
      
      // Handle peak hold
      if (_barCurrents[i] > _barPeaks[i]) {
        _barPeaks[i] = _barCurrents[i];
        _peakHoldCounters[i] = _peakHoldFrames;
      } else if (_peakHoldCounters[i] > 0) {
        _peakHoldCounters[i]--;
      } else {
        // Peak decay
        _barPeaks[i] = math.max(_noiseFloor, _barPeaks[i] * 0.95);
      }
    }
  }
  
  /// Get current bar height for rendering
  double _getBarHeight(int index) {
    if (!widget.isActive) {
      return widget.height * _noiseFloor;
    }
    
    // Use the smoothed current value
    final normalizedHeight = _barCurrents[index];
    return widget.height * normalizedHeight;
  }
  
  /// Create decoration for bars with gradient or solid color
  BoxDecoration _createBarDecoration(double barWidth) {
    // Check if we have a gradient name and it exists in our definitions
    if (widget.gradientName != null && _gradients.containsKey(widget.gradientName!)) {
      final gradientColors = _gradients[widget.gradientName!]!;
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0], // Matching the TypeScript pos values
        ),
        borderRadius: widget.preset == 'roundBars' 
            ? BorderRadius.circular(barWidth / 2)
            : null,
      );
    }
    
    // Fallback to solid color
    final fallbackColor = widget.color ?? Colors.blue;
    return BoxDecoration(
      color: fallbackColor,
      borderRadius: widget.preset == 'roundBars' 
          ? BorderRadius.circular(barWidth / 2)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          return AnimatedBuilder(
            animation: _updateController,
            builder: (context, child) {
              // Continuously update bars during animation
              if (widget.isActive && widget.audioLevels.isNotEmpty) {
                _updateBarAnimations();
              }
              
              final barHeight = _getBarHeight(index);
              final barWidth = (widget.width / _barCount) * 0.85; // Use 85% of available space per bar
              
              return Container(
                width: barWidth,
                height: barHeight,
                decoration: _createBarDecoration(barWidth),
              );
            },
          );
        }),
      ),
    );
  }
}