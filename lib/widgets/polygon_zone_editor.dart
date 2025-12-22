import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/zone_model.dart';

/// Polygon zone editor widget for drawing and editing geo-fence zones
class PolygonZoneEditor extends StatefulWidget {
  final List<Offset> vertices;
  final Color zoneColor;
  final Function(List<Offset>) onVerticesChanged;
  final Function()? onDelete;
  final bool isSelected;

  const PolygonZoneEditor({
    super.key,
    required this.vertices,
    required this.zoneColor,
    required this.onVerticesChanged,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  State<PolygonZoneEditor> createState() => _PolygonZoneEditorState();
}

class _PolygonZoneEditorState extends State<PolygonZoneEditor> {
  late List<Offset> _vertices;
  bool _isDragging = false;
  int _draggedVertexIndex = -1;

  @override
  void initState() {
    super.initState();
    _vertices = List.from(widget.vertices);
  }

  @override
  void didUpdateWidget(covariant PolygonZoneEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vertices != widget.vertices) {
      _vertices = List.from(widget.vertices);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Polygon fill
        CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: _PolygonPainter(
            vertices: _vertices,
            fillColor: widget.zoneColor.withOpacity(0.3),
            strokeColor: widget.zoneColor,
            strokeWidth: widget.isSelected ? 3.0 : 2.0,
            isSelected: widget.isSelected,
          ),
        ),

        // Vertex handles
        if (widget.isSelected) ...[
          for (int i = 0; i < _vertices.length; i++) _buildVertexHandle(i),

          // Delete button
          if (widget.onDelete != null)
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: widget.onDelete,
              ),
            ),
        ],
      ],
    );
  }

  /// Build a draggable vertex handle
  Widget _buildVertexHandle(int index) {
    return Positioned(
      left: _vertices[index].dx - 12,
      top: _vertices[index].dy - 12,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _draggedVertexIndex = index;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging && _draggedVertexIndex == index) {
            setState(() {
              _vertices[index] = _vertices[index] + details.delta;
              widget.onVerticesChanged(_vertices);
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            _draggedVertexIndex = -1;
          });
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: widget.zoneColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.drag_handle,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for drawing polygon zones
class _PolygonPainter extends CustomPainter {
  final List<Offset> vertices;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool isSelected;

  _PolygonPainter({
    required this.vertices,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.length < 3) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final path = Path();
    path.moveTo(vertices[0].dx, vertices[0].dy);

    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }

    path.close();
    canvas.drawPath(path, paint);

    // Draw stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = strokeWidth;

    if (isSelected) {
      // Add dash effect for selected zones
      strokePaint.strokeCap = StrokeCap.round;
    }

    canvas.drawPath(path, strokePaint);

    // Draw animated border for selected zones
    if (isSelected) {
      final dashPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round;

      _drawDashedPath(canvas, path, dashPaint, 5, 3);
    }
  }

  /// Draw a dashed path
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      bool shouldDraw = true;

      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final endDistance = distance + (shouldDraw ? dashWidth : dashSpace);
        final end =
            metric.getTangentForOffset(math.min(endDistance, metric.length));

        if (start != null && end != null && shouldDraw) {
          canvas.drawLine(start.position, end.position, paint);
        }

        distance = endDistance;
        shouldDraw = !shouldDraw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Zone creation toolbar
class ZoneCreationToolbar extends StatelessWidget {
  final ZoneActionType selectedActionType;
  final Function(ZoneActionType) onActionTypeChanged;
  final VoidCallback onCancel;

  const ZoneCreationToolbar({
    super.key,
    required this.selectedActionType,
    required this.onActionTypeChanged,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create Zone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onCancel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<ZoneActionType>(
            segments: const [
              ButtonSegment(
                value: ZoneActionType.forbidden,
                label: Text('Forbidden'),
                icon: Icon(Icons.warning, size: 18),
              ),
              ButtonSegment(
                value: ZoneActionType.accessControl,
                label: Text('Access'),
                icon: Icon(Icons.lock, size: 18),
              ),
              ButtonSegment(
                value: ZoneActionType.monitoring,
                label: Text('Monitor'),
                icon: Icon(Icons.visibility, size: 18),
              ),
            ],
            selected: {selectedActionType},
            onSelectionChanged: (Set<ZoneActionType> newSelection) {
              if (newSelection.isNotEmpty) {
                onActionTypeChanged(newSelection.first);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selectedActionType.color.withOpacity(0.3),
                  border: Border.all(color: selectedActionType.color, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selectedActionType.displayName,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
