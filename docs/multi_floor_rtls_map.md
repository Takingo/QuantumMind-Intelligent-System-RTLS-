# Multi-Floor RTLS Map Implementation

## Overview

This document describes the implementation of multi-floor support for the QuantumMind RTLS Map system. The new implementation allows users to create and manage multiple floors/buildings within a single facility, with each floor having its own map elements and background.

## Key Features

### 1. Flexible Map Creation
- Custom floor names (e.g., "Floor 1", "Hall A", "Basement")
- Configurable map scale (1 pixel = ? meters)
- Choice of measurement units (meters, centimeters, feet)

### 2. Multi-Floor Management
- Add/remove floors
- Switch between floors
- Rename floors
- Each floor maintains its own:
  - Background image or grid
  - Zones, walls, doors, anchors, tags
  - Distance lines
  - Map scale and measurements

### 3. Improved Dashboard
- Collapsible panels save screen space
- Click to expand for detailed information
- Active Tags, Doors, Sensors, and Alerts panels

### 4. Enhanced User Experience
- Floor selector in AppBar with visual indicators
- Intuitive floor management
- RTLS map as primary focus (80% of screen)

## Implementation Details

### Core Classes

#### MapFloor
The `MapFloor` class in [lib/models/map_element_models.dart](file:///c:/Users/posei/QuantumMind_RTLS/lib/models/map_element_models.dart) represents a single floor with all its elements:

```dart
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
}
```

#### MapBackgroundManager
The enhanced `MapBackgroundManager` in [lib/services/map_background_manager.dart](file:///c:/Users/posei/QuantumMind_RTLS/lib/services/map_background_manager.dart) now supports multiple floors:

```dart
class MapBackgroundManager {
  List<MapFloor> _floors = [];
  int _currentFloorIndex = 0;
  
  MapFloor get currentFloor => _floors[_currentFloorIndex];
  List<MapFloor> get floors => _floors;
  int get currentFloorIndex => _currentFloorIndex;
}
```

### New Screen Implementation

The new `RtlsMapWithFloorsScreen` in [lib/screens/rtls_map_with_floors.dart](file:///c:/Users/posei/QuantumMind_RTLS/lib/screens/rtls_map_with_floors.dart) provides the complete multi-floor experience.

## Usage Instructions

### Creating a New Floor
1. Click the "Layers" icon in the AppBar
2. Select "Add New Floor"
3. Enter a floor name (e.g., "Floor 2", "Basement")
4. The new floor will be created with a default grid background

### Creating a New Map with Custom Settings
1. Click the "Map" icon in the AppBar
2. Select "Create new map"
3. In the dialog, specify:
   - Floor name
   - Map scale (e.g., 0.025 for 1px = 2.5cm)
   - Measurement unit (meters, cm, feet)
4. Click "Create"

### Switching Between Floors
1. Click the "Layers" icon in the AppBar
2. Select the desired floor from the list
3. The map will update to show the selected floor's elements

### Managing Floor Elements
Each floor maintains its own set of elements:
- Add zones, walls, doors, anchors, and tags as needed
- Elements are isolated to their respective floors
- Background images can be different for each floor

### Using the Dashboard
The dashboard at the bottom has collapsible panels:
- Click any panel header to expand/collapse
- Expanded panels show detailed information
- Collapsed panels show only the count of items

## Technical Integration

### State Management
The implementation follows the existing Provider/GetX state management pattern used throughout the application.

### Data Persistence
Each floor's data is maintained in memory. For persistence across sessions, the data would need to be serialized and stored using the existing Supabase integration.

### Real-time Features
The multi-floor system is compatible with the existing RTLS real-time integration architecture.

## Future Enhancements

### Building Support
- Add building-level organization
- Support for campus-wide deployments
- Inter-building navigation

### Advanced Floor Features
- Floor elevation tracking
- Stairwell and elevator connections
- 3D visualization options

### Enhanced Dashboard
- Customizable panel layout
- Real-time alert notifications
- Performance metrics per floor

## Testing

Unit tests are provided in [test/map_floor_test.dart](file:///c:/Users/posei/QuantumMind_RTLS/test/map_floor_test.dart) to verify:
- MapFloor creation and copying
- Multi-floor management in MapBackgroundManager
- Floor switching functionality
- Edge cases (removing last floor, invalid indices)