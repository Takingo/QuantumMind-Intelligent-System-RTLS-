import 'package:flutter/material.dart';
import '../services/map_background_manager.dart';
import '../models/map_element_models.dart';

/// Advanced RTLS Map Screen with Multi-Floor Support
class RtlsMapWithFloorsScreen extends StatefulWidget {
  const RtlsMapWithFloorsScreen({super.key});

  @override
  State<RtlsMapWithFloorsScreen> createState() =>
      _RtlsMapWithFloorsScreenState();
}

class _RtlsMapWithFloorsScreenState extends State<RtlsMapWithFloorsScreen> {
  late MapBackgroundManager _backgroundManager;

  bool _isEditMode = false;
  MapElement? _selectedElement;
  DrawingMode _drawingMode = DrawingMode.none;
  Offset? _wallStartPoint;
  final bool _isPlacingElement = false;
  final String _pendingElementType = '';
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
  final bool _showMeasurements = true;

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
        title: const Text('RTLS System Map'),
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
                  Text(
                    '$title ($count)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
    showDialog(
      context: context,
      builder: (context) => _FlexibleMapCreationDialog(
        onCreate: (String floorName, double scale, String unit) {
          setState(() {
            // Add new floor
            _backgroundManager.addFloor(floorName);
            _backgroundManager
                .switchToFloor(_backgroundManager.floors.length - 1);

            // Set map scale and unit
            _mapScale = scale;
            _measurementUnit = unit;

            // Create new map
            _backgroundManager.createNewMap();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New map created: $floorName'),
                backgroundColor: const Color(0xFF00FFC6),
              ),
            );
          }
        },
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

  // Placeholder methods - these would be implemented with the actual functionality
  void _importFloorPlan() {
    // Implementation would go here
  }

  void _replaceBackground() {
    // Implementation would go here
  }

  void _toggleBackgroundVisibility() {
    // Implementation would go here
  }

  void _showMapConfig() {
    // Implementation would go here
  }

  void _exportToPdf() {
    // Implementation would go here
  }

  void _handleWallDrawing(Offset localPosition) {
    // Implementation would go here
  }

  void _placeElementAtPosition(Offset localPosition) {
    // Implementation would go here
  }

  Widget _buildDrawingTools() {
    return Container(); // Placeholder
  }

  Widget _buildEditSidePanel() {
    return Container(); // Placeholder
  }

  Widget _buildZone(MapZone zone) {
    return Container(); // Placeholder
  }

  Widget _buildWall(MapWall wall) {
    return Container(); // Placeholder
  }

  Widget _buildDoor(MapDoor door) {
    return Container(); // Placeholder
  }

  Widget _buildAnchor(MapAnchor anchor) {
    return Container(); // Placeholder
  }

  Widget _buildDistanceLine(MapDistanceLine line) {
    return Container(); // Placeholder
  }

  Widget _buildTag(MapTag tag) {
    return Container(); // Placeholder
  }

  Widget _buildLegend() {
    return Container(); // Placeholder
  }
}

// New dialog for flexible map creation
class _FlexibleMapCreationDialog extends StatefulWidget {
  final Function(String, double, String) onCreate;

  const _FlexibleMapCreationDialog({required this.onCreate});

  @override
  State<_FlexibleMapCreationDialog> createState() =>
      _FlexibleMapCreationDialogState();
}

class _FlexibleMapCreationDialogState
    extends State<_FlexibleMapCreationDialog> {
  final _floorNameController = TextEditingController(text: 'Floor 1');
  final _scaleController = TextEditingController(text: '0.025');
  String _selectedUnit = 'meter';

  @override
  void dispose() {
    _floorNameController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      title:
          const Text('Create New Map', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Floor Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _floorNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'e.g., Floor 1, Hall A, Basement',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter floor name',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
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
            final scale = double.tryParse(_scaleController.text) ?? 0.025;
            widget.onCreate(
              _floorNameController.text.isEmpty
                  ? 'Floor 1'
                  : _floorNameController.text,
              scale,
              _selectedUnit,
            );
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
