import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Advanced RTLS Map Screen
class AdvancedRtlsMapScreen extends StatefulWidget {
  const AdvancedRtlsMapScreen({super.key});

  @override
  State<AdvancedRtlsMapScreen> createState() => _AdvancedRtlsMapScreenState();
}

class _AdvancedRtlsMapScreenState extends State<AdvancedRtlsMapScreen> {
  final List<MapTag> _tags = [
    MapTag(id: '001', name: 'Worker-1', x: 150, y: 200, type: TagType.worker),
    MapTag(
        id: '002', name: 'Forklift-1', x: 300, y: 350, type: TagType.vehicle),
  ];

  final List<MapZone> _zones = [
    MapZone(
        name: 'Assembly Area',
        x: 100,
        y: 100,
        width: 200,
        height: 150,
        color: Colors.blue),
    MapZone(
        name: 'Warehouse',
        x: 350,
        y: 250,
        width: 250,
        height: 200,
        color: Colors.green),
  ];

  final List<MapWall> _walls = [];
  final List<MapDoor> _doors = [];
  final List<MapAnchor> _anchors = [];
  final List<MapDistanceLine> _distanceLines =
      []; // Zone-to-zone distance measurements

  Uint8List? _floorPlanBytes;
  bool _isEditMode = false;
  MapElement? _selectedElement;
  DrawingMode _drawingMode = DrawingMode.none;
  Offset? _wallStartPoint;
  bool _isPlacingElement = false;
  String _pendingElementType = '';
  bool _isDisposed = false;
  MapZone? _distanceLineStartZone; // For measuring zone-to-zone distance

  // Measurement system
  double _mapScale = 0.025; // 1px = 0.025m (2.5cm)
  String _measurementUnit = 'meter'; // meter, cm, feet
  bool _showMeasurements = true;

  @override
  void dispose() {
    _isDisposed = true;
    _floorPlanBytes = null;
    _selectedElement = null;
    _wallStartPoint = null;
    _distanceLineStartZone = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Advanced RTLS Map'),
        actions: [
          IconButton(
              icon: const Icon(Icons.straighten),
              tooltip: 'Map Config',
              onPressed: _showMapConfig),
          IconButton(
              icon: const Icon(Icons.upload_file), onPressed: _importFloorPlan),
          IconButton(
              icon: const Icon(Icons.picture_as_pdf), onPressed: _exportToPdf),
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: () => setState(() {
              _isEditMode = !_isEditMode;
              if (!_isEditMode) {
                _selectedElement = null;
                _drawingMode = DrawingMode.none;
                _wallStartPoint = null;
                _distanceLineStartZone = null;
              }
            }),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          final bodyContent = Column(
            children: [
              if (_isEditMode) _buildDrawingTools(),
              Expanded(
                child: Row(
                  children: [
                    // Side panel for edit buttons (only in edit mode)
                    if (_isEditMode) _buildEditSidePanel(),
                    // Main map area
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 4, right: 4, bottom: 4), // Reduced margins
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius:
                              BorderRadius.circular(12), // Smaller radius
                          border: Border.all(
                              color: const Color(0xFF007AFF).withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                onTapDown: (details) {
                                  if (!_isEditMode || _isDisposed) return;

                                  if (_drawingMode == DrawingMode.wall) {
                                    _handleWallDrawing(details.localPosition);
                                  } else if (_isPlacingElement) {
                                    _placeElementAtPosition(
                                        details.localPosition);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    if (_floorPlanBytes != null)
                                      Positioned.fill(
                                          child: Image.memory(_floorPlanBytes!,
                                              fit: BoxFit.contain))
                                    else
                                      Positioned.fill(
                                          child: CustomPaint(
                                              painter: GridPainter())),
                                    ..._zones
                                        .map((zone) => _buildZone(zone))
                                        .toList(),
                                    ..._walls
                                        .map((wall) => _buildWall(wall))
                                        .toList(),
                                    ..._doors
                                        .map((door) => _buildDoor(door))
                                        .toList(),
                                    ..._anchors
                                        .map((anchor) => _buildAnchor(anchor))
                                        .toList(),
                                    ..._distanceLines
                                        .map((line) => _buildDistanceLine(line))
                                        .toList(),
                                    ..._tags
                                        .map((tag) => _buildTag(tag))
                                        .toList(),
                                    Positioned(
                                        top: 16,
                                        right: 16,
                                        child: _buildLegend()),
                                    if (_wallStartPoint != null)
                                      Positioned(
                                        left: _wallStartPoint!.dx - 5,
                                        top: _wallStartPoint!.dy - 5,
                                        child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle)),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildElementList(),
            ],
          );

          // Wrap in scroll view for landscape mode
          return isLandscape
              ? SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context)
                        .size
                        .width, // Use width as height in landscape
                    child: bodyContent,
                  ),
                )
              : bodyContent;
        },
      ),
    );
  }

  Widget _buildDrawingTools() {
    return Container(
      height: 50, // Reduced from 60
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // Reduced padding
      color: const Color(0xFF1F2937),
      child: Row(
        children: [
          const Text('Tools:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolButton(
                      'Zone', Icons.crop_square, DrawingMode.zone, Colors.blue),
                  _buildToolButton('Wall', Icons.horizontal_rule,
                      DrawingMode.wall, Colors.grey),
                  _buildToolButton('Door', Icons.sensor_door, DrawingMode.door,
                      Colors.brown),
                  _buildToolButton(
                      'Anchor', Icons.router, DrawingMode.anchor, Colors.red),
                  _buildToolButton('Distance', Icons.straighten,
                      DrawingMode.distance, Colors.yellow),
                ],
              ),
            ),
          ),
          if (_selectedElement != null)
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: _deleteSelectedElement),
        ],
      ),
    );
  }

  Widget _buildToolButton(
      String label, IconData icon, DrawingMode mode, Color color) {
    final isSelected = _drawingMode == mode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: () => setState(() {
          _drawingMode = mode;
          if (mode != DrawingMode.wall) _wallStartPoint = null;
          if (mode != DrawingMode.distance) _distanceLineStartZone = null;
        }),
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : const Color(0xFF0B0C10),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildZone(MapZone zone) {
    final isSelected = _selectedElement == zone;
    return Positioned(
      left: zone.x,
      top: zone.y,
      child: GestureDetector(
        onTap: _isEditMode
            ? () {
                if (_drawingMode == DrawingMode.distance) {
                  _handleDistanceLineMeasurement(zone);
                } else {
                  setState(() => _selectedElement = zone);
                }
              }
            : null,
        onDoubleTap: _isEditMode ? () => _editZone(zone) : null,
        onPanUpdate: _isEditMode && _drawingMode != DrawingMode.distance
            ? (details) => setState(() {
                  zone.x += details.delta.dx;
                  zone.y += details.delta.dy;
                })
            : null,
        child: Container(
          width: zone.width,
          height: zone.height,
          decoration: BoxDecoration(
            color: zone.color.withOpacity(0.2),
            border: Border.all(
                color: isSelected ? Colors.red : zone.color,
                width: isSelected ? 3 : 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Zone name in center
              Center(
                child: Text(
                  zone.name,
                  style: TextStyle(
                    color: zone.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              // Measurement badges - CLICKABLE TO EDIT!
              if (_showMeasurements)
                // Width badge (top) - EDITABLE
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isEditMode
                          ? () => _quickEditZoneDimension(zone, 'width')
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isEditMode
                              ? Colors.blue.withOpacity(0.8)
                              : Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                          border: _isEditMode
                              ? Border.all(color: Colors.white, width: 1)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isEditMode)
                              const Icon(Icons.edit,
                                  size: 10, color: Colors.white),
                            if (_isEditMode) const SizedBox(width: 2),
                            Text(
                              _toRealSize(zone.width),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showMeasurements)
                // Height badge (left side) - EDITABLE
                Positioned(
                  left: 2,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isEditMode
                          ? () => _quickEditZoneDimension(zone, 'height')
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isEditMode
                              ? Colors.blue.withOpacity(0.8)
                              : Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                          border: _isEditMode
                              ? Border.all(color: Colors.white, width: 1)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isEditMode)
                              const Icon(Icons.edit,
                                  size: 10, color: Colors.white),
                            if (_isEditMode) const SizedBox(width: 2),
                            Text(
                              _toRealSize(zone.height),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWall(MapWall wall) {
    final isSelected = _selectedElement == wall;
    return Stack(
      children: [
        // Wall line
        Positioned(
          left: wall.x1 < wall.x2 ? wall.x1 : wall.x2,
          top: wall.y1 < wall.y2 ? wall.y1 : wall.y2,
          child: GestureDetector(
            onTap: _isEditMode
                ? () => setState(() => _selectedElement = wall)
                : null,
            onDoubleTap:
                _isEditMode ? () => _editWall(wall) : null, // Changed to edit
            child: SizedBox(
              width: (wall.x2 - wall.x1).abs() + 10,
              height: (wall.y2 - wall.y1).abs() + 10,
              child: CustomPaint(painter: WallPainter(wall, isSelected)),
            ),
          ),
        ),
        // Draggable start point
        if (_isEditMode && isSelected)
          Positioned(
            left: wall.x1 - 8,
            top: wall.y1 - 8,
            child: GestureDetector(
              onPanUpdate: (details) => setState(() {
                wall.x1 += details.delta.dx;
                wall.y1 += details.delta.dy;
              }),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        // Draggable end point
        if (_isEditMode && isSelected)
          Positioned(
            left: wall.x2 - 8,
            top: wall.y2 - 8,
            child: GestureDetector(
              onPanUpdate: (details) => setState(() {
                wall.x2 += details.delta.dx;
                wall.y2 += details.delta.dy;
              }),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDoor(MapDoor door) {
    final isSelected = _selectedElement == door;
    return Positioned(
      left: door.x,
      top: door.y,
      child: GestureDetector(
        onTap:
            _isEditMode ? () => setState(() => _selectedElement = door) : null,
        onDoubleTap: _isEditMode ? () => _editDoor(door) : null,
        onPanUpdate: _isEditMode
            ? (details) => setState(() {
                  door.x += details.delta.dx;
                  door.y += details.delta.dy;
                })
            : null,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              border: Border.all(
                  color: isSelected ? Colors.red : Colors.brown,
                  width: isSelected ? 3 : 2),
              borderRadius: BorderRadius.circular(4)),
          child: CustomPaint(
              painter: DoorPainter(isSelected), size: const Size(60, 60)),
        ),
      ),
    );
  }

  Widget _buildAnchor(MapAnchor anchor) {
    final isSelected = _selectedElement == anchor;
    return Positioned(
      left: anchor.x,
      top: anchor.y,
      child: GestureDetector(
        onTap: _isEditMode
            ? () => setState(() => _selectedElement = anchor)
            : () => _showAnchorDetails(anchor),
        onDoubleTap: _isEditMode ? () => _editAnchor(anchor) : null,
        onPanUpdate: _isEditMode
            ? (details) => setState(() {
                  anchor.x += details.delta.dx;
                  anchor.y += details.delta.dy;
                })
            : null,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.red,
                    width: isSelected ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3)
                ],
              ),
              child: const Icon(Icons.router, color: Colors.red, size: 28),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(4)),
              child: Text(anchor.id,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(MapTag tag) {
    final isSelected = _selectedElement == tag;
    return Positioned(
      left: tag.x,
      top: tag.y,
      child: GestureDetector(
        onTap: _isEditMode
            ? () => setState(() => _selectedElement = tag)
            : () => _showTagDetails(tag),
        onDoubleTap: _isEditMode ? () => _editTag(tag) : null,
        onPanUpdate: _isEditMode
            ? (details) => setState(() {
                  tag.x += details.delta.dx;
                  tag.y += details.delta.dy;
                })
            : null,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tag.type.color,
            shape: BoxShape.circle,
            border: Border.all(
                color: isSelected ? Colors.red : Colors.white,
                width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                  color: tag.type.color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2)
            ],
          ),
          child:
              Center(child: Icon(tag.type.icon, color: Colors.white, size: 24)),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFF0B0C10).withOpacity(0.9),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Legend',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          ...TagType.values
              .map((type) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(type.icon, color: type.color, size: 16),
                      const SizedBox(width: 8),
                      Text(type.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ]),
                  ))
              .toList(),
          const Divider(color: Colors.grey),
          const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.router, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Text('UWB Anchor',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _buildElementList() {
    return Container(
      height: 70, // Reduced from 80
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(
          top: BorderSide(
              color: const Color(0xFF1F2937),
              width: 1), // Same color = no visible line
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Map Elements',
              style: TextStyle(
                  fontSize: 14, // Reduced from 16
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6), // Reduced from 8
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildElementChip('Tags', _tags.length, Icons.sensors),
                _buildElementChip('Zones', _zones.length, Icons.crop_square),
                _buildElementChip(
                    'Walls', _walls.length, Icons.horizontal_rule),
                _buildElementChip('Doors', _doors.length, Icons.sensor_door),
                _buildElementChip('Anchors', _anchors.length, Icons.router),
                _buildElementChip(
                    'Distances', _distanceLines.length, Icons.straighten),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementChip(String label, int count, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 10), // Reduced from 12
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10),
        borderRadius: BorderRadius.circular(6), // Reduced from 8
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF00FFC6), size: 16), // Reduced from 20
        const SizedBox(width: 6), // Reduced from 8
        Text('$label: $count',
            style: const TextStyle(
                color: Colors.white, fontSize: 12)), // Smaller text
      ]),
    );
  }

  Widget _buildEditSidePanel() {
    return Container(
      width: 130, // Further reduced from 140px
      margin:
          const EdgeInsets.only(left: 4, top: 4, bottom: 4), // Smaller margins
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(10), // Smaller radius
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
          // Scrollable buttons
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  _buildSidePanelButton(
                      'Zone', Icons.crop_square, Colors.blue, _addZone),
                  _buildSidePanelButton('Door', Icons.sensor_door, Colors.brown,
                      _startPlacingDoor),
                  _buildSidePanelButton(
                      'Anchor', Icons.router, Colors.red, _startPlacingAnchor),
                  const Divider(color: Colors.grey, height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Tags',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  _buildSidePanelButton(
                      'Worker',
                      TagType.worker.icon,
                      TagType.worker.color,
                      () => _startPlacingTag(TagType.worker)),
                  _buildSidePanelButton(
                      'Vehicle',
                      TagType.vehicle.icon,
                      TagType.vehicle.color,
                      () => _startPlacingTag(TagType.vehicle)),
                  _buildSidePanelButton(
                      'Equipment',
                      TagType.equipment.icon,
                      TagType.equipment.color,
                      () => _startPlacingTag(TagType.equipment)),
                  _buildSidePanelButton(
                      'Asset',
                      TagType.asset.icon,
                      TagType.asset.color,
                      () => _startPlacingTag(TagType.asset)),
                ],
              ),
            ),
          ),
          // Delete button at bottom
          if (_selectedElement != null)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border(
                  top: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _deleteSelectedElement,
                  icon: const Icon(Icons.delete, size: 14),
                  label: const Text('Del', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidePanelButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    final isActive = _isPlacingElement &&
        (_pendingElementType == label.toLowerCase() ||
            (_pendingElementType == 'door' && label == 'Door') ||
            (_pendingElementType == 'anchor' && label == 'Anchor'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? color : const Color(0xFF0B0C10),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: isActive ? Colors.white : color.withOpacity(0.5),
                width: isActive ? 2 : 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : color),
              const SizedBox(height: 2),
              Text(
                isActive ? 'Click' : label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Map Element FABs (always visible in edit mode)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addZone',
            onPressed: _addZone,
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.add),
            label: const Text('Add Zone'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addDoor',
            onPressed: _startPlacingDoor,
            backgroundColor: Colors.brown,
            icon: const Icon(Icons.add),
            label: Text(_isPlacingElement && _pendingElementType == 'door'
                ? 'Click Map'
                : 'Add Door'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addAnchor',
            onPressed: _startPlacingAnchor,
            backgroundColor: Colors.red,
            icon: const Icon(Icons.add),
            label: Text(_isPlacingElement && _pendingElementType == 'anchor'
                ? 'Click Map'
                : 'Add Anchor'),
          ),
        ),
        const Divider(color: Colors.white),
        // UWB Tag Type FABs
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addWorker',
            onPressed: () => _startPlacingTag(TagType.worker),
            backgroundColor: TagType.worker.color,
            icon: Icon(TagType.worker.icon),
            label: Text(_isPlacingElement && _pendingElementType == 'worker'
                ? 'Click Map'
                : 'Add Worker'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addVehicle',
            onPressed: () => _startPlacingTag(TagType.vehicle),
            backgroundColor: TagType.vehicle.color,
            icon: Icon(TagType.vehicle.icon),
            label: Text(_isPlacingElement && _pendingElementType == 'vehicle'
                ? 'Click Map'
                : 'Add Vehicle'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addEquipment',
            onPressed: () => _startPlacingTag(TagType.equipment),
            backgroundColor: TagType.equipment.color,
            icon: Icon(TagType.equipment.icon),
            label: Text(_isPlacingElement && _pendingElementType == 'equipment'
                ? 'Click Map'
                : 'Add Equipment'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            heroTag: 'addAsset',
            onPressed: () => _startPlacingTag(TagType.asset),
            backgroundColor: TagType.asset.color,
            icon: Icon(TagType.asset.icon),
            label: Text(_isPlacingElement && _pendingElementType == 'asset'
                ? 'Click Map'
                : 'Add Asset'),
          ),
        ),
      ],
    );
  }

  Future<void> _importFloorPlan() async {
    try {
      final XFile? image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _floorPlanBytes = bytes;
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Floor plan imported'),
              backgroundColor: Color(0xFF00FFC6)));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('QuantumMind RTLS - Factory Floor Plan',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Map Elements:'),
                  pw.SizedBox(height: 10),
                  pw.Text('• Tags: ${_tags.length}'),
                  pw.Text('• Zones: ${_zones.length}'),
                  pw.Text('• Walls: ${_walls.length}'),
                  pw.Text('• Doors: ${_doors.length}'),
                  pw.Text('• Anchors: ${_anchors.length}'),
                  pw.SizedBox(height: 20),
                  pw.Text('Zones:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ..._zones.map((zone) => pw.Text('  • ${zone.name}')),
                  pw.SizedBox(height: 20),
                  pw.Text('Tags:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ..._tags.map(
                      (tag) => pw.Text('  • ${tag.name} (${tag.type.label})')),
                  if (_anchors.isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Text('UWB Anchors:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ..._anchors.map((anchor) =>
                        pw.Text('  • ${anchor.name} - ID: ${anchor.id}')),
                  ],
                ]);
          }));
      final output = await getApplicationDocumentsDirectory();
      final file = File(
          '${output.path}/rtls_map_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PDF exported to: ${file.path}'),
            backgroundColor: const Color(0xFF00FFC6),
            duration: const Duration(seconds: 5)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PDF export failed: $e'),
            backgroundColor: Colors.redAccent));
    }
  }

  void _addZone() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _AddZoneDialog(
        onAdd: (zone) {
          if (mounted) setState(() => _zones.add(zone));
        },
      ),
    );
  }

  void _editZone(MapZone zone) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _EditZoneDialog(
        zone: zone,
        mapScale: _mapScale,
        measurementUnit: _measurementUnit,
        onEdit: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _quickEditZoneDimension(MapZone zone, String dimension) {
    if (!mounted) return;

    final isWidth = dimension == 'width';
    final currentValue = isWidth ? zone.width : zone.height;
    final currentRealValue = currentValue * _mapScale;

    String displayValue;
    switch (_measurementUnit) {
      case 'meter':
        displayValue = currentRealValue.toStringAsFixed(2);
        break;
      case 'cm':
        displayValue = (currentRealValue * 100).toStringAsFixed(0);
        break;
      case 'feet':
        displayValue = (currentRealValue * 3.28084).toStringAsFixed(2);
        break;
      default:
        displayValue = currentRealValue.toStringAsFixed(2);
    }

    final controller = TextEditingController(text: displayValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Row(
          children: [
            Icon(
              isWidth ? Icons.swap_horiz : Icons.swap_vert,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Edit ${isWidth ? "Width" : "Height"}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zone: ${zone.name}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                labelText:
                    '${isWidth ? "Width" : "Height"} (${_getMeasurementUnitSymbol()})',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: 'e.g., 5.00',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(
                  Icons.straighten,
                  color: Colors.blue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onSubmitted: (value) {
                _saveQuickEditDimension(zone, dimension, value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Press Enter or click Save',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveQuickEditDimension(zone, dimension, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveQuickEditDimension(MapZone zone, String dimension, String value) {
    final parsedValue = double.tryParse(value);
    if (parsedValue == null || parsedValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert from real units to pixels
    double realValueMeters;
    switch (_measurementUnit) {
      case 'meter':
        realValueMeters = parsedValue;
        break;
      case 'cm':
        realValueMeters = parsedValue / 100;
        break;
      case 'feet':
        realValueMeters = parsedValue / 3.28084;
        break;
      default:
        realValueMeters = parsedValue;
    }

    final pixels = realValueMeters / _mapScale;

    setState(() {
      if (dimension == 'width') {
        zone.width = pixels;
      } else {
        zone.height = pixels;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${dimension == "width" ? "Width" : "Height"} updated to ${value}${_getMeasurementUnitSymbol()}'),
        backgroundColor: const Color(0xFF00FFC6),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getMeasurementUnitSymbol() {
    switch (_measurementUnit) {
      case 'meter':
        return 'm';
      case 'cm':
        return 'cm';
      case 'feet':
        return 'ft';
      default:
        return 'm';
    }
  }

  void _editAnchor(MapAnchor anchor) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _EditAnchorDialog(
        anchor: anchor,
        onEdit: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _editTag(MapTag tag) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _EditTagDialog(
        tag: tag,
        onEdit: (updatedTag) {
          if (mounted) {
            setState(() {
              final index = _tags.indexOf(tag);
              if (index != -1) {
                _tags[index] = updatedTag;
              }
            });
          }
        },
      ),
    );
  }

  void _editDoor(MapDoor door) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _EditDoorDialog(
        door: door,
        onEdit: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _editWall(MapWall wall) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _EditWallDialog(
        wall: wall,
        mapScale: _mapScale,
        measurementUnit: _measurementUnit,
        onEdit: () {
          if (mounted) {
            setState(() {
              // Wall updated
            });
          }
        },
      ),
    );
  }

  void _showMapConfig() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _MapConfigDialog(
        scale: _mapScale,
        unit: _measurementUnit,
        showMeasurements: _showMeasurements,
        onSave: (scale, unit, showMeas) {
          if (mounted) {
            setState(() {
              _mapScale = scale;
              _measurementUnit = unit;
              _showMeasurements = showMeas;
            });
          }
        },
      ),
    );
  }

  String _toRealSize(double pixels) {
    double realSize = pixels * _mapScale;
    switch (_measurementUnit) {
      case 'meter':
        return '${realSize.toStringAsFixed(2)}m';
      case 'cm':
        return '${(realSize * 100).toStringAsFixed(0)}cm';
      case 'feet':
        return '${(realSize * 3.28084).toStringAsFixed(2)}ft';
      default:
        return '${realSize.toStringAsFixed(2)}m';
    }
  }

  void _addDoor() => setState(() =>
      _doors.add(MapDoor(x: 200, y: 200, name: 'Door ${_doors.length + 1}')));

  void _addAnchor() => showDialog(
      context: context,
      builder: (context) => _AddAnchorDialog(
          onAdd: (anchor) => setState(() => _anchors.add(anchor))));

  void _startPlacingTag(TagType type) {
    setState(() {
      _isPlacingElement = true;
      _pendingElementType = type.name;
    });
    // No SnackBar - visual cursor shows placement mode
  }

  void _startPlacingDoor() {
    setState(() {
      _isPlacingElement = true;
      _pendingElementType = 'door';
    });
    // No SnackBar - visual cursor shows placement mode
  }

  void _startPlacingAnchor() {
    setState(() {
      _isPlacingElement = true;
      _pendingElementType = 'anchor';
    });
    // No SnackBar - visual cursor shows placement mode
  }

  void _placeElementAtPosition(Offset position) {
    if (_pendingElementType == 'door') {
      if (mounted) {
        setState(() {
          _doors.add(MapDoor(
            x: position.dx - 30,
            y: position.dy - 30,
            name: 'Door ${_doors.length + 1}',
          ));
          _isPlacingElement = false;
          _pendingElementType = '';
        });
      }
    } else if (_pendingElementType == 'anchor') {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => _AddAnchorDialog(
          position: position,
          onAdd: (anchor) {
            if (mounted) {
              setState(() {
                _anchors.add(anchor);
                _isPlacingElement = false;
                _pendingElementType = '';
              });
            }
          },
        ),
      );
    } else {
      // Handle tag placement
      final tagType = TagType.values.firstWhere(
        (t) => t.name == _pendingElementType,
        orElse: () => TagType.worker,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => _AddTagDialog(
          type: tagType,
          position: position,
          onAdd: (tag) {
            if (mounted) {
              setState(() {
                _tags.add(tag);
                _isPlacingElement = false;
                _pendingElementType = '';
              });
            }
          },
        ),
      );
    }
  }

  void _handleWallDrawing(Offset position) {
    if (!mounted) return;

    if (_wallStartPoint == null) {
      setState(() => _wallStartPoint = position);
      // Visual red circle shows first point - no SnackBar needed
    } else {
      setState(() {
        _walls.add(MapWall(
          x1: _wallStartPoint!.dx,
          y1: _wallStartPoint!.dy,
          x2: position.dx,
          y2: position.dy,
        ));
        _wallStartPoint = null;
      });
      // Wall created silently - visible on map
    }
  }

  void _deleteSelectedElement() {
    if (_selectedElement == null || !mounted) return;
    setState(() {
      if (_selectedElement is MapTag)
        _tags.remove(_selectedElement);
      else if (_selectedElement is MapZone)
        _zones.remove(_selectedElement);
      else if (_selectedElement is MapWall)
        _walls.remove(_selectedElement);
      else if (_selectedElement is MapDoor)
        _doors.remove(_selectedElement);
      else if (_selectedElement is MapAnchor)
        _anchors.remove(_selectedElement);
      else if (_selectedElement is MapDistanceLine)
        _distanceLines.remove(_selectedElement);
      _selectedElement = null;
    });
  }

  void _handleDistanceLineMeasurement(MapZone zone) {
    if (_distanceLineStartZone == null) {
      // First zone selected
      setState(() {
        _distanceLineStartZone = zone;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'First zone "${zone.name}" selected. Click another zone to measure distance.'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (_distanceLineStartZone == zone) {
      // Same zone clicked - cancel
      setState(() {
        _distanceLineStartZone = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Distance measurement cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Second zone selected - create distance line
      final newLine = MapDistanceLine(
        startZone: _distanceLineStartZone!,
        endZone: zone,
      );
      setState(() {
        _distanceLines.add(newLine);
        _distanceLineStartZone = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Distance line created between "${_distanceLineStartZone!.name}" and "${zone.name}"'),
          backgroundColor: const Color(0xFF00FFC6),
        ),
      );
    }
  }

  Widget _buildDistanceLine(MapDistanceLine line) {
    final isSelected = _selectedElement == line;
    final startPoint = line.startPoint;
    final endPoint = line.endPoint;

    // Calculate midpoint for label
    final midX = (startPoint.dx + endPoint.dx) / 2;
    final midY = (startPoint.dy + endPoint.dy) / 2;

    // Calculate real distance
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final lengthPx = (dx * dx + dy * dy).abs().toDouble();
    final realSize = lengthPx * _mapScale;

    String distanceText;
    switch (_measurementUnit) {
      case 'meter':
        distanceText = '${realSize.toStringAsFixed(2)}m';
        break;
      case 'cm':
        distanceText = '${(realSize * 100).toStringAsFixed(0)}cm';
        break;
      case 'feet':
        distanceText = '${(realSize * 3.28084).toStringAsFixed(2)}ft';
        break;
      default:
        distanceText = '${realSize.toStringAsFixed(2)}m';
    }

    return Stack(
      children: [
        // Distance line
        Positioned(
          left: 0,
          top: 0,
          child: GestureDetector(
            onTap: _isEditMode
                ? () => setState(() => _selectedElement = line)
                : null,
            onDoubleTap: _isEditMode ? () => _editDistanceLine(line) : null,
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: DistanceLinePainter(
                startPoint: startPoint,
                endPoint: endPoint,
                isSelected: isSelected,
              ),
            ),
          ),
        ),
        // Distance label
        Positioned(
          left: midX - 40,
          top: midY - 20,
          child: GestureDetector(
            onTap: _isEditMode
                ? () => setState(() => _selectedElement = line)
                : null,
            onDoubleTap: _isEditMode ? () => _editDistanceLine(line) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.yellow.shade700,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.yellow.shade900,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.straighten, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    line.label ?? distanceText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editDistanceLine(MapDistanceLine line) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _EditDistanceLineDialog(
        line: line,
        mapScale: _mapScale,
        measurementUnit: _measurementUnit,
        onEdit: () {
          if (mounted) {
            setState(() {
              // Distance line updated
            });
          }
        },
      ),
    );
  }

  void _showAnchorDetails(MapAnchor anchor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.router, color: Colors.red, size: 32),
              const SizedBox(width: 16),
              Text(anchor.name,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
            ]),
            const SizedBox(height: 16),
            _buildDetailRow('Anchor ID', anchor.id),
            _buildDetailRow('Type', 'UWB Anchor'),
            _buildDetailRow(
                'Position', 'X: ${anchor.x.toInt()}, Y: ${anchor.y.toInt()}'),
            _buildDetailRow('Status', 'Active'),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF)),
                    child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  void _showTagDetails(MapTag tag) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(tag.type.icon, color: tag.type.color, size: 32),
              const SizedBox(width: 16),
              Text(tag.name,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
            ]),
            const SizedBox(height: 16),
            _buildDetailRow('ID', tag.id),
            _buildDetailRow('Type', tag.type.label),
            _buildDetailRow(
                'Position', 'X: ${tag.x.toInt()}, Y: ${tag.y.toInt()}'),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF)),
                    child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      );
}

// Models
abstract class MapElement {}

class MapTag extends MapElement {
  final String id;
  final String name;
  double x;
  double y;
  final TagType type;
  MapTag(
      {required this.id,
      required this.name,
      required this.x,
      required this.y,
      required this.type});
}

class MapZone extends MapElement {
  String name;
  double x;
  double y;
  double width;
  double height;
  Color color;
  MapZone(
      {required this.name,
      required this.x,
      required this.y,
      required this.width,
      required this.height,
      required this.color});
}

class MapWall extends MapElement {
  double x1;
  double y1;
  double x2;
  double y2;
  MapWall(
      {required this.x1, required this.y1, required this.x2, required this.y2});
}

class MapDoor extends MapElement {
  String name;
  double x;
  double y;
  MapDoor({required this.name, required this.x, required this.y});
}

class MapAnchor extends MapElement {
  String id;
  String name;
  double x;
  double y;
  MapAnchor(
      {required this.id, required this.name, required this.x, required this.y});
}

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

enum DrawingMode { none, zone, wall, door, anchor, distance }

// Painters
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 50)
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 50)
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WallPainter extends CustomPainter {
  final MapWall wall;
  final bool isSelected;
  WallPainter(this.wall, this.isSelected);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.red : Colors.grey[700]!
      ..strokeWidth = isSelected ? 8 : 6
      ..strokeCap = StrokeCap.round;
    final startX = wall.x1 < wall.x2 ? 5.0 : size.width - 5;
    final startY = wall.y1 < wall.y2 ? 5.0 : size.height - 5;
    final endX = wall.x2 > wall.x1 ? size.width - 5 : 5.0;
    final endY = wall.y2 > wall.y1 ? size.height - 5 : 5.0;
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DoorPainter extends CustomPainter {
  final bool isSelected;
  DoorPainter(this.isSelected);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.red : Colors.brown
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(5, 5, size.width - 10, size.height - 10),
        Paint()
          ..color = Colors.brown.withOpacity(0.3)
          ..style = PaintingStyle.fill);
    final panelWidth = (size.width - 20) / 2;
    canvas.drawRect(
        Rect.fromLTWH(8, 8, panelWidth - 2, size.height - 16), paint);
    canvas.drawRect(
        Rect.fromLTWH(10 + panelWidth, 8, panelWidth - 2, size.height - 16),
        paint);
    canvas.drawCircle(Offset(8 + panelWidth - 8, size.height / 2), 3,
        Paint()..color = Colors.yellow);
    canvas.drawCircle(Offset(10 + panelWidth + 8, size.height / 2), 3,
        Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DistanceLinePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final bool isSelected;

  DistanceLinePainter({
    required this.startPoint,
    required this.endPoint,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.red : Colors.yellow.shade700
      ..strokeWidth = isSelected ? 3 : 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed line
    const dashWidth = 5;
    const dashSpace = 5;

    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final distance = (dx * dx + dy * dy).abs().toDouble();
    final steps = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < steps; i++) {
      final t1 = (i * (dashWidth + dashSpace)) / distance;
      final t2 = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;

      final x1 = startPoint.dx + dx * t1;
      final y1 = startPoint.dy + dy * t1;
      final x2 = startPoint.dx + dx * t2;
      final y2 = startPoint.dy + dy * t2;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw endpoint circles
    final circlePaint = Paint()
      ..color = isSelected ? Colors.red : Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startPoint, 5, circlePaint);
    canvas.drawCircle(endPoint, 5, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Dialogs
class _AddTagDialog extends StatefulWidget {
  final TagType type;
  final Offset? position;
  final Function(MapTag) onAdd;
  const _AddTagDialog({required this.type, this.position, required this.onAdd});
  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: Text('Add ${widget.type.label} Tag',
          style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _idController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText:
                  'Tag ID (e.g., ${widget.type == TagType.worker ? "W001" : widget.type == TagType.vehicle ? "V001" : widget.type == TagType.equipment ? "E001" : "A001"})',
              labelStyle: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '${widget.type.label} Name',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: widget.type == TagType.worker
                  ? 'e.g., John Smith'
                  : widget.type == TagType.vehicle
                      ? 'e.g., Forklift-A'
                      : widget.type == TagType.equipment
                          ? 'e.g., Drill-1'
                          : 'e.g., Pallet-101',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final prefix = widget.type == TagType.worker
                ? 'W'
                : widget.type == TagType.vehicle
                    ? 'V'
                    : widget.type == TagType.equipment
                        ? 'E'
                        : 'A';
            final position = widget.position ?? const Offset(200, 200);
            widget.onAdd(MapTag(
              id: _idController.text.isEmpty
                  ? '$prefix${DateTime.now().millisecondsSinceEpoch % 1000}'
                  : _idController.text,
              name: _nameController.text.isEmpty
                  ? '${widget.type.label} ${DateTime.now().millisecondsSinceEpoch % 100}'
                  : _nameController.text,
              x: position.dx - 25,
              y: position.dy - 25,
              type: widget.type,
            ));
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddZoneDialog extends StatefulWidget {
  final Function(MapZone) onAdd;
  const _AddZoneDialog({required this.onAdd});
  @override
  State<_AddZoneDialog> createState() => _AddZoneDialogState();
}

class _AddZoneDialogState extends State<_AddZoneDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Add Zone', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Zone Name',
                  labelStyle: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          const Text('Color:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              children: [
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.red
              ]
                  .map((color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _selectedColor == color
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3)))))
                  .toList()),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              widget.onAdd(MapZone(
                  name: _nameController.text.isEmpty
                      ? 'Zone'
                      : _nameController.text,
                  x: 100,
                  y: 100,
                  width: 120, // Reduced from 200
                  height: 100, // Reduced from 150
                  color: _selectedColor));
              Navigator.pop(context);
            },
            child: const Text('Add')),
      ],
    );
  }
}

class _EditZoneDialog extends StatefulWidget {
  final MapZone zone;
  final double mapScale;
  final String measurementUnit;
  final VoidCallback onEdit;

  const _EditZoneDialog({
    required this.zone,
    required this.mapScale,
    required this.measurementUnit,
    required this.onEdit,
  });

  @override
  State<_EditZoneDialog> createState() => _EditZoneDialogState();
}

class _EditZoneDialogState extends State<_EditZoneDialog> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late Color _selectedColor;
  bool _useRealUnits = true; // Toggle between pixels and real units

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone.name);
    // Initialize with real-world measurements
    final widthReal = widget.zone.width * widget.mapScale;
    final heightReal = widget.zone.height * widget.mapScale;
    _widthController = TextEditingController(text: _formatRealValue(widthReal));
    _heightController =
        TextEditingController(text: _formatRealValue(heightReal));
    _selectedColor = widget.zone.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String _formatRealValue(double realSize) {
    switch (widget.measurementUnit) {
      case 'meter':
        return realSize.toStringAsFixed(2);
      case 'cm':
        return (realSize * 100).toStringAsFixed(0);
      case 'feet':
        return (realSize * 3.28084).toStringAsFixed(2);
      default:
        return realSize.toStringAsFixed(2);
    }
  }

  double _parseRealValue(String text) {
    final value = double.tryParse(text) ?? 0;
    switch (widget.measurementUnit) {
      case 'meter':
        return value;
      case 'cm':
        return value / 100;
      case 'feet':
        return value / 3.28084;
      default:
        return value;
    }
  }

  String _getUnitLabel() {
    switch (widget.measurementUnit) {
      case 'meter':
        return 'm';
      case 'cm':
        return 'cm';
      case 'feet':
        return 'ft';
      default:
        return 'm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Edit Zone', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Zone Name',
                    labelStyle: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            // Unit toggle switch
            Row(
              children: [
                const Text('Use Real Units',
                    style: TextStyle(color: Colors.grey)),
                const Spacer(),
                Switch(
                  value: _useRealUnits,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        // Convert from pixels to real units
                        final widthPx =
                            double.tryParse(_widthController.text) ??
                                widget.zone.width;
                        final heightPx =
                            double.tryParse(_heightController.text) ??
                                widget.zone.height;
                        final widthReal = widthPx * widget.mapScale;
                        final heightReal = heightPx * widget.mapScale;
                        _widthController.text = _formatRealValue(widthReal);
                        _heightController.text = _formatRealValue(heightReal);
                      } else {
                        // Convert from real units to pixels
                        final widthReal =
                            _parseRealValue(_widthController.text);
                        final heightReal =
                            _parseRealValue(_heightController.text);
                        _widthController.text =
                            (widthReal / widget.mapScale).toInt().toString();
                        _heightController.text =
                            (heightReal / widget.mapScale).toInt().toString();
                      }
                      _useRealUnits = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Width input
            TextField(
                controller: _widthController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: _useRealUnits
                        ? 'Width (${_getUnitLabel()})'
                        : 'Width (pixels)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: _useRealUnits ? 'e.g., 5.00' : 'e.g., 200',
                    hintStyle: const TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            // Height input
            TextField(
                controller: _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: _useRealUnits
                        ? 'Height (${_getUnitLabel()})'
                        : 'Height (pixels)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: _useRealUnits ? 'e.g., 3.75' : 'e.g., 150',
                    hintStyle: const TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            // Preview calculation
            if (_useRealUnits)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Real-world Size:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_widthController.text} ${_getUnitLabel()} × ${_heightController.text} ${_getUnitLabel()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text('Color:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                children: [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.red
                ]
                    .map((color) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: _selectedColor == color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3)))))
                    .toList()),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              widget.zone.name =
                  _nameController.text.isEmpty ? 'Zone' : _nameController.text;

              // Parse dimensions based on unit mode
              if (_useRealUnits) {
                // Convert from real units to pixels
                final widthReal = _parseRealValue(_widthController.text);
                final heightReal = _parseRealValue(_heightController.text);
                widget.zone.width = widthReal / widget.mapScale;
                widget.zone.height = heightReal / widget.mapScale;
              } else {
                // Direct pixel input
                widget.zone.width =
                    double.tryParse(_widthController.text) ?? widget.zone.width;
                widget.zone.height = double.tryParse(_heightController.text) ??
                    widget.zone.height;
              }

              widget.zone.color = _selectedColor;
              widget.onEdit();
              Navigator.pop(context);
            },
            child: const Text('Save')),
      ],
    );
  }
}

class _AddAnchorDialog extends StatefulWidget {
  final Offset? position;
  final Function(MapAnchor) onAdd;
  const _AddAnchorDialog({this.position, required this.onAdd});
  @override
  State<_AddAnchorDialog> createState() => _AddAnchorDialogState();
}

class _AddAnchorDialogState extends State<_AddAnchorDialog> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title:
          const Text('Add UWB Anchor', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _idController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Anchor ID (e.g., A001)',
                  labelStyle: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Anchor Name',
                  labelStyle: TextStyle(color: Colors.grey))),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              final position = widget.position ?? const Offset(150, 150);
              widget.onAdd(MapAnchor(
                  id: _idController.text.isEmpty
                      ? 'A${DateTime.now().millisecondsSinceEpoch % 1000}'
                      : _idController.text,
                  name: _nameController.text.isEmpty
                      ? 'Anchor'
                      : _nameController.text,
                  x: position.dx - 25,
                  y: position.dy - 25));
              Navigator.pop(context);
            },
            child: const Text('Add')),
      ],
    );
  }
}

class _EditAnchorDialog extends StatefulWidget {
  final MapAnchor anchor;
  final VoidCallback onEdit;
  const _EditAnchorDialog({required this.anchor, required this.onEdit});
  @override
  State<_EditAnchorDialog> createState() => _EditAnchorDialogState();
}

class _EditAnchorDialogState extends State<_EditAnchorDialog> {
  late TextEditingController _idController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.anchor.id);
    _nameController = TextEditingController(text: widget.anchor.name);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title:
          const Text('Edit UWB Anchor', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _idController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Anchor ID',
                  labelStyle: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Anchor Name',
                  labelStyle: TextStyle(color: Colors.grey))),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              widget.anchor.id = _idController.text.isEmpty
                  ? widget.anchor.id
                  : _idController.text;
              widget.anchor.name = _nameController.text.isEmpty
                  ? widget.anchor.name
                  : _nameController.text;
              widget.onEdit();
              Navigator.pop(context);
            },
            child: const Text('Save')),
      ],
    );
  }
}

class _EditTagDialog extends StatefulWidget {
  final MapTag tag;
  final Function(MapTag) onEdit;
  const _EditTagDialog({required this.tag, required this.onEdit});
  @override
  State<_EditTagDialog> createState() => _EditTagDialogState();
}

class _EditTagDialogState extends State<_EditTagDialog> {
  late TextEditingController _idController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.tag.id);
    _nameController = TextEditingController(text: widget.tag.name);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: Text('Edit ${widget.tag.type.label}',
          style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _idController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: '${widget.tag.type.label} ID',
                  labelStyle: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: '${widget.tag.type.label} Name',
                  labelStyle: const TextStyle(color: Colors.grey))),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              // Create new tag with updated values
              final updatedTag = MapTag(
                id: _idController.text.isEmpty
                    ? widget.tag.id
                    : _idController.text,
                name: _nameController.text.isEmpty
                    ? widget.tag.name
                    : _nameController.text,
                x: widget.tag.x,
                y: widget.tag.y,
                type: widget.tag.type,
              );
              widget.onEdit(updatedTag);
              Navigator.pop(context);
            },
            child: const Text('Save')),
      ],
    );
  }
}

class _EditDoorDialog extends StatefulWidget {
  final MapDoor door;
  final VoidCallback onEdit;
  const _EditDoorDialog({required this.door, required this.onEdit});
  @override
  State<_EditDoorDialog> createState() => _EditDoorDialogState();
}

class _EditDoorDialogState extends State<_EditDoorDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.door.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Edit Door', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _nameController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
            labelText: 'Door Name', labelStyle: TextStyle(color: Colors.grey)),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              widget.door.name = _nameController.text.isEmpty
                  ? widget.door.name
                  : _nameController.text;
              widget.onEdit();
              Navigator.pop(context);
            },
            child: const Text('Save')),
      ],
    );
  }
}

class _MapConfigDialog extends StatefulWidget {
  final double scale;
  final String unit;
  final bool showMeasurements;
  final Function(double, String, bool) onSave;

  const _MapConfigDialog({
    required this.scale,
    required this.unit,
    required this.showMeasurements,
    required this.onSave,
  });

  @override
  State<_MapConfigDialog> createState() => _MapConfigDialogState();
}

class _MapConfigDialogState extends State<_MapConfigDialog> {
  late TextEditingController _scaleController;
  late String _selectedUnit;
  late bool _showMeasurements;

  @override
  void initState() {
    super.initState();
    _scaleController = TextEditingController(text: widget.scale.toString());
    _selectedUnit = widget.unit;
    _showMeasurements = widget.showMeasurements;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Map Configuration',
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Scale (1 pixel = ? meters)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _scaleController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Scale (e.g., 0.025)',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: '0.025',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Measurement Unit',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedUnit,
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'meter', child: Text('Meters (m)')),
                DropdownMenuItem(value: 'cm', child: Text('Centimeters (cm)')),
                DropdownMenuItem(value: 'feet', child: Text('Feet (ft)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedUnit = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _showMeasurements,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _showMeasurements = value ?? true;
                    });
                  },
                ),
                const Text(
                  'Show measurements on elements',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final scale =
                double.tryParse(_scaleController.text) ?? widget.scale;
            widget.onSave(scale, _selectedUnit, _showMeasurements);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditWallDialog extends StatefulWidget {
  final MapWall wall;
  final double mapScale;
  final String measurementUnit;
  final VoidCallback onEdit;

  const _EditWallDialog({
    required this.wall,
    required this.mapScale,
    required this.measurementUnit,
    required this.onEdit,
  });

  @override
  State<_EditWallDialog> createState() => _EditWallDialogState();
}

class _EditWallDialogState extends State<_EditWallDialog> {
  late TextEditingController _x1Controller;
  late TextEditingController _y1Controller;
  late TextEditingController _x2Controller;
  late TextEditingController _y2Controller;

  @override
  void initState() {
    super.initState();
    _x1Controller =
        TextEditingController(text: widget.wall.x1.toStringAsFixed(1));
    _y1Controller =
        TextEditingController(text: widget.wall.y1.toStringAsFixed(1));
    _x2Controller =
        TextEditingController(text: widget.wall.x2.toStringAsFixed(1));
    _y2Controller =
        TextEditingController(text: widget.wall.y2.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _x1Controller.dispose();
    _y1Controller.dispose();
    _x2Controller.dispose();
    _y2Controller.dispose();
    super.dispose();
  }

  String _calculateLength() {
    final x1 = double.tryParse(_x1Controller.text) ?? widget.wall.x1;
    final y1 = double.tryParse(_y1Controller.text) ?? widget.wall.y1;
    final x2 = double.tryParse(_x2Controller.text) ?? widget.wall.x2;
    final y2 = double.tryParse(_y2Controller.text) ?? widget.wall.y2;

    final dx = x2 - x1;
    final dy = y2 - y1;
    final lengthPx = (dx * dx + dy * dy).abs().toDouble();
    final realSize = lengthPx * widget.mapScale;

    switch (widget.measurementUnit) {
      case 'meter':
        return '${realSize.toStringAsFixed(2)}m';
      case 'cm':
        return '${(realSize * 100).toStringAsFixed(0)}cm';
      case 'feet':
        return '${(realSize * 3.28084).toStringAsFixed(2)}ft';
      default:
        return '${realSize.toStringAsFixed(2)}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Edit Wall', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Point',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _x1Controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'X1',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _y1Controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Y1',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'End Point',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _x2Controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'X2',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _y2Controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Y2',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.straighten, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Length: ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    _calculateLength(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: You can also drag the blue/red endpoints on the map',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.wall.x1 =
                double.tryParse(_x1Controller.text) ?? widget.wall.x1;
            widget.wall.y1 =
                double.tryParse(_y1Controller.text) ?? widget.wall.y1;
            widget.wall.x2 =
                double.tryParse(_x2Controller.text) ?? widget.wall.x2;
            widget.wall.y2 =
                double.tryParse(_y2Controller.text) ?? widget.wall.y2;
            widget.onEdit();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EditDistanceLineDialog extends StatefulWidget {
  final MapDistanceLine line;
  final double mapScale;
  final String measurementUnit;
  final VoidCallback onEdit;

  const _EditDistanceLineDialog({
    required this.line,
    required this.mapScale,
    required this.measurementUnit,
    required this.onEdit,
  });

  @override
  State<_EditDistanceLineDialog> createState() =>
      _EditDistanceLineDialogState();
}

class _EditDistanceLineDialogState extends State<_EditDistanceLineDialog> {
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.line.label ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _calculateDistance() {
    final dx = widget.line.endPoint.dx - widget.line.startPoint.dx;
    final dy = widget.line.endPoint.dy - widget.line.startPoint.dy;
    final lengthPx = (dx * dx + dy * dy).abs().toDouble();
    final realSize = lengthPx * widget.mapScale;

    switch (widget.measurementUnit) {
      case 'meter':
        return '${realSize.toStringAsFixed(2)}m';
      case 'cm':
        return '${(realSize * 100).toStringAsFixed(0)}cm';
      case 'feet':
        return '${(realSize * 3.28084).toStringAsFixed(2)}ft';
      default:
        return '${realSize.toStringAsFixed(2)}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Edit Distance Line',
          style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distance Information',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Text(
                  'From: ${widget.line.startZone.name}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  'To: ${widget.line.endZone.name}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade700.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade700),
              ),
              child: Row(
                children: [
                  const Icon(Icons.straighten, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Calculated Distance: ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    _calculateDistance(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Custom Label (optional)',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Label',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Leave empty to show calculated distance',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: The distance is automatically calculated based on zone positions',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.line.label =
                _labelController.text.isEmpty ? null : _labelController.text;
            widget.onEdit();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
