import 'package:flutter/material.dart';

/// Zone model for geo-fencing
class Zone {
  final String id;
  final String name;
  final List<Offset> polygonCoords; // Polygon coordinates
  final ZoneActionType actionType;
  final int? targetRelay; // Relay number (1 for GPIO35, 2 for GPIO36)
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Zone({
    required this.id,
    required this.name,
    required this.polygonCoords,
    required this.actionType,
    this.targetRelay,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if a point is inside this zone using ray casting algorithm
  bool containsPoint(Offset point) {
    if (polygonCoords.length < 3) return false;

    int intersectCount = 0;
    for (int i = 0; i < polygonCoords.length; i++) {
      Offset p1 = polygonCoords[i];
      Offset p2 = polygonCoords[(i + 1) % polygonCoords.length];

      if (point.dy > (p1.dy < p2.dy ? p1.dy : p2.dy) &&
          point.dy <= (p1.dy > p2.dy ? p1.dy : p2.dy) &&
          point.dx <= (p1.dx > p2.dx ? p1.dx : p2.dx)) {
        double xIntersection =
            (point.dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
        if (p1.dx == p2.dx || point.dx <= xIntersection) {
          intersectCount++;
        }
      }
    }

    return intersectCount.isOdd;
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'polygon_coords': polygonCoords
          .map(
            (offset) => {
              'x': offset.dx,
              'y': offset.dy,
            },
          )
          .toList(),
      'action_type': actionType.name,
      'target_relay': targetRelay,
      'color': color.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Zone.fromJson(Map<String, dynamic> json) {
    List<Offset> coords = [];
    if (json['polygon_coords'] is List) {
      coords = (json['polygon_coords'] as List)
          .map(
            (coord) => Offset(
              (coord['x'] as num).toDouble(),
              (coord['y'] as num).toDouble(),
            ),
          )
          .toList();
    }

    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      polygonCoords: coords,
      actionType: ZoneActionType.values
          .firstWhere((e) => e.name == json['action_type'] as String),
      targetRelay: json['target_relay'] as int?,
      color: Color(json['color'] as int),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Create a copy with updated values
  Zone copyWith({
    String? id,
    String? name,
    List<Offset>? polygonCoords,
    ZoneActionType? actionType,
    int? targetRelay,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      polygonCoords: polygonCoords ?? this.polygonCoords,
      actionType: actionType ?? this.actionType,
      targetRelay: targetRelay ?? this.targetRelay,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Zone action types
enum ZoneActionType {
  forbidden, // Safety zone - triggers Relay 1 (GPIO35)
  accessControl, // Access control zone - triggers Relay 2 (GPIO36)
  monitoring, // Monitoring only - no relay action
}

extension ZoneActionTypeExtension on ZoneActionType {
  String get displayName {
    switch (this) {
      case ZoneActionType.forbidden:
        return 'Forbidden Zone';
      case ZoneActionType.accessControl:
        return 'Access Control';
      case ZoneActionType.monitoring:
        return 'Monitoring Only';
    }
  }

  Color get color {
    switch (this) {
      case ZoneActionType.forbidden:
        return Colors.red;
      case ZoneActionType.accessControl:
        return Colors.orange;
      case ZoneActionType.monitoring:
        return Colors.blue;
    }
  }
}
