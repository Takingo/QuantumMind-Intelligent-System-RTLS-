import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Floor Plan Model
class FloorPlan {
  final String id;
  final String name;
  final Uint8List? imageBytes;
  final String? imagePath;
  final double widthMeters;
  final double heightMeters;
  final double pixelsPerMeter;
  final Size imageSize;
  final List<MeasurementPoint> calibrationPoints;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FloorPlan({
    required this.id,
    required this.name,
    this.imageBytes,
    this.imagePath,
    required this.widthMeters,
    required this.heightMeters,
    required this.pixelsPerMeter,
    required this.imageSize,
    List<MeasurementPoint>? calibrationPoints,
    required this.createdAt,
    this.updatedAt,
  }) : calibrationPoints = calibrationPoints ?? [];

  /// Create FloorPlan from JSON
  factory FloorPlan.fromJson(Map<String, dynamic> json) {
    return FloorPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      widthMeters: (json['width_meters'] as num).toDouble(),
      heightMeters: (json['height_meters'] as num).toDouble(),
      pixelsPerMeter: (json['pixels_per_meter'] as num).toDouble(),
      imageSize: Size(
        (json['image_width'] as num).toDouble(),
        (json['image_height'] as num).toDouble(),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert FloorPlan to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'width_meters': widthMeters,
      'height_meters': heightMeters,
      'pixels_per_meter': pixelsPerMeter,
      'image_width': imageSize.width,
      'image_height': imageSize.height,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Calculate pixels per meter from calibration points
  static double calculatePixelsPerMeter(
    Offset point1,
    Offset point2,
    double realDistanceMeters,
  ) {
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;
    final pixelDistance = sqrt(dx * dx + dy * dy);
    return pixelDistance / realDistanceMeters;
  }

  /// Copy with method
  FloorPlan copyWith({
    String? id,
    String? name,
    Uint8List? imageBytes,
    String? imagePath,
    double? widthMeters,
    double? heightMeters,
    double? pixelsPerMeter,
    Size? imageSize,
    List<MeasurementPoint>? calibrationPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FloorPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      imageBytes: imageBytes ?? this.imageBytes,
      imagePath: imagePath ?? this.imagePath,
      widthMeters: widthMeters ?? this.widthMeters,
      heightMeters: heightMeters ?? this.heightMeters,
      pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
      imageSize: imageSize ?? this.imageSize,
      calibrationPoints: calibrationPoints ?? List.from(this.calibrationPoints),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Measurement Point for calibration
class MeasurementPoint {
  final String id;
  final String floorPlanId;
  final Offset imagePosition;
  final double realX;
  final double realY;
  final DateTime createdAt;

  MeasurementPoint({
    required this.id,
    required this.floorPlanId,
    required this.imagePosition,
    required this.realX,
    required this.realY,
    required this.createdAt,
  });

  /// Create MeasurementPoint from JSON
  factory MeasurementPoint.fromJson(Map<String, dynamic> json) {
    return MeasurementPoint(
      id: json['id'] as String,
      floorPlanId: json['floor_plan_id'] as String,
      imagePosition: Offset(
        (json['image_x'] as num).toDouble(),
        (json['image_y'] as num).toDouble(),
      ),
      realX: (json['real_x'] as num).toDouble(),
      realY: (json['real_y'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert MeasurementPoint to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor_plan_id': floorPlanId,
      'image_x': imagePosition.dx,
      'image_y': imagePosition.dy,
      'real_x': realX,
      'real_y': realY,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
