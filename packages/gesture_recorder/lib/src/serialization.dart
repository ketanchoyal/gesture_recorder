import 'dart:convert';
import 'dart:ui';

import 'recorded_data.dart';

/// Extension methods for JSON serialization of recorded data types.
extension RecordedPointerDataSerialization on RecordedPointerData {
  /// Converts this [RecordedPointerData] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp.inMicroseconds,
      'change': change.index,
      'kind': kind.index,
      'signalKind': signalKind?.index,
      'device': device,
      'pointerIdentifier': pointerIdentifier,
      'physicalX': physicalX,
      'physicalY': physicalY,
      'physicalDeltaX': physicalDeltaX,
      'physicalDeltaY': physicalDeltaY,
      'buttons': buttons,
      'obscured': obscured,
      'synthesized': synthesized,
      'pressure': pressure,
      'pressureMin': pressureMin,
      'pressureMax': pressureMax,
      'distance': distance,
      'distanceMax': distanceMax,
      'size': size,
      'radiusMajor': radiusMajor,
      'radiusMinor': radiusMinor,
      'radiusMin': radiusMin,
      'radiusMax': radiusMax,
      'orientation': orientation,
      'tilt': tilt,
      'platformData': platformData,
      'scrollDeltaX': scrollDeltaX,
      'scrollDeltaY': scrollDeltaY,
    };
  }

  /// Creates a [RecordedPointerData] from a JSON map.
  static RecordedPointerData fromJson(Map<String, dynamic> json) {
    return RecordedPointerData(
      timeStamp: Duration(microseconds: json['timeStamp'] as int),
      change: PointerChange.values[json['change'] as int],
      kind: PointerDeviceKind.values[json['kind'] as int],
      signalKind: json['signalKind'] != null
          ? PointerSignalKind.values[json['signalKind'] as int]
          : null,
      device: json['device'] as int,
      pointerIdentifier: json['pointerIdentifier'] as int,
      physicalX: (json['physicalX'] as num).toDouble(),
      physicalY: (json['physicalY'] as num).toDouble(),
      physicalDeltaX: (json['physicalDeltaX'] as num).toDouble(),
      physicalDeltaY: (json['physicalDeltaY'] as num).toDouble(),
      buttons: json['buttons'] as int,
      obscured: json['obscured'] as bool? ?? false,
      synthesized: json['synthesized'] as bool? ?? false,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0.0,
      pressureMin: (json['pressureMin'] as num?)?.toDouble() ?? 0.0,
      pressureMax: (json['pressureMax'] as num?)?.toDouble() ?? 1.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      distanceMax: (json['distanceMax'] as num?)?.toDouble() ?? 0.0,
      size: (json['size'] as num?)?.toDouble() ?? 0.0,
      radiusMajor: (json['radiusMajor'] as num?)?.toDouble() ?? 0.0,
      radiusMinor: (json['radiusMinor'] as num?)?.toDouble() ?? 0.0,
      radiusMin: (json['radiusMin'] as num?)?.toDouble() ?? 0.0,
      radiusMax: (json['radiusMax'] as num?)?.toDouble() ?? 0.0,
      orientation: (json['orientation'] as num?)?.toDouble() ?? 0.0,
      tilt: (json['tilt'] as num?)?.toDouble() ?? 0.0,
      platformData: json['platformData'] as int? ?? 0,
      scrollDeltaX: (json['scrollDeltaX'] as num?)?.toDouble() ?? 0.0,
      scrollDeltaY: (json['scrollDeltaY'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Extension methods for JSON serialization of [RecordedPointerDataPacket].
extension RecordedPointerDataPacketSerialization on RecordedPointerDataPacket {
  /// Converts this [RecordedPointerDataPacket] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((d) => d.toJson()).toList(),
    };
  }

  /// Creates a [RecordedPointerDataPacket] from a JSON map.
  static RecordedPointerDataPacket fromJson(Map<String, dynamic> json) {
    return RecordedPointerDataPacket(
      (json['data'] as List)
          .map((item) => RecordedPointerDataSerialization.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

/// Extension methods for JSON serialization of [RecordedGestureData].
extension RecordedGestureDataSerialization on RecordedGestureData {
  /// Converts this [RecordedGestureData] to a JSON map.
  String toJson() {
    return jsonEncode({
      'events': events.map((event) {
        return {
          'packet': event.packet.toJson(),
          'timeSincePrevious': event.timeSincePrevious.inMicroseconds,
        };
      }).toList(),
      'screenSize': {
        'width': screenSize.width,
        'height': screenSize.height,
      },
    });
  }
}

extension RecordedGestureDataDeserialization on String {
  /// Creates a [RecordedGestureData] from a JSON map.
  RecordedGestureData toData() {
    final json = jsonDecode(this) as Map<String, dynamic>;
    final eventsJson = json['events'] as List;
    final events = <RecordedEvent>[];
    for (final eventJson in eventsJson) {
      final eventMap = eventJson as Map<String, dynamic>;
      events.add((
        packet: RecordedPointerDataPacketSerialization.fromJson(
          eventMap['packet'] as Map<String, dynamic>,
        ),
        timeSincePrevious: Duration(
          microseconds: eventMap['timeSincePrevious'] as int,
        ),
      ));
    }

    final screenSizeJson = json['screenSize'] as Map<String, dynamic>;
    final screenSize = Size(
      (screenSizeJson['width'] as num).toDouble(),
      (screenSizeJson['height'] as num).toDouble(),
    );

    return RecordedGestureData(
      events: events,
      screenSize: screenSize,
    );
  }
}
