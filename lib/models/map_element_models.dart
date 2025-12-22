import 'package:flutter/material.dart';
import 'dart:typed_data';

/// Base class for map elements
abstract class MapElement {}

/// Map Zone element
class MapZone extends MapElement {
  String id; // Unique zone ID for linking devices
  String name;
  double x;
  double y;
  double width;
  double height;
  Color color;

  MapZone({
    String? id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  }) : id = id ?? UniqueKey().toString();
}

/// Map Wall element
class MapWall extends MapElement {
  double x1;
  double y1;
  double x2;
  double y2;

  MapWall({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}

/// Map Door element
class MapDoor extends MapElement {
  String name;
  double x;
  double y;
  String? zoneId; // Optional: linked zone
  String? deviceId; // Optional: controller/board ID
  String? macAddress; // Optional: MAC address

  MapDoor({
    required this.name,
    required this.x,
    required this.y,
    this.zoneId,
    this.deviceId,
    this.macAddress,
  });
}

/// Map Anchor element
class MapAnchor extends MapElement {
  String id; // Anchor device ID (match ESP32/UWB board)
  String name;
  double x;
  double y;
  String? zoneId; // Optional: linked zone
  String? deviceId; // Optional: hardware/tag ID for ESP32

  MapAnchor({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.zoneId,
    this.deviceId,
  });
}

/// Map Tag element
class MapTag extends MapElement {
  final String id;
  final String name;
  double x;
  double y;
  final TagType type;
  bool isActive;
  String? zoneId; // Optional: linked zone
  String? deviceId; // Optional: hardware/tag ID for ESP32

  MapTag({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.type,
    this.isActive = true,
    this.zoneId,
    this.deviceId,
  });
}

/// Map Distance Line element
class MapDistanceLine extends MapElement {
  MapZone startZone;
  MapZone endZone;
  String? label;

  MapDistanceLine({
    required this.startZone,
    required this.endZone,
    this.label,
  });

  // Calculate center points of zones
  Offset get startPoint => Offset(
        startZone.x + startZone.width / 2,
        startZone.y + startZone.height / 2,
      );

  Offset get endPoint => Offset(
        endZone.x + endZone.width / 2,
        endZone.y + endZone.height / 2,
      );

  double get distanceInPixels {
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    return (dx * dx + dy * dy).abs();
  }
}

/// Tag Type enum
enum TagType {
  worker(Colors.cyan, Icons.person, 'Worker'),
  vehicle(Colors.orange, Icons.local_shipping, 'Vehicle'),
  equipment(Colors.purple, Icons.precision_manufacturing, 'Equipment'),
  asset(Colors.green, Icons.inventory_2, 'Asset');

  final Color color;
  final IconData icon;
  final String label;

  const TagType(this.color, this.icon, this.label);
}

/// Drawing Mode enum
enum DrawingMode { none, zone, wall, door, anchor, distance }

/// Map Floor element
class MapFloor {
  String id;
  String name;
  List<MapZone> zones;
  List<MapWall> walls;
  List<MapDoor> doors;
  List<MapAnchor> anchors;
  List<MapTag> tags;
  List<MapDistanceLine> distanceLines;
  Uint8List? backgroundImageBytes;
  bool isManualGrid;
  String? backgroundImagePath;
  double backgroundScale;
  Offset backgroundPosition;

  MapFloor({
    required this.id,
    required this.name,
    List<MapZone>? zones,
    List<MapWall>? walls,
    List<MapDoor>? doors,
    List<MapAnchor>? anchors,
    List<MapTag>? tags,
    List<MapDistanceLine>? distanceLines,
    this.backgroundImageBytes,
    this.isManualGrid = true,
    this.backgroundImagePath,
    this.backgroundScale = 1.0,
    Offset? backgroundPosition,
  })  : zones = zones ?? [],
        walls = walls ?? [],
        doors = doors ?? [],
        anchors = anchors ?? [],
        tags = tags ?? [],
        distanceLines = distanceLines ?? [],
        backgroundPosition = backgroundPosition ?? Offset.zero;

  /// Create a copy of this floor
  MapFloor copy() {
    return MapFloor(
      id: id,
      name: name,
      zones: zones
          .map(
            (zone) => MapZone(
              id: zone.id,
              name: zone.name,
              x: zone.x,
              y: zone.y,
              width: zone.width,
              height: zone.height,
              color: zone.color,
            ),
          )
          .toList(),
      walls: walls
          .map(
            (wall) => MapWall(
              x1: wall.x1,
              y1: wall.y1,
              x2: wall.x2,
              y2: wall.y2,
            ),
          )
          .toList(),
      doors: doors
          .map(
            (door) => MapDoor(
              name: door.name,
              x: door.x,
              y: door.y,
              zoneId: door.zoneId,
              deviceId: door.deviceId,
              macAddress: door.macAddress,
            ),
          )
          .toList(),
      anchors: anchors
          .map(
            (anchor) => MapAnchor(
              id: anchor.id,
              name: anchor.name,
              x: anchor.x,
              y: anchor.y,
              zoneId: anchor.zoneId,
            ),
          )
          .toList(),
      tags: tags
          .map(
            (tag) => MapTag(
              id: tag.id,
              name: tag.name,
              x: tag.x,
              y: tag.y,
              type: tag.type,
              isActive: tag.isActive,
              zoneId: tag.zoneId,
              deviceId: tag.deviceId,
            ),
          )
          .toList(),
      distanceLines: distanceLines
          .map(
            (line) => MapDistanceLine(
              startZone: line.startZone,
              endZone: line.endZone,
              label: line.label,
            ),
          )
          .toList(),
      backgroundImageBytes: backgroundImageBytes,
      isManualGrid: isManualGrid,
      backgroundImagePath: backgroundImagePath,
      backgroundScale: backgroundScale,
      backgroundPosition: backgroundPosition,
    );
  }
}
