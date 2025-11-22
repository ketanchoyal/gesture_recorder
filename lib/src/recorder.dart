import 'dart:ui';

import 'package:flutter/material.dart';

/// A tuple of [PointerDataPacket] and [DateTime] when the packet was captured.
typedef CapturedPointerData = ({PointerDataPacket packet, DateTime timestamp});

/// The state of the gesture recorder.
enum RecordState { none, recording, playing }

/// A widget that records all the gesture events happening during recording.
///
/// [GestureRecorder] captures all the gesture events reported by the platform and
/// expose [List<CapturedPointerData>] as a result of recording.
///
/// [GestureRecorder] must be placed at the root (or almost root) of the widget tree
/// so that its descendant can call [start], [stop], and [replay] methods
/// by finding [GestureRecorder] as the result of traversing [BuildContext].
///
/// Once the value of [List<CapturedPointerData>] is obtained by [stop] method,
/// you can replay the recorded events by calling [replay] method with passing the value as-is.
class GestureRecorder extends StatefulWidget {
  const GestureRecorder({super.key, required this.child});

  /// The child widget.
  final Widget child;

  /// Returns the current state of the gesture recorder.
  /// Once the state changes, the dependent widgets are rebuilt.
  static RecordState stateOf(BuildContext context) {
    final state =
        context.dependOnInheritedWidgetOfExactType<_GestureRecorderScope>();
    assert(
      state != null,
      'GestureRecorder must be used within a GestureRecorder',
    );
    return state!.state;
  }

  static _GestureRecorderState _of(BuildContext context) {
    final state = context.findAncestorStateOfType<_GestureRecorderState>();
    assert(
      state != null,
      'GestureRecorder must be used within a GestureRecorder',
    );
    return state!;
  }

  /// Starts recording gesture events.
  static void start(BuildContext context) async {
    _of(context)._start();
  }

  /// Stops recording gesture events and returns the recorded event data.
  static Future<List<CapturedPointerData>> stop(BuildContext context) async {
    return _of(context)._stop();
  }

  /// Replays the recorded gesture events.
  /// [pointerHistory] is typically obtained by [stop] method.
  static Future<void> replay(
    BuildContext context,
    List<CapturedPointerData> pointerHistory,
  ) async {
    return _of(context)._replay(pointerHistory);
  }

  /// Creates [_GestureRecorderState] instance for Flutter framework.
  @override
  State<GestureRecorder> createState() => _GestureRecorderState();
}

/// The state of the gesture recorder.
/// This operates a recording and replaying of gesture events.
class _GestureRecorderState extends State<GestureRecorder> {
  final List<CapturedPointerData> _pointerData = [];
  void Function()? _restoreFunc;
  RecordState _state = RecordState.none;

  void _start() {
    final dispatcher = PlatformDispatcher.instance.onPointerDataPacket;
    if (dispatcher != null) {
      setState(() {
        _state = RecordState.recording;
      });

      void wrappedFunc(PointerDataPacket packet) {
        _pointerData.add((packet: packet, timestamp: DateTime.now()));
        dispatcher(packet);
      }

      PlatformDispatcher.instance.onPointerDataPacket = wrappedFunc;
      _restoreFunc =
          () => PlatformDispatcher.instance.onPointerDataPacket = dispatcher;
    }
  }

  List<CapturedPointerData> _stop() {
    setState(() {
      _state = RecordState.none;
    });

    if (_restoreFunc != null) {
      _restoreFunc!();
      _restoreFunc = null;
    }
    final copied = [..._pointerData];
    _pointerData.clear();
    return copied;
  }

  Future<void> _replay(List<CapturedPointerData> pointerHistory) async {
    final dispatcher = PlatformDispatcher.instance.onPointerDataPacket;
    if (dispatcher == null) {
      return;
    }

    setState(() {
      _state = RecordState.playing;
    });

    DateTime? previousTime;
    for (final historyItem in pointerHistory) {
      if (previousTime != null) {
        final delay = historyItem.timestamp.difference(previousTime);
        if (delay.inMicroseconds > 0) {
          await Future.delayed(delay);
        }
      }
      dispatcher(historyItem.packet);
      previousTime = historyItem.timestamp;
    }

    setState(() {
      _state = RecordState.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _GestureRecorderScope(state: _state, child: widget.child);
  }
}

/// An [InheritedWidget] that provides the current state of the gesture recorder.
class _GestureRecorderScope extends InheritedWidget {
  const _GestureRecorderScope({required super.child, required this.state});

  final RecordState state;

  @override
  bool updateShouldNotify(_GestureRecorderScope oldWidget) {
    return state != oldWidget.state;
  }
}
