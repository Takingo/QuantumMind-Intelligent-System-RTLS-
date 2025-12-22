import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/rtls_provider.dart';

/// Mixin for integrating real-time MQTT data into RTLS Map
/// Usage: Add this mixin to _AdvancedRtlsMapScreenState
mixin RtlsRealtimeIntegration<T extends StatefulWidget> on State<T> {
  Timer? _positionUpdateTimer;
  StreamSubscription? _rtlsSubscription;

  /// Map scale for coordinate conversion (pixels per meter)
  /// Override this in your state class
  double get mapScalePixelsPerMeter => 40.0; // 1 meter = 40 pixels default

  /// Real-time tag positions: tagId -> Offset(x, y) in pixels
  final Map<String, Offset> realtimeTagPositions = {};

  /// Real-time door statuses: doorId -> DoorState
  final Map<String, DoorState> realtimeDoorStatuses = {};

  /// Initialize real-time integration
  void initializeRealtimeIntegration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rtls = context.read<RtlsProvider>();

      // Initialize MQTT if not connected
      if (!rtls.isConnected) {
        rtls.initialize();
      }

      // Start periodic position updates
      _positionUpdateTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _updateRealtimePositions(),
      );
    });
  }

  /// Update real-time positions from provider
  void _updateRealtimePositions() {
    if (!mounted) return;

    final rtls = context.read<RtlsProvider>();

    // Update tag positions
    for (var entry in rtls.tagPositions.entries) {
      final tagId = entry.key;
      final position = entry.value;

      // Convert real-world coordinates (meters) to pixels
      final pixelX = position.x * mapScalePixelsPerMeter;
      final pixelY = position.y * mapScalePixelsPerMeter;

      realtimeTagPositions[tagId] = Offset(pixelX, pixelY);
    }

    // Update door statuses
    for (var entry in rtls.doorStatuses.entries) {
      realtimeDoorStatuses[entry.key] = entry.value.status;
    }

    // Trigger rebuild if there are updates
    if (realtimeTagPositions.isNotEmpty || realtimeDoorStatuses.isNotEmpty) {
      setState(() {});
    }
  }

  /// Get realtime position for a tag
  Offset? getRealtimeTagPosition(String tagId) {
    return realtimeTagPositions[tagId];
  }

  /// Get realtime door status
  DoorState? getRealtimeDoorStatus(String doorId) {
    return realtimeDoorStatuses[doorId];
  }

  /// Get color for door based on real-time status
  Color getDoorStatusColor(String doorId) {
    final status = realtimeDoorStatuses[doorId];
    if (status == null) return Colors.brown; // Default

    switch (status) {
      case DoorState.open:
        return const Color(0xFF00FFC6); // Green
      case DoorState.closed:
        return Colors.grey;
      case DoorState.locked:
        return Colors.redAccent;
      case DoorState.opening:
        return Colors.orange;
      case DoorState.closing:
        return Colors.amber;
      case DoorState.unknown:
        return Colors.brown;
    }
  }

  /// Dispose real-time integration
  void disposeRealtimeIntegration() {
    _positionUpdateTimer?.cancel();
    _rtlsSubscription?.cancel();
  }
}

/// Calibration Overlay Widget
/// Allows users to align floor plan with real-world coordinates
class CalibrationOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(CalibrationPoints) onSave;
  final CalibrationPoints? existingPoints;

  const CalibrationOverlay({
    super.key,
    required this.onClose,
    required this.onSave,
    this.existingPoints,
  });

  @override
  State<CalibrationOverlay> createState() => _CalibrationOverlayState();
}

class _CalibrationOverlayState extends State<CalibrationOverlay> {
  Offset? _point1;
  Offset? _point2;
  final TextEditingController _x1Controller = TextEditingController();
  final TextEditingController _y1Controller = TextEditingController();
  final TextEditingController _x2Controller = TextEditingController();
  final TextEditingController _y2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPoints != null) {
      _point1 = widget.existingPoints!.screenPoint1;
      _point2 = widget.existingPoints!.screenPoint2;
      _x1Controller.text = widget.existingPoints!.realPoint1.dx.toString();
      _y1Controller.text = widget.existingPoints!.realPoint1.dy.toString();
      _x2Controller.text = widget.existingPoints!.realPoint2.dx.toString();
      _y2Controller.text = widget.existingPoints!.realPoint2.dy.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: GestureDetector(
              onTapDown: (details) {
                if (_point1 == null) {
                  setState(() => _point1 = details.localPosition);
                } else if (_point2 == null) {
                  setState(() => _point2 = details.localPosition);
                }
              },
              child: CustomPaint(
                painter: _CalibrationPainter(_point1, _point2),
              ),
            ),
          ),
        ),

        // Control panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.straighten, color: Color(0xFF00FFC6)),
                    const SizedBox(width: 12),
                    const Text(
                      'Map Calibration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Tap two known points on the map\n2. Enter their real-world coordinates (meters)',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Point 1 inputs
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Point 1:',
                        style: TextStyle(color: Colors.white),),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _x1Controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'X (m)',
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _y1Controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Y (m)',
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Point 2 inputs
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Point 2:',
                        style: TextStyle(color: Colors.white),),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _x2Controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'X (m)',
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _y2Controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Y (m)',
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _reset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canSave() ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFC6),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Save Calibration'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _canSave() {
    return _point1 != null &&
        _point2 != null &&
        _x1Controller.text.isNotEmpty &&
        _y1Controller.text.isNotEmpty &&
        _x2Controller.text.isNotEmpty &&
        _y2Controller.text.isNotEmpty;
  }

  void _reset() {
    setState(() {
      _point1 = null;
      _point2 = null;
      _x1Controller.clear();
      _y1Controller.clear();
      _x2Controller.clear();
      _y2Controller.clear();
    });
  }

  void _save() {
    final realPoint1 = Offset(
      double.parse(_x1Controller.text),
      double.parse(_y1Controller.text),
    );
    final realPoint2 = Offset(
      double.parse(_x2Controller.text),
      double.parse(_y2Controller.text),
    );

    final calibration = CalibrationPoints(
      screenPoint1: _point1!,
      screenPoint2: _point2!,
      realPoint1: realPoint1,
      realPoint2: realPoint2,
    );

    widget.onSave(calibration);
  }

  @override
  void dispose() {
    _x1Controller.dispose();
    _y1Controller.dispose();
    _x2Controller.dispose();
    _y2Controller.dispose();
    super.dispose();
  }
}

class _CalibrationPainter extends CustomPainter {
  final Offset? point1;
  final Offset? point2;

  _CalibrationPainter(this.point1, this.point2);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw line between points
    if (point1 != null && point2 != null) {
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(point1!, point2!, paint);
    }

    // Draw point 1
    if (point1 != null) {
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point1!, 10, paint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(point1!, 10, borderPaint);
    }

    // Draw point 2
    if (point2 != null) {
      final paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point2!, 10, paint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(point2!, 10, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Calibration Points Model
class CalibrationPoints {
  final Offset screenPoint1; // Pixel coordinates
  final Offset screenPoint2;
  final Offset realPoint1; // Real-world coordinates (meters)
  final Offset realPoint2;

  CalibrationPoints({
    required this.screenPoint1,
    required this.screenPoint2,
    required this.realPoint1,
    required this.realPoint2,
  });

  /// Calculate scale factor (pixels per meter)
  double get scaleX {
    final screenDx = (screenPoint2.dx - screenPoint1.dx).abs();
    final realDx = (realPoint2.dx - realPoint1.dx).abs();
    return screenDx / realDx;
  }

  double get scaleY {
    final screenDy = (screenPoint2.dy - screenPoint1.dy).abs();
    final realDy = (realPoint2.dy - realPoint1.dy).abs();
    return screenDy / realDy;
  }

  /// Average scale
  double get scale => (scaleX + scaleY) / 2;

  /// Convert real coordinates to screen coordinates
  Offset realToScreen(Offset real) {
    final dx = screenPoint1.dx + (real.dx - realPoint1.dx) * scaleX;
    final dy = screenPoint1.dy + (real.dy - realPoint1.dy) * scaleY;
    return Offset(dx, dy);
  }

  /// Convert screen coordinates to real coordinates
  Offset screenToReal(Offset screen) {
    final dx = realPoint1.dx + (screen.dx - screenPoint1.dx) / scaleX;
    final dy = realPoint1.dy + (screen.dy - screenPoint1.dy) / scaleY;
    return Offset(dx, dy);
  }
}
