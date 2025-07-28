import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Audio visualizer widget that displays animated bars
class AudioVisualizer extends StatefulWidget {
  final Color color;
  final double height;
  final double width;
  final String preset;
  final bool isActive;

  const AudioVisualizer({
    super.key,
    required this.color,
    this.height = 60,
    this.width = 200,
    this.preset = 'roundBars',
    this.isActive = false,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;
  
  final int _barCount = 20;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _barControllers = List.generate(_barCount, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 200 + _random.nextInt(300)),
        vsync: this,
      );
    });

    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
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
  }

  void _startAnimation() {
    for (var controller in _barControllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimation() {
    for (var controller in _barControllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barCount, (index) {
          return AnimatedBuilder(
            animation: _barAnimations[index],
            builder: (context, child) {
              final barHeight = widget.isActive 
                  ? widget.height * _barAnimations[index].value
                  : widget.height * 0.1;
              
              return Container(
                width: 3,
                height: barHeight,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: widget.preset == 'roundBars' 
                      ? BorderRadius.circular(1.5)
                      : null,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}