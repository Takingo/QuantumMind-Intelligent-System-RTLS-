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

  Uint8List? _floorPlanBytes;
  bool _isEditMode = false;
  MapElement? _selectedElement;
  DrawingMode _drawingMode = DrawingMode.none;
  Offset? _wallStartPoint;
  bool _isPlacingElement = false;
  String _pendingElementType = '';
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _floorPlanBytes = null;
    _selectedElement = null;
    _wallStartPoint = null;
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
              }
            }),
          ),
        ],
      ),
      body: Column(
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
                      borderRadius: BorderRadius.circular(12), // Smaller radius
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
                                _placeElementAtPosition(details.localPosition);
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
                                      child:
                                          CustomPaint(painter: GridPainter())),
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
                                ..._tags.map((tag) => _buildTag(tag)).toList(),
                                Positioned(
                                    top: 16, right: 16, child: _buildLegend()),
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
        onTap:
            _isEditMode ? () => setState(() => _selectedElement = zone) : null,
        onDoubleTap: _isEditMode ? () => _editZone(zone) : null,
        onPanUpdate: _isEditMode
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
          child: Center(
              child: Text(zone.name,
                  style: TextStyle(
                      color: zone.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12))),
        ),
      ),
    );
  }

  Widget _buildWall(MapWall wall) {
    final isSelected = _selectedElement == wall;
    return Positioned(
      left: wall.x1 < wall.x2 ? wall.x1 : wall.x2,
      top: wall.y1 < wall.y2 ? wall.y1 : wall.y2,
      child: GestureDetector(
        onTap:
            _isEditMode ? () => setState(() => _selectedElement = wall) : null,
        onDoubleTap:
            _isEditMode ? () => _showWallInfo(wall) : null, // Added double-tap
        child: SizedBox(
          width: (wall.x2 - wall.x1).abs() + 10,
          height: (wall.y2 - wall.y1).abs() + 10,
          child: CustomPaint(painter: WallPainter(wall, isSelected)),
        ),
      ),
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
        onEdit: () {
          if (mounted) setState(() {});
        },
      ),
    );
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

  void _showWallInfo(MapWall wall) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Wall Info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: Wall',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
                'Length: ${((wall.x2 - wall.x1).abs() + (wall.y2 - wall.y1).abs()).toInt()} px',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
                'Position: (${wall.x1.toInt()}, ${wall.y1.toInt()}) → (${wall.x2.toInt()}, ${wall.y2.toInt()})',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('Tip: Select and press Delete to remove',
                style: TextStyle(color: Colors.orange, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      else if (_selectedElement is MapAnchor) _anchors.remove(_selectedElement);
      _selectedElement = null;
    });
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

enum DrawingMode { none, zone, wall, door, anchor }

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
  final VoidCallback onEdit;
  const _EditZoneDialog({required this.zone, required this.onEdit});
  @override
  State<_EditZoneDialog> createState() => _EditZoneDialogState();
}

class _EditZoneDialogState extends State<_EditZoneDialog> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone.name);
    _widthController =
        TextEditingController(text: widget.zone.width.toInt().toString());
    _heightController =
        TextEditingController(text: widget.zone.height.toInt().toString());
    _selectedColor = widget.zone.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title: const Text('Edit Zone', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Zone Name',
                    labelStyle: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            TextField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Width',
                    labelStyle: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Height',
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
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              widget.zone.name =
                  _nameController.text.isEmpty ? 'Zone' : _nameController.text;
              widget.zone.width =
                  double.tryParse(_widthController.text) ?? widget.zone.width;
              widget.zone.height =
                  double.tryParse(_heightController.text) ?? widget.zone.height;
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
