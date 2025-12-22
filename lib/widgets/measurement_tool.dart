import 'dart:math';
import 'package:flutter/material.dart';

/// Measurement Tool Widget for measuring distances on floor plans
class MeasurementTool extends StatefulWidget {
  final Function(Offset point1, Offset point2, double distance)?
      onMeasurementComplete;
  final Size imageSize;
  final double pixelsPerMeter;

  const MeasurementTool({
    super.key,
    required this.onMeasurementComplete,
    required this.imageSize,
    required this.pixelsPerMeter,
  });

  @override
  State<MeasurementTool> createState() => _MeasurementToolState();
}

class _MeasurementToolState extends State<MeasurementTool> {
  Offset? _point1;
  Offset? _point2;
  bool _isMeasuring = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Measurement line
        if (_point1 != null && _point2 != null)
          CustomPaint(
            painter: MeasurementPainter(_point1!, _point2!),
            size: widget.imageSize,
          ),

        // Measurement points
        if (_point1 != null)
          Positioned(
            left: _point1!.dx - 10,
            top: _point1!.dy - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        if (_point2 != null)
          Positioned(
            left: _point2!.dx - 10,
            top: _point2!.dy - 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),

        // Distance label
        if (_point1 != null && _point2 != null)
          Positioned(
            left: (_point1!.dx + _point2!.dx) / 2,
            top: (_point1!.dy + _point2!.dy) / 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_calculateDistance().toStringAsFixed(2)}m',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _calculateDistance() {
    if (_point1 == null || _point2 == null) return 0.0;

    final dx = _point2!.dx - _point1!.dx;
    final dy = _point2!.dy - _point1!.dy;
    final pixelDistance = sqrt(dx * dx + dy * dy);
    return pixelDistance / widget.pixelsPerMeter;
  }

  void startMeasurement(Offset point) {
    setState(() {
      _point1 = point;
      _point2 = null;
      _isMeasuring = true;
    });
  }

  void updateMeasurement(Offset point) {
    if (_isMeasuring && _point1 != null) {
      setState(() {
        _point2 = point;
      });
    }
  }

  void completeMeasurement() {
    if (_point1 != null && _point2 != null) {
      final distance = _calculateDistance();
      widget.onMeasurementComplete?.call(_point1!, _point2!, distance);
    }

    setState(() {
      _point1 = null;
      _point2 = null;
      _isMeasuring = false;
    });
  }
}

/// Custom painter for drawing measurement lines
class MeasurementPainter extends CustomPainter {
  final Offset point1;
  final Offset point2;

  MeasurementPainter(this.point1, this.point2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw line between points
    canvas.drawLine(point1, point2, paint);

    // Draw arrowheads
    _drawArrowhead(canvas, paint, point1, point2);
    _drawArrowhead(canvas, paint, point2, point1);
  }

  void _drawArrowhead(Canvas canvas, Paint paint, Offset start, Offset end) {
    final angle = (end.dy - start.dy) / (end.dx - start.dx);
    const headLength = 10.0;

    // Simple arrowhead implementation
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - headLength * cos(angle + 0.5),
        end.dy - headLength * sin(angle + 0.5),
      )
      ..lineTo(
        end.dx - headLength * cos(angle - 0.5),
        end.dy - headLength * sin(angle - 0.5),
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
