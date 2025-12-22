import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../models/floor_plan.dart';
import '../models/map_element_models.dart';
import '../utils/helpers.dart';

/// Floor Plan Service for handling floor plan operations
class FloorPlanService {
  static FloorPlanService? _instance;

  FloorPlanService._();

  /// Get singleton instance
  static FloorPlanService get instance {
    _instance ??= FloorPlanService._();
    return _instance!;
  }

  /// Load floor plan image from file
  Future<Uint8List?> loadFloorPlanImage(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      print('Failed to load floor plan image: $e');
      return null;
    }
  }

  /// Load floor plan image from asset
  Future<Uint8List?> loadFloorPlanAsset(String assetPath) async {
    try {
      return await rootBundle
          .load(assetPath)
          .then((bytes) => bytes.buffer.asUint8List());
    } catch (e) {
      print('Failed to load floor plan asset: $e');
      return null;
    }
  }

  /// Calculate dimensions in meters from image size and pixels per meter
  (double, double) calculateDimensionsMeters(
    Size imageSize,
    double pixelsPerMeter,
  ) {
    return (
      imageSize.width / pixelsPerMeter,
      imageSize.height / pixelsPerMeter
    );
  }

  /// Calculate pixels per meter from two points and real distance
  double calculatePixelsPerMeter(
    Offset point1,
    Offset point2,
    double realDistanceMeters,
  ) {
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;
    final pixelDistance = sqrt(dx * dx + dy * dy);
    return pixelDistance / realDistanceMeters;
  }

  /// Scale anchor positions from image coordinates to real world coordinates
  MapAnchor scaleAnchorToRealWorld(
    MapAnchor anchor,
    double pixelsPerMeter,
    Offset imageOrigin,
  ) {
    return MapAnchor(
      id: anchor.id,
      name: anchor.name,
      x: (anchor.x - imageOrigin.dx) / pixelsPerMeter,
      y: (anchor.y - imageOrigin.dy) / pixelsPerMeter,
    );
  }

  /// Scale anchor positions from real world coordinates to image coordinates
  MapAnchor scaleAnchorToImage(
    MapAnchor anchor,
    double pixelsPerMeter,
    Offset imageOrigin,
  ) {
    return MapAnchor(
      id: anchor.id,
      name: anchor.name,
      x: anchor.x * pixelsPerMeter + imageOrigin.dx,
      y: anchor.y * pixelsPerMeter + imageOrigin.dy,
    );
  }

  /// Calculate anchor position relative to another anchor
  MapAnchor calculateRelativeAnchorPosition(
    MapAnchor referenceAnchor,
    double distanceMeters,
    double angleDegrees,
    double pixelsPerMeter,
  ) {
    final angleRadians = angleDegrees * (3.14159 / 180);
    final deltaX = distanceMeters * pixelsPerMeter * cos(angleRadians);
    final deltaY = distanceMeters * pixelsPerMeter * sin(angleRadians);

    return MapAnchor(
      id: Helpers.generateUuid(),
      name: 'Relative Anchor',
      x: referenceAnchor.x + deltaX,
      y: referenceAnchor.y + deltaY,
    );
  }

  /// Create floor plan from image and calibration data
  FloorPlan createFloorPlanFromImage(
    String name,
    Uint8List imageBytes,
    Offset calibrationPoint1,
    Offset calibrationPoint2,
    double realDistanceMeters,
  ) {
    // Decode image to get dimensions
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate pixels per meter
    final pixelsPerMeter = calculatePixelsPerMeter(
      calibrationPoint1,
      calibrationPoint2,
      realDistanceMeters,
    );

    // Calculate dimensions in meters
    final (widthMeters, heightMeters) = calculateDimensionsMeters(
      Size(image.width.toDouble(), image.height.toDouble()),
      pixelsPerMeter,
    );

    return FloorPlan(
      id: Helpers.generateUuid(),
      name: name,
      imageBytes: imageBytes,
      widthMeters: widthMeters,
      heightMeters: heightMeters,
      pixelsPerMeter: pixelsPerMeter,
      imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      createdAt: DateTime.now(),
    );
  }
}
