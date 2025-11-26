import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A recorded pointer data that mimics [PointerData] from `dart:ui`.
///
/// This class is package-owned and hides Flutter framework types from the public API.
class RecordedPointerData {
  const RecordedPointerData({
    required this.timeStamp,
    required this.change,
    required this.kind,
    this.signalKind,
    required this.device,
    required this.pointerIdentifier,
    required this.physicalX,
    required this.physicalY,
    required this.physicalDeltaX,
    required this.physicalDeltaY,
    required this.buttons,
    this.obscured = false,
    this.synthesized = false,
    this.pressure = 0.0,
    this.pressureMin = 0.0,
    this.pressureMax = 1.0,
    this.distance = 0.0,
    this.distanceMax = 0.0,
    this.size = 0.0,
    this.radiusMajor = 0.0,
    this.radiusMinor = 0.0,
    this.radiusMin = 0.0,
    this.radiusMax = 0.0,
    this.orientation = 0.0,
    this.tilt = 0.0,
    this.platformData = 0,
    this.scrollDeltaX = 0.0,
    this.scrollDeltaY = 0.0,
  });

  final Duration timeStamp;
  final ui.PointerChange change;
  final ui.PointerDeviceKind kind;
  final ui.PointerSignalKind? signalKind;
  final int device;
  final int pointerIdentifier;
  final double physicalX;
  final double physicalY;
  final double physicalDeltaX;
  final double physicalDeltaY;
  final int buttons;
  final bool obscured;
  final bool synthesized;
  final double pressure;
  final double pressureMin;
  final double pressureMax;
  final double distance;
  final double distanceMax;
  final double size;
  final double radiusMajor;
  final double radiusMinor;
  final double radiusMin;
  final double radiusMax;
  final double orientation;
  final double tilt;
  final int platformData;
  final double scrollDeltaX;
  final double scrollDeltaY;

  /// Creates a [RecordedPointerData] from a Flutter [ui.PointerData].
  factory RecordedPointerData.fromPointerData(ui.PointerData data) {
    return RecordedPointerData(
      timeStamp: data.timeStamp,
      change: data.change,
      kind: data.kind,
      signalKind: data.signalKind,
      device: data.device,
      pointerIdentifier: data.pointerIdentifier,
      physicalX: data.physicalX,
      physicalY: data.physicalY,
      physicalDeltaX: data.physicalDeltaX,
      physicalDeltaY: data.physicalDeltaY,
      buttons: data.buttons,
      obscured: data.obscured,
      synthesized: data.synthesized,
      pressure: data.pressure,
      pressureMin: data.pressureMin,
      pressureMax: data.pressureMax,
      distance: data.distance,
      distanceMax: data.distanceMax,
      size: data.size,
      radiusMajor: data.radiusMajor,
      radiusMinor: data.radiusMinor,
      radiusMin: data.radiusMin,
      radiusMax: data.radiusMax,
      orientation: data.orientation,
      tilt: data.tilt,
      platformData: data.platformData,
      scrollDeltaX: data.scrollDeltaX,
      scrollDeltaY: data.scrollDeltaY,
    );
  }

  /// Converts this [RecordedPointerData] to a Flutter [PointerData].
  ui.PointerData toPointerData() {
    return ui.PointerData(
      timeStamp: timeStamp,
      change: change,
      kind: kind,
      signalKind: signalKind,
      device: device,
      pointerIdentifier: pointerIdentifier,
      physicalX: physicalX,
      physicalY: physicalY,
      physicalDeltaX: physicalDeltaX,
      physicalDeltaY: physicalDeltaY,
      buttons: buttons,
      obscured: obscured,
      synthesized: synthesized,
      pressure: pressure,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      platformData: platformData,
      scrollDeltaX: scrollDeltaX,
      scrollDeltaY: scrollDeltaY,
    );
  }
}

/// A recorded pointer data packet that mimics [ui.PointerDataPacket] from `dart:ui`.
///
/// This class is package-owned and hides Flutter framework types from the public API.
class RecordedPointerDataPacket {
  const RecordedPointerDataPacket(this.data);

  final List<RecordedPointerData> data;

  /// Creates a [RecordedPointerDataPacket] from a Flutter [PointerDataPacket].
  factory RecordedPointerDataPacket.fromPointerDataPacket(
    ui.PointerDataPacket packet,
  ) {
    return RecordedPointerDataPacket(
      packet.data.map(RecordedPointerData.fromPointerData).toList(),
    );
  }

  /// Converts this [RecordedPointerDataPacket] to a Flutter [PointerDataPacket].
  ui.PointerDataPacket toPointerDataPacket() {
    return ui.PointerDataPacket(
      data: data.map((d) => d.toPointerData()).toList(),
    );
  }
}

/// A tuple representing a single event in a recording.
typedef RecordedEvent = ({
  RecordedPointerDataPacket packet,
  Duration timeSincePrevious,
});

/// Represents a complete recording session.
///
/// Contains all events from one recording, along with metadata about the recording device.
class RecordedGestureData {
  const RecordedGestureData({
    required this.events,
    required this.screenSize,
  });

  /// List of all events in this recording session.
  ///
  /// Each event contains a packet and the duration since the previous event.
  /// The first event has `timeSincePrevious` of `Duration.zero`.
  final List<RecordedEvent> events;

  /// Screen size of the device where this recording was made.
  final Size screenSize;

  /// Creates a copy of this [RecordedGestureData] with the given fields replaced.
  RecordedGestureData copyWith({
    List<RecordedEvent>? events,
    Size? screenSize,
  }) {
    return RecordedGestureData(
      events: events ?? this.events,
      screenSize: screenSize ?? this.screenSize,
    );
  }
}
