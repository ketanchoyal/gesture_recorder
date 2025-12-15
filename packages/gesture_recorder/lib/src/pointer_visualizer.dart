import 'package:flutter/material.dart';

/// Controller for managing pointer visualization state without widget rebuilds
class PointerVisualizerController extends ChangeNotifier {
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  void enable() {
    if (!_isEnabled) {
      _isEnabled = true;
      notifyListeners();
    }
  }

  void disable() {
    if (_isEnabled) {
      _isEnabled = false;
      notifyListeners();
    }
  }

  void setEnabled(bool enabled) {
    if (_isEnabled != enabled) {
      _isEnabled = enabled;
      notifyListeners();
    }
  }
}

/// Visualizes pointer interactions on screen with customizable markers
///
/// This widget overlays visual markers on pointer events, making them visible
/// during video recordings, screencasts, presentations, or integration tests.
/// Useful for demonstrating user interactions in demos and tutorials.
class PointerVisualizer extends StatefulWidget {
  /// The widget tree on which to display pointer markers
  final Widget child;

  /// The diameter of each pointer marker
  final double markerSize;

  /// The color scheme for pointer markers
  final Color markerColor;

  /// Custom widget to display instead of the default marker.
  ///
  /// Ensure [markerSize] is set appropriately to align the custom widget
  final Widget? customMarker;

  /// Controller for managing visualization state
  final PointerVisualizerController controller;

  /// The text direction for positioning markers
  ///
  /// Only used if [GestureRecorder] is passed before MaterialApp or CupertinoApp
  final TextDirection textDirection;

  /// Creates a pointer visualization overlay
  ///
  /// Visual markers appear at pointer contact points on the [child] widget
  const PointerVisualizer({
    super.key,
    required this.child,
    this.customMarker,
    this.markerSize = 25.0,
    this.markerColor = Colors.grey,
    required this.controller,
    this.textDirection = TextDirection.ltr,
  });

  @override
  _PointerVisualizerState createState() => _PointerVisualizerState();
}

class _PointerVisualizerState extends State<PointerVisualizer>
    with SingleTickerProviderStateMixin {
  final Map<int, Offset> activePointers = <int, Offset>{};
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late final Key _key;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.controller.isEnabled;
    _key = UniqueKey();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    if (_isEnabled) {
      _glowController.repeat(reverse: true);
    }
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final newEnabled = widget.controller.isEnabled;
    if (newEnabled != _isEnabled) {
      setState(() {
        _isEnabled = newEnabled;
      });
      if (_isEnabled) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
      }
    }
  }

  @override
  void didUpdateWidget(PointerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _isEnabled = widget.controller.isEnabled;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _glowController.dispose();
    super.dispose();
  }

  Widget _buildEdgeGradient() {
    const edgeWidth = 40.0;
    const glowColor = Color(0xFF0066FF); // Vibrant blue

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final intensity = 0.5 + (_glowAnimation.value * 0.3);

        return IgnorePointer(
          child: Stack(
            children: [
              // Top edge gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: edgeWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        glowColor.withValues(alpha: intensity),
                        glowColor.withValues(alpha: intensity * 0.5),
                        glowColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Bottom edge gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: edgeWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        glowColor.withValues(alpha: intensity),
                        glowColor.withValues(alpha: intensity * 0.5),
                        glowColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Left edge gradient
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: edgeWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        glowColor.withValues(alpha: intensity),
                        glowColor.withValues(alpha: intensity * 0.5),
                        glowColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Right edge gradient
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: edgeWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        glowColor.withValues(alpha: intensity),
                        glowColor.withValues(alpha: intensity * 0.5),
                        glowColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Iterable<Widget> _buildPointerMarkers() sync* {
    if (activePointers.isNotEmpty) {
      for (var pointerLocation in activePointers.values) {
        yield Positioned.directional(
          start: pointerLocation.dx - widget.markerSize / 2,
          top: pointerLocation.dy - widget.markerSize / 2,
          textDirection:
              Directionality.maybeOf(context) ?? widget.textDirection,
          child: widget.customMarker != null
              ? widget.customMarker!
              : Container(
                  width: widget.markerSize,
                  height: widget.markerSize,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 1.5,
                      color: widget.markerColor,
                    ),
                  ),
                ),
        );
      }
    }
  }

  void updatePointerPosition(int pointerId, Offset position) {
    setState(() {
      activePointers[pointerId] = position;
    });
  }

  void removePointerPosition(int pointerId) {
    setState(() {
      activePointers.remove(pointerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final layeredWidgets = [
      KeyedSubtree(key: _key, child: widget.child),
      if (_isEnabled) ...[
        _buildEdgeGradient(),
        ..._buildPointerMarkers(),
      ]
    ];
    return Listener(
      onPointerDown: _isEnabled
          ? (event) {
              updatePointerPosition(event.pointer, event.position);
            }
          : null,
      onPointerMove: _isEnabled
          ? (event) {
              updatePointerPosition(event.pointer, event.position);
            }
          : null,
      onPointerCancel: _isEnabled
          ? (event) {
              removePointerPosition(event.pointer);
            }
          : null,
      onPointerUp: _isEnabled
          ? (event) {
              removePointerPosition(event.pointer);
            }
          : null,
      child: Directionality(
        textDirection: Directionality.maybeOf(context) ?? widget.textDirection,
        child: Stack(
          children: layeredWidgets,
        ),
      ),
    );
  }
}
