import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import '../services/map_background_manager.dart';
import '../models/map_element_models.dart';

/// Advanced RTLS Map Screen
class AdvancedRtlsMapScreen extends StatefulWidget {
  const AdvancedRtlsMapScreen({super.key});

  @override
  State<AdvancedRtlsMapScreen> createState() => _AdvancedRtlsMapScreenState();
}

class _AdvancedRtlsMapScreenState extends State<AdvancedRtlsMapScreen> {
  // Use the current floor's elements instead of separate lists
  late MapBackgroundManager _backgroundManager;

  bool _isEditMode = false;
  MapElement? _selectedElement;
  DrawingMode _drawingMode = DrawingMode.none;
  Offset? _wallStartPoint;
  bool _isPlacingElement = false;
  String _pendingElementType = '';
  bool _isDisposed = false;
  MapZone? _distanceLineStartZone; // For measuring zone-to-zone distance

  // Dashboard table expansion states
  bool _isTagsExpanded = false;
  bool _isDoorsExpanded = false;
  bool _isSensorsExpanded = false;
  bool _isAlertsExpanded = false;

  // Measurement system
  double _mapScale = 0.025; // 1px = 0.025m (2.5cm)
  String _measurementUnit = 'meter'; // meter, cm, feet
  bool _showMeasurements = true;

  @override
  void initState() {
    super.initState();
    _backgroundManager = MapBackgroundManager();
  }

  // Get current floor elements
  List<MapTag> get _tags => _backgroundManager.currentFloor.tags;
  List<MapZone> get _zones => _backgroundManager.currentFloor.zones;
  List<MapWall> get _walls => _backgroundManager.currentFloor.walls;
  List<MapDoor> get _doors => _backgroundManager.currentFloor.doors;
  List<MapAnchor> get _anchors => _backgroundManager.currentFloor.anchors;
  List<MapDistanceLine> get _distanceLines =>
      _backgroundManager.currentFloor.distanceLines;

  @override
  void dispose() {
    _isDisposed = true;
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
          // Floor selector
          PopupMenuButton<int>(
            icon: const Icon(Icons.layers),
            tooltip: 'Select Floor',
            onSelected: (int result) {
              if (result == -1) {
                // Add new floor
                _showAddFloorDialog();
              } else {
                setState(() {
                  _backgroundManager.switchToFloor(result);
                });
              }
            },
            itemBuilder: (BuildContext context) {
              final List<PopupMenuEntry<int>> items = [];

              // Add floor items
              for (int i = 0; i < _backgroundManager.floors.length; i++) {
                final floor = _backgroundManager.floors[i];
                items.add(
                  PopupMenuItem<int>(
                    value: i,
                    child: ListTile(
                      leading: Icon(
                        i == _backgroundManager.currentFloorIndex
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Colors.blue,
                      ),
                      title: Text(floor.name),
                    ),
                  ),
                );
              }

              // Add divider and "Add New Floor" option
              items.add(const PopupMenuDivider());
              items.add(
                const PopupMenuItem<int>(
                  value: -1, // Special value for adding new floor
                  child: ListTile(
                    leading: Icon(Icons.add, color: Colors.green),
                    title: Text('Add New Floor'),
                  ),
                ),
              );

              return items;
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.map),
            tooltip: 'Map Source',
            onSelected: (String result) {
              switch (result) {
                case 'import':
                  _importFloorPlan();
                  break;
                case 'create':
                  _showFlexibleMapCreationDialog();
                  break;
                case 'replace':
                  _replaceBackground();
                  break;
                case 'toggle':
                  _toggleBackgroundVisibility();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload_file, color: Colors.blue),
                  title: Text('Use existing plan'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'create',
                child: ListTile(
                  leading: Icon(Icons.grid_on, color: Colors.green),
                  title: Text('Create new map'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'replace',
                child: ListTile(
                  leading: Icon(Icons.refresh, color: Colors.orange),
                  title: Text('Replace background'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'toggle',
                child: ListTile(
                  leading: Icon(Icons.visibility, color: Colors.purple),
                  title: Text('Hide/Show background'),
                ),
              ),
            ],
          ),
          IconButton(
              icon: const Icon(Icons.straighten),
              tooltip: 'Map Config',
              onPressed: _showMapConfig,),
          IconButton(
              icon: const Icon(Icons.picture_as_pdf), onPressed: _exportToPdf,),
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
              // Main map area - now takes most of the screen
              Expanded(
                flex: 4, // Give more space to the map
                child: Row(
                  children: [
                    // Side panel for edit buttons (only in edit mode)
                    if (_isEditMode) _buildEditSidePanel(),
                    // Main map area
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 4, right: 4, bottom: 4,), // Reduced margins
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius:
                              BorderRadius.circular(12), // Smaller radius
                          border: Border.all(
                              color: const Color(0xFF007AFF).withOpacity(0.3),),
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
                                        details.localPosition,);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: _backgroundManager
                                            .getBackgroundWidget(),),
                                    ..._zones
                                        .map((zone) => _buildZone(zone))
                                        ,
                                    ..._walls
                                        .map((wall) => _buildWall(wall))
                                        ,
                                    ..._doors
                                        .map((door) => _buildDoor(door))
                                        ,
                                    ..._anchors
                                        .map((anchor) => _buildAnchor(anchor))
                                        ,
                                    ..._distanceLines
                                        .map((line) => _buildDistanceLine(line))
                                        ,
                                    ..._tags
                                        .map((tag) => _buildTag(tag))
                                        ,
                                    Positioned(
                                        top: 16,
                                        right: 16,
                                        child: _buildLegend(),),
                                    if (_wallStartPoint != null)
                                      Positioned(
                                        left: _wallStartPoint!.dx - 5,
                                        top: _wallStartPoint!.dy - 5,
                                        child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,),),
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
              // Dashboard tables - smaller and expandable
              Expanded(
                flex: 1, // Give less space to dashboard
                child: _buildDashboardTables(),
              ),
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

  // New method to build dashboard tables
  Widget _buildDashboardTables() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Active Tags
                _buildExpandableDashboardCard(
                  title: 'Active Tags',
                  count: _tags.length,
                  icon: Icons.sensors,
                  isExpanded: _isTagsExpanded,
                  onToggle: () =>
                      setState(() => _isTagsExpanded = !_isTagsExpanded),
                  content: _isTagsExpanded
                      ? SizedBox(
                          width: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _tags.length,
                            itemBuilder: (context, index) {
                              final tag = _tags[index];
                              return ListTile(
                                title: Text(
                                  tag.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12,),
                                ),
                                subtitle: Text(
                                  '${tag.type.label} - ${tag.id}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10,),
                                ),
                                trailing: Icon(tag.type.icon,
                                    color: tag.type.color, size: 16,),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                ),
                // Doors
                _buildExpandableDashboardCard(
                  title: 'Doors',
                  count: _doors.length,
                  icon: Icons.sensor_door,
                  isExpanded: _isDoorsExpanded,
                  onToggle: () =>
                      setState(() => _isDoorsExpanded = !_isDoorsExpanded),
                  content: _isDoorsExpanded
                      ? SizedBox(
                          width: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _doors.length,
                            itemBuilder: (context, index) {
                              final door = _doors[index];
                              return ListTile(
                                title: Text(
                                  door.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12,),
                                ),
                                subtitle: Text(
                                  'Position: (${door.x.toStringAsFixed(0)}, ${door.y.toStringAsFixed(0)})',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10,),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                ),
                // Sensors (using anchors as sensors)
                _buildExpandableDashboardCard(
                  title: 'Sensors',
                  count: _anchors.length,
                  icon: Icons.router,
                  isExpanded: _isSensorsExpanded,
                  onToggle: () =>
                      setState(() => _isSensorsExpanded = !_isSensorsExpanded),
                  content: _isSensorsExpanded
                      ? SizedBox(
                          width: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _anchors.length,
                            itemBuilder: (context, index) {
                              final anchor = _anchors[index];
                              return ListTile(
                                title: Text(
                                  anchor.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12,),
                                ),
                                subtitle: Text(
                                  'ID: ${anchor.id} - Position: (${anchor.x.toStringAsFixed(0)}, ${anchor.y.toStringAsFixed(0)})',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10,),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                ),
                // Alerts (placeholder)
                _buildExpandableDashboardCard(
                  title: 'Alerts',
                  count: 0,
                  icon: Icons.warning,
                  isExpanded: _isAlertsExpanded,
                  onToggle: () =>
                      setState(() => _isAlertsExpanded = !_isAlertsExpanded),
                  content: _isAlertsExpanded
                      ? SizedBox(
                          width: 200,
                          child: ListView(
                            shrinkWrap: true,
                            children: const [
                              ListTile(
                                title: Text(
                                  'No alerts',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12,),
                                ),
                                subtitle: Text(
                                  'System is operating normally',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10,),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build expandable dashboard cards
  Widget _buildExpandableDashboardCard({
    required String title,
    required int count,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      width: isExpanded ? 250 : 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF007AFF).withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF00FFC6), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$title ($count)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) Expanded(child: content),
        ],
      ),
    );
  }

  // Show dialog for flexible map creation
  void _showFlexibleMapCreationDialog() {
    final floorNameController = TextEditingController(text: 'Floor 1');
    final scaleController = TextEditingController(text: _mapScale.toString());
    String selectedUnit = _measurementUnit;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title:
            const Text('Create New Map', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: floorNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Floor Name',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'e.g., Floor 1',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scaleController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Map Scale (m/px)',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'e.g., 0.025',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedUnit,
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'meter', child: Text('Meters')),
                DropdownMenuItem(value: 'cm', child: Text('Centimeters')),
                DropdownMenuItem(value: 'feet', child: Text('Feet')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedUnit = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final floorName = floorNameController.text;
              final scale = double.tryParse(scaleController.text) ?? 0.025;

              setState(() {
                // Add new floor
                _backgroundManager.addFloor(floorName);
                _backgroundManager
                    .switchToFloor(_backgroundManager.floors.length - 1);

                // Set map scale and unit
                _mapScale = scale;
                _measurementUnit = selectedUnit;

                // Create new map
                _backgroundManager.createNewMap();
              });

              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New map created: $floorName'),
                    backgroundColor: const Color(0xFF00FFC6),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Show dialog for adding new floor
  void _showAddFloorDialog() {
    final floorNameController = TextEditingController(
        text: 'Floor ${_backgroundManager.floors.length + 1}',);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title:
            const Text('Add New Floor', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: floorNameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Floor Name',
            labelStyle: TextStyle(color: Colors.grey),
            hintText: 'e.g., Floor 1, Hall A, Basement',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _backgroundManager.addFloor(floorNameController.text);
              });
              Navigator.pop(context);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Added new floor: ${floorNameController.text}'),
                    backgroundColor: const Color(0xFF00FFC6),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingTools() {
    return Container(
      height: 50, // Reduced from 60
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6,), // Reduced padding
      color: const Color(0xFF1F2937),
      child: Row(
        children: [
          const Text('Tools:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolButton(
                      'Zone', Icons.crop_square, DrawingMode.zone, Colors.blue,),
                  _buildToolButton('Wall', Icons.horizontal_rule,
                      DrawingMode.wall, Colors.grey,),
                  _buildToolButton('Door', Icons.sensor_door, DrawingMode.door,
                      Colors.brown,),
                  _buildToolButton(
                      'Anchor', Icons.router, DrawingMode.anchor, Colors.red,),
                  _buildToolButton('Distance', Icons.straighten,
                      DrawingMode.distance, Colors.yellow,),
                ],
              ),
            ),
          ),
          if (_selectedElement != null)
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: _deleteSelectedElement,),
        ],
      ),
    );
  }

  Widget _buildToolButton(
      String label, IconData icon, DrawingMode mode, Color color,) {
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

  Widget _buildEditSidePanel() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color(0xFF1F2937),
      child: Column(
        children: [
          // Elements Section
          _buildExpandableSection(
            title: 'Elements',
            isExpanded: _isElementsExpanded,
            onToggle: () =>
                setState(() => _isElementsExpanded = !_isElementsExpanded),
            content: _isElementsExpanded
                ? _buildElementsContent()
                : const SizedBox(),
          ),

          // Measurements Section
          _buildExpandableSection(
            title: 'Measurements',
            isExpanded: _isMeasurementsExpanded,
            onToggle: () => setState(
                () => _isMeasurementsExpanded = !_isMeasurementsExpanded,),
            content: _isMeasurementsExpanded
                ? _buildMeasurementsContent()
                : const SizedBox(),
          ),

          // Background Section
          _buildExpandableSection(
            title: 'Background',
            isExpanded: _isBackgroundExpanded,
            onToggle: () =>
                setState(() => _isBackgroundExpanded = !_isBackgroundExpanded),
            content: _isBackgroundExpanded
                ? _buildBackgroundContent()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // New state variables for expandable sections
  bool _isElementsExpanded = true;
  bool _isMeasurementsExpanded = true;
  bool _isBackgroundExpanded = true;

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildElementsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Elements:',
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold,),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildElementButton('Zone', Icons.crop_square, 'zone', Colors.blue),
            _buildElementButton(
                'Wall', Icons.horizontal_rule, 'wall', Colors.grey,),
            _buildElementButton(
                'Door', Icons.sensor_door, 'door', Colors.brown,),
            _buildElementButton('Anchor', Icons.router, 'anchor', Colors.red),
            _buildElementButton('Tag', Icons.local_offer, 'tag', Colors.green),
            _buildElementButton(
                'Robot', Icons.precision_manufacturing, 'robot', Colors.purple,),
            _buildElementButton(
                'Machine', Icons.settings, 'machine', Colors.orange,),
            _buildElementButton(
                'Asset', Icons.inventory_2, 'asset', Colors.cyan,),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Element Count:',
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold,),
        ),
        const SizedBox(height: 8),
        Text('Zones: ${_zones.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),),
        Text('Walls: ${_walls.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),),
        Text('Doors: ${_doors.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),),
        Text('Anchors: ${_anchors.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),),
        Text('Tags: ${_tags.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),),
      ],
    );
  }

  Widget _buildElementButton(
      String label, IconData icon, String type, Color color,) {
    return ElevatedButton.icon(
      onPressed: () => setState(() {
        _drawingMode = _getDrawingModeFromType(type);
        _isPlacingElement = true;
        _pendingElementType = type;
      }),
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  DrawingMode _getDrawingModeFromType(String type) {
    switch (type) {
      case 'zone':
        return DrawingMode.zone;
      case 'wall':
        return DrawingMode.wall;
      case 'door':
        return DrawingMode.door;
      case 'anchor':
        return DrawingMode.anchor;
      case 'distance':
        return DrawingMode.distance;
      default:
        return DrawingMode.none;
    }
  }

  Widget _buildMeasurementsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Show Measurements',
              style: TextStyle(color: Colors.white, fontSize: 14),),
          value: _showMeasurements,
          onChanged: (value) => setState(() => _showMeasurements = value),
          activeThumbColor: const Color(0xFF00FFC6),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Scale: ', style: TextStyle(color: Colors.white)),
            Expanded(
              child: Slider(
                value: _mapScale,
                min: 0.01,
                max: 0.1,
                divisions: 100,
                label: '${(_mapScale * 100).toStringAsFixed(1)} cm/px',
                onChanged: (value) => setState(() => _mapScale = value),
                activeColor: const Color(0xFF00FFC6),
              ),
            ),
          ],
        ),
        Text(
          '1px = ${(_mapScale * 100).toStringAsFixed(1)} cm',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Unit: ', style: TextStyle(color: Colors.white)),
            DropdownButton<String>(
              value: _measurementUnit,
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: const [
                DropdownMenuItem(value: 'meter', child: Text('Meters')),
                DropdownMenuItem(value: 'cm', child: Text('Centimeters')),
                DropdownMenuItem(value: 'feet', child: Text('Feet')),
              ],
              onChanged: (value) => setState(() => _measurementUnit = value!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Show Background',
              style: TextStyle(color: Colors.white, fontSize: 14),),
          value: _backgroundManager.isBackgroundVisible(),
          onChanged: (value) => setState(() => _toggleBackgroundVisibility()),
          activeThumbColor: const Color(0xFF00FFC6),
        ),
        const SizedBox(height: 8),
        if (_backgroundManager.currentFloor.backgroundImageBytes != null)
          Row(
            children: [
              const Text('Background: ', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.memory(
                  _backgroundManager.currentFloor.backgroundImageBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _importFloorPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Import', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: _replaceBackground,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9D4EDD),
                foregroundColor: Colors.white,
              ),
              child: const Text('Replace', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _backgroundManager.resetToGrid()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  // Add new element types
  MapElement _createElement(String type, Offset position) {
    switch (type) {
      case 'zone':
        return MapZone(
          name: 'Zone ${_zones.length + 1}',
          x: position.dx,
          y: position.dy,
          width: 100,
          height: 100,
          color: Colors.blue,
        );
      case 'wall':
        return MapWall(
          x1: position.dx,
          y1: position.dy,
          x2: position.dx + 100,
          y2: position.dy,
        );
      case 'door':
        return MapDoor(
          name: 'Door ${_doors.length + 1}',
          x: position.dx,
          y: position.dy,
        );
      case 'anchor':
        return MapAnchor(
          id: 'A${DateTime.now().millisecondsSinceEpoch % 1000}',
          name: 'Anchor ${_anchors.length + 1}',
          x: position.dx,
          y: position.dy,
        );
      case 'tag':
        return MapTag(
          id: 'T${DateTime.now().millisecondsSinceEpoch % 1000}',
          name: 'Tag ${_tags.length + 1}',
          x: position.dx,
          y: position.dy,
          type: TagType.worker,
        );
      case 'robot':
        return MapTag(
          id: 'R${DateTime.now().millisecondsSinceEpoch % 1000}',
          name: 'Robot ${_tags.where((t) => t.id.startsWith('R')).length + 1}',
          x: position.dx,
          y: position.dy,
          type: TagType.vehicle, // Using vehicle type for robot
        );
      case 'machine':
        return MapZone(
          name:
              'Machine ${_zones.where((z) => z.name.startsWith('Machine')).length + 1}',
          x: position.dx,
          y: position.dy,
          width: 80,
          height: 80,
          color: Colors.orange,
        );
      case 'asset':
        return MapTag(
          id: 'AS${DateTime.now().millisecondsSinceEpoch % 1000}',
          name: 'Asset ${_tags.where((t) => t.id.startsWith('AS')).length + 1}',
          x: position.dx,
          y: position.dy,
          type: TagType.asset,
        );
      default:
        throw Exception('Unknown element type: $type');
    }
  }

  // Improve the build methods for better visualization
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
            color: zone.color.withOpacity(0.3),
            border: Border.all(
                color: isSelected ? Colors.red : zone.color,
                width: isSelected ? 3 : 2,),
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
                            horizontal: 6, vertical: 2,),
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
                                  size: 10, color: Colors.white,),
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
                            horizontal: 2, vertical: 6,),
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
                                  size: 10, color: Colors.white,),
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
    // Calculate the position and dimensions based on the two points
    final left = wall.x1 < wall.x2 ? wall.x1 : wall.x2;
    final top = wall.y1 < wall.y2 ? wall.y1 : wall.y2;
    final width = (wall.x2 - wall.x1).abs();
    const height = 4.0; // Fixed height for wall visualization

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap:
            _isEditMode ? () => setState(() => _selectedElement = wall) : null,
        onDoubleTap: _isEditMode ? () => _editWall(wall) : null,
        onPanUpdate: _isEditMode
            ? (details) => setState(() {
                  wall.x1 += details.delta.dx;
                  wall.y1 += details.delta.dy;
                  wall.x2 += details.delta.dx;
                  wall.y2 += details.delta.dy;
                })
            : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.grey[700]!,
            border: Border.all(
                color: isSelected ? Colors.red : Colors.grey[700]!,
                width: isSelected ? 3 : 2,),
            borderRadius: BorderRadius.circular(2),
          ),
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
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.brown,
            border: Border.all(
                color: isSelected ? Colors.red : Colors.brown,
                width: isSelected ? 3 : 2,),
            borderRadius: BorderRadius.circular(4),
            shape: BoxShape.rectangle,
          ),
          child:
              const Icon(Icons.door_front_door, color: Colors.white, size: 16),
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
            : null,
        onDoubleTap: _isEditMode ? () => _editAnchor(anchor) : null,
        onPanUpdate: _isEditMode
            ? (details) => setState(() {
                  anchor.x += details.delta.dx;
                  anchor.y += details.delta.dy;
                })
            : null,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.red,
            border: Border.all(
                color: isSelected ? Colors.red : Colors.red,
                width: isSelected ? 3 : 2,),
            borderRadius: BorderRadius.circular(8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.router, color: Colors.white, size: 12),
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
        onTap:
            _isEditMode ? () => setState(() => _selectedElement = tag) : null,
        onDoubleTap: _isEditMode ? () => _editTag(tag) : null,
        onPanUpdate: _isEditMode
            ? (details) => setState(() {
                  tag.x += details.delta.dx;
                  tag.y += details.delta.dy;
                })
            : null,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : tag.type.color,
            border: Border.all(
                color: isSelected ? Colors.red : tag.type.color,
                width: isSelected ? 3 : 2,),
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.circle,
          ),
          child: Icon(tag.type.icon, color: Colors.white, size: 14),
        ),
      ),
    );
  }

  void _handleWallDrawing(Offset position) {
    if (_wallStartPoint == null) {
      setState(() {
        _wallStartPoint = position;
      });
    } else {
      final wall = MapWall(
        x1: _wallStartPoint!.dx,
        y1: _wallStartPoint!.dy,
        x2: position.dx,
        y2: position.dy,
      );
      setState(() {
        _backgroundManager.currentFloor.walls.add(wall);
        _wallStartPoint = null;
      });
    }
  }

  void _placeElementAtPosition(Offset position) {
    if (_pendingElementType.isNotEmpty) {
      final element = _createElement(_pendingElementType, position);
      setState(() {
        // Add element to the appropriate list based on its type
        if (element is MapZone) {
          _backgroundManager.currentFloor.zones.add(element);
        } else if (element is MapWall) {
          _backgroundManager.currentFloor.walls.add(element);
        } else if (element is MapDoor) {
          _backgroundManager.currentFloor.doors.add(element);
        } else if (element is MapAnchor) {
          _backgroundManager.currentFloor.anchors.add(element);
        } else if (element is MapTag) {
          _backgroundManager.currentFloor.tags.add(element);
        }
        _pendingElementType = '';
      });
    }
  }

  void _deleteSelectedElement() {
    setState(() {
      if (_selectedElement is MapZone) {
        _backgroundManager.currentFloor.zones.remove(_selectedElement);
      } else if (_selectedElement is MapWall) {
        _backgroundManager.currentFloor.walls.remove(_selectedElement);
      } else if (_selectedElement is MapDoor) {
        _backgroundManager.currentFloor.doors.remove(_selectedElement);
      } else if (_selectedElement is MapAnchor) {
        _backgroundManager.currentFloor.anchors.remove(_selectedElement);
      } else if (_selectedElement is MapDistanceLine) {
        _backgroundManager.currentFloor.distanceLines.remove(_selectedElement);
      } else if (_selectedElement is MapTag) {
        _backgroundManager.currentFloor.tags.remove(_selectedElement);
      }
      _selectedElement = null;
    });
  }

  void _handleDistanceLineMeasurement(MapZone zone) {
    if (_distanceLineStartZone == null) {
      setState(() {
        _distanceLineStartZone = zone;
      });
    } else {
      final distance = _calculateDistance(_distanceLineStartZone!, zone);
      setState(() {
        _backgroundManager.currentFloor.distanceLines.add(
          MapDistanceLine(
            startZone: _distanceLineStartZone!,
            endZone: zone,
          ),
        );
        _distanceLineStartZone = null;
      });
    }
  }

  void _toggleBackgroundVisibility() {
    setState(() {
      _backgroundManager.toggleBackgroundVisibility();
    });
  }

  void _importFloorPlan() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _backgroundManager.currentFloor.backgroundImageBytes =
            Uint8List.fromList(bytes);
        _backgroundManager.currentFloor.isManualGrid = false;
      });
    }
  }

  void _replaceBackground() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _backgroundManager.currentFloor.backgroundImageBytes =
            Uint8List.fromList(bytes);
        _backgroundManager.currentFloor.isManualGrid = false;
      });
    }
  }

  void _exportToPdf() async {
    final pdf = pw.Document();

    // Export current floor data to PDF
    final filePath = await _backgroundManager.exportToPdf(
      zones: _zones,
      walls: _walls,
      doors: _doors,
      anchors: _anchors,
      tags: _tags,
      distanceLines: _distanceLines,
    );

    if (filePath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported to: $filePath'),
          backgroundColor: const Color(0xFF00FFC6),
        ),
      );
    }
  }

  void _showMapConfig() {
    // Show map configuration dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Map Configuration',
            style: TextStyle(color: Colors.white),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Map Scale (1 pixel = ? meters)',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller:
                        TextEditingController(text: _mapScale.toString()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Scale (e.g., 0.025)',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: '0.025',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (value) {
                      final scale = double.tryParse(value) ?? 0.025;
                      setState(() {
                        _mapScale = scale;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Measurement Unit',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                DropdownButton<String>(
                  value: _measurementUnit,
                  dropdownColor: const Color(0xFF1F2937),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'meter', child: Text('Meters (m)')),
                    DropdownMenuItem(
                        value: 'cm', child: Text('Centimeters (cm)'),),
                    DropdownMenuItem(value: 'feet', child: Text('Feet (ft)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _measurementUnit = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _quickEditZoneDimension(MapZone zone, String dimension) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Zone Dimension',
            style: TextStyle(color: Colors.white),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit ${dimension == 'width' ? 'Width' : 'Height'}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(
                  text: dimension == 'width'
                      ? zone.width.toString()
                      : zone.height.toString(),),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Length (e.g., 100)',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: '100',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                final length = double.tryParse(value) ?? 100;
                setState(() {
                  if (dimension == 'width') {
                    zone.width = length;
                  } else {
                    zone.height = length;
                  }
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editZone(MapZone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Zone', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Zone Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: zone.name),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter zone name',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  zone.name = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Zone Color',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: zone.color.value.toRadixString(16),),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Color (hex)',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'e.g., 0xFF00FFC6',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (value) {
                      final color = int.tryParse('0x$value') ?? Colors.blue;
                      setState(() {
                        zone.color = Color(color as int);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: zone.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editWall(MapWall wall) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Wall', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wall Properties',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              'Walls do not support custom colors',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editDoor(MapDoor door) {
    final nameController = TextEditingController(text: door.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Door', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Door Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter door name',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Find the index of the door in the list
                final index =
                    _backgroundManager.currentFloor.doors.indexOf(door);
                if (index != -1) {
                  // Replace the door with a new instance with updated values
                  _backgroundManager.currentFloor.doors[index] = MapDoor(
                    name: nameController.text,
                    x: door.x,
                    y: door.y,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editAnchor(MapAnchor anchor) {
    final nameController = TextEditingController(text: anchor.name);
    final idController = TextEditingController(text: anchor.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Anchor', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Anchor ID',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'ID',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter anchor ID',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Anchor Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter anchor name',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Find the index of the anchor in the list
                final index =
                    _backgroundManager.currentFloor.anchors.indexOf(anchor);
                if (index != -1) {
                  // Replace the anchor with a new instance with updated values
                  _backgroundManager.currentFloor.anchors[index] = MapAnchor(
                    id: idController.text,
                    name: nameController.text,
                    x: anchor.x,
                    y: anchor.y,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTag(MapTag tag) {
    final nameController = TextEditingController(text: tag.name);
    TagType selectedType = tag.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Tag', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tag Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter tag name',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tag Type',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            DropdownButton<TagType>(
              value: selectedType,
              dropdownColor: const Color(0xFF1F2937),
              style: const TextStyle(color: Colors.white),
              items: TagType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, color: type.color, size: 16),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Find the index of the tag in the list
                final index = _backgroundManager.currentFloor.tags.indexOf(tag);
                if (index != -1) {
                  // Replace the tag with a new instance with updated values
                  _backgroundManager.currentFloor.tags[index] = MapTag(
                    id: tag.id,
                    name: nameController.text,
                    x: tag.x,
                    y: tag.y,
                    type: selectedType,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Add the missing methods that were cut off in the corrupted file
  double _calculateDistance(MapZone startZone, MapZone endZone) {
    final startX = startZone.x + startZone.width / 2;
    final startY = startZone.y + startZone.height / 2;
    final endX = endZone.x + endZone.width / 2;
    final endY = endZone.y + endZone.height / 2;
    final distance = math.sqrt(
        ((endX - startX) * (endX - startX) + (endY - startY) * (endY - startY))
            .toDouble(),);
    return distance * _mapScale; // Apply scale to get real distance
  }

  Widget _buildDistanceLine(MapDistanceLine line) {
    final isSelected = _selectedElement == line;
    final startPoint = line.startPoint;
    final endPoint = line.endPoint;

    // Calculate angle and length for the line
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx);

    // Calculate real distance
    final realDistance = length * _mapScale;
    final distanceText = _formatDistance(realDistance);

    return Positioned(
      left: startPoint.dx,
      top: startPoint.dy,
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: _isEditMode
              ? () => setState(() => _selectedElement = line)
              : null,
          onDoubleTap: _isEditMode ? () => _editDistanceLine(line) : null,
          child: Container(
            width: length,
            height: 20,
            color: Colors.transparent,
            child: Stack(
              children: [
                // Line
                Positioned(
                  left: 0,
                  top: 10,
                  child: Container(
                    width: length,
                    height: isSelected ? 3 : 2,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.yellow.shade700,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                // Distance label
                if (_showMeasurements)
                  Positioned(
                    left: length / 2 - 30,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2,),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        distanceText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    switch (_measurementUnit) {
      case 'meter':
        return '${meters.toStringAsFixed(2)} m';
      case 'cm':
        return '${(meters * 100).toStringAsFixed(0)} cm';
      case 'feet':
        return '${(meters * 3.28084).toStringAsFixed(2)} ft';
      default:
        return '${meters.toStringAsFixed(2)} m';
    }
  }

  void _editDistanceLine(MapDistanceLine line) {
    final TextEditingController labelController = TextEditingController(
      text: line.label ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Edit Distance Line',
            style: TextStyle(color: Colors.white),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Label (optional)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: labelController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Label',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter label',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Distance: ${_formatDistance(_calculateDistance(line.startZone, line.endZone))}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                line.label =
                    labelController.text.isEmpty ? null : labelController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _toRealSize(double pixels) {
    // Convert pixels to real size based on map scale
    return '${(pixels * _mapScale).toStringAsFixed(2)} $_measurementUnit';
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF007AFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Zone',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 50,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Wall',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Door',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Anchor',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
