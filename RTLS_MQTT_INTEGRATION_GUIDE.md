# 🚀 RTLS Real-Time MQTT Integration - Complete Guide

## ✅ Implementation Summary

The existing QuantumMind_RTLS app has been **enhanced** (not rebuilt) with real-time MQTT integration for:

- **Real-time tag position tracking** on RTLS map
- **Live door status** with color-coded indicators
- **Synchronized control** between map and door control screen
- **Calibration overlay** for floor plan alignment

---

## 📦 New Components Added

### 1. **RtlsProvider** (`lib/providers/rtls_provider.dart`)
**Purpose**: State management for real-time MQTT data

**Features**:
- Listens to MQTT topics for tag positions and door status
- Manages tag position cache with timestamps
- Provides door control methods (open/close/lock)
- Automatic data updates via ChangeNotifier

**Key Methods**:
```dart
initialize()                          // Connect to MQTT
getTagPosition(tagId)                 // Get real-time tag position
getDoorStatus(doorId)                 // Get door status
openDoor(doorId, duration)            // Send door open command
closeDoor(doorId)                     // Send door close command
lockDoor(doorId)                      // Send door lock command
```

---

### 2. **Enhanced Door Control Screen** (`lib/screens/door_control_screen.dart`)
**Updates**: Complete rewrite as StatefulWidget with Provider integration

**New Features**:
- ✅ **Live status indicator** (Online/Offline)
- ✅ **Real-time door state** (OPEN/CLOSED/LOCKED/OPENING/CLOSING)
- ✅ **Animated status badges** with color coding
- ✅ **Loading indicators** during transitions
- ✅ **Timestamp display** ("Updated 5s ago")
- ✅ **3 action buttons**: Open, Close, Lock

**Visual Changes**:
- Doors change color based on status (Green=Open, Red=Locked, Grey=Closed)
- Progress spinner during opening/closing
- Glowing border effect matching door state

---

### 3. **RTLS Realtime Integration Mixin** (`lib/screens/rtls_realtime_integration.dart`)

#### **RtlsRealtimeIntegration Mixin**
**Purpose**: Add to existing `_AdvancedRtlsMapScreenState`

**Features**:
- Periodic position updates (500ms interval)
- Coordinate conversion (meters → pixels)
- Door status color mapping
- Real-time tag position cache

**Usage**:
```dart
class _AdvancedRtlsMapScreenState extends State<AdvancedRtlsMapScreen> 
    with RtlsRealtimeIntegration {
  
  @override
  void initState() {
    super.initState();
    initializeRealtimeIntegration();
  }
  
  @override
  void dispose() {
    disposeRealtimeIntegration();
    super.dispose();
  }
}
```

#### **CalibrationOverlay Widget**
**Purpose**: Align floor plan with real-world coordinates

**Features**:
- Two-point calibration system
- Visual point markers (Blue & Red)
- Real-world coordinate inputs (meters)
- Automatic scale calculation
- Coordinate conversion utilities

**How It Works**:
1. User taps two known points on map
2. Enters real-world coordinates (meters)
3. System calculates pixel-to-meter scale
4. All positions auto-convert using calibration

---

## 🔌 MQTT Topic Structure

### Existing Topics (from `constants.dart`):

```
quantummind/rtls/position    → Tag position updates
quantummind/door/control     → Door commands (publish)
quantummind/door/control/status → Door status updates (subscribe)
quantummind/sensor/data      → Sensor readings
```

### Message Formats:

#### **Position Update** (Subscribe: `quantummind/rtls/position`)
```json
{
  "tag_id": "W001",
  "x": 15.5,
  "y": 8.2,
  "z": 0.0,
  "timestamp": "2025-10-22T14:30:00Z"
}
```

#### **Door Status Update** (Subscribe: `quantummind/door/control/status`)
```json
{
  "door_id": "door_1",
  "status": "open",
  "locked": false,
  "timestamp": "2025-10-22T14:30:00Z"
}
```

#### **Door Control Command** (Publish: `quantummind/door/control`)
```json
{
  "command": "open",
  "door_id": "door_1",
  "duration": 3000,
  "timestamp": "2025-10-22T14:30:00Z"
}
```

---

## 📝 Integration Steps

### Step 1: Add Provider to `main.dart`

```dart
import 'package:provider/provider.dart';
import 'providers/rtls_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RtlsProvider()..initialize()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Step 2: Integrate Mixin in RTLS Map

**File**: `lib/screens/advanced_rtls_map_screen.dart`

**Add to class declaration**:
```dart
import 'rtls_realtime_integration.dart';

class _AdvancedRtlsMapScreenState extends State<AdvancedRtlsMapScreen> 
    with RtlsRealtimeIntegration {
  
  @override
  void initState() {
    super.initState();
    initializeRealtimeIntegration(); // ← Add this
  }
  
  @override
  void dispose() {
    disposeRealtimeIntegration(); // ← Add this
    super.dispose();
  }
  
  // Override to match your map scale
  @override
  double get mapScalePixelsPerMeter => 1.0 / _mapScale; // Convert your scale
}
```

### Step 3: Update Door Rendering

**In `_buildDoor()` method**, add color animation:

```dart
Widget _buildDoor(MapDoor door) {
  final isSelected = _selectedElement == door;
  final realtimeColor = getDoorStatusColor(door.name); // ← Add this
  
  return Positioned(
    left: door.x,
    top: door.y,
    child: GestureDetector(
      onTap: _isEditMode ? () => setState(() => _selectedElement = door) : null,
      onDoubleTap: _isEditMode ? () => _editDoor(door) : null,
      onPanUpdate: _isEditMode
          ? (details) => setState(() {
                door.x += details.delta.dx;
                door.y += details.delta.dy;
              })
          : null,
      child: AnimatedContainer( // ← Changed from Container
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.red : realtimeColor, // ← Use realtime color
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: realtimeColor.withOpacity(0.5), // ← Glowing effect
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CustomPaint(
          painter: DoorPainter(isSelected), 
          size: const Size(60, 60),
        ),
      ),
    ),
  );
}
```

### Step 4: Add Real-Time Tag Rendering

**In `_buildTag()` method**, integrate real-time positions:

```dart
Widget _buildTag(MapTag tag) {
  final isSelected = _selectedElement == tag;
  
  // Get realtime position if available
  final realtimePos = getRealtimeTagPosition(tag.id);
  final displayX = realtimePos?.dx ?? tag.x;
  final displayY = realtimePos?.dy ?? tag.y;
  
  return AnimatedPositioned( // ← Changed from Positioned
    duration: const Duration(milliseconds: 300),
    left: displayX,
    top: displayY,
    child: GestureDetector(
      // ... rest of code
    ),
  );
}
```

### Step 5: Add Calibration Button

**In AppBar actions**:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.straighten),
    tooltip: 'Calibrate Map',
    onPressed: _showCalibration,
  ),
  // ... other buttons
],

// Add method
void _showCalibration() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CalibrationOverlay(
      onClose: () => Navigator.pop(context),
      onSave: (points) {
        setState(() {
          // Update map scale based on calibration
          _mapScale = 1.0 / points.scale;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calibration saved!'),
            backgroundColor: Color(0xFF00FFC6),
          ),
        );
      },
    ),
  );
}
```

---

## 🎨 Visual Enhancements

### Door Status Colors:
| Status | Color | Hex |
|--------|-------|-----|
| Open | Green | #00FFC6 |
| Closed | Grey | #808080 |
| Locked | Red | #FF5252 |
| Opening | Orange | #FF9800 |
| Closing | Amber | #FFC107 |

### Tag Position Animation:
- **Smooth transitions** (300ms) when position updates
- **Trail effect** possible by keeping position history
- **Pulse animation** for recently updated tags

---

## 🔧 Configuration

### MQTT Broker Setup
**File**: `lib/utils/constants.dart`

```dart
static const String mqttBroker = '192.168.1.100'; // Your broker IP
static const int mqttPort = 1883;
```

### Map Scale Calibration
**Default**: 1 pixel = 0.025 meters (40 pixels/meter)

**Adjust in** `advanced_rtls_map_screen.dart`:
```dart
double _mapScale = 0.025; // meters per pixel
```

---

## 📊 Data Flow

```
ESP32-DW3000 (UWB Tags)
    ↓ MQTT
MQTT Broker
    ↓ Subscribe
MqttService
    ↓ Stream
RtlsProvider (ChangeNotifier)
    ↓ Consumer/Listen
RTLS Map Screen + Door Control Screen
    ↓ Visual Updates
UI (Animated Doors, Moving Tags)
```

---

## 🧪 Testing

### Test Real-Time Updates

1. **Start MQTT Broker**
   ```bash
   mosquitto -v
   ```

2. **Publish Test Position**
   ```bash
   mosquitto_pub -h localhost -t "quantummind/rtls/position" -m '{"tag_id":"W001","x":10.5,"y":5.2,"timestamp":"2025-10-22T14:00:00Z"}'
   ```

3. **Publish Test Door Status**
   ```bash
   mosquitto_pub -h localhost -t "quantummind/door/control/status" -m '{"door_id":"door_1","status":"open","locked":false,"timestamp":"2025-10-22T14:00:00Z"}'
   ```

4. **Expected Result**:
   - Tag W001 moves to position (10.5m, 5.2m) on map
   - Door 1 turns green in both map and door control screen

---

## 🚨 Troubleshooting

### Issue: Tags not moving
**Solution**: Check MQTT connection status
```dart
final rtls = context.read<RtlsProvider>();
print('Connected: ${rtls.isConnected}');
print('Tag positions: ${rtls.tagPositions}');
```

### Issue: Doors not changing color
**Solution**: Verify door ID matching
- Map door names must match `door_id` in MQTT messages
- Default IDs: `door_1`, `door_2`, `door_3`, `door_4`

### Issue: Positions incorrect
**Solution**: Run calibration
1. Click calibration button
2. Select two known points
3. Enter real coordinates
4. Save calibration

---

## 📚 API Reference

### RtlsProvider Methods

```dart
// Connection
Future<bool> initialize()           // Connect to MQTT
bool get isConnected               // Check connection

// Data Access
TagPosition? getTagPosition(String tagId)
DoorStatus? getDoorStatus(String doorId)
Map<String, TagPosition> get tagPositions
Map<String, DoorStatus> get doorStatuses

// Door Control
Future<void> openDoor(String doorId, {int duration})
Future<void> closeDoor(String doorId)
Future<void> lockDoor(String doorId)

// Maintenance
void clearOldPositions({Duration threshold})
void dispose()
```

### Mixin Methods

```dart
// Lifecycle
void initializeRealtimeIntegration()
void disposeRealtimeIntegration()

// Data Access
Offset? getRealtimeTagPosition(String tagId)
DoorState? getRealtimeDoorStatus(String doorId)
Color getDoorStatusColor(String doorId)

// Configuration
double get mapScalePixelsPerMeter  // Override this
```

---

## ✅ Checklist

- [ ] Add `RtlsProvider` to `main.dart`
- [ ] Apply `RtlsRealtimeIntegration` mixin to map state
- [ ] Update door rendering with `AnimatedContainer`
- [ ] Add calibration button to AppBar
- [ ] Configure MQTT broker IP in constants
- [ ] Test with MQTT pub/sub commands
- [ ] Verify door colors change on status update
- [ ] Confirm tags move smoothly with position updates
- [ ] Calibrate map scale if needed

---

## 🎯 Next Steps

1. **ESP32 Integration**: Configure ESP32-DW3000 to publish position data
2. **Database Sync**: Optionally sync MQTT data to Supabase for history
3. **Geofencing**: Add proximity alerts when tags enter/exit zones
4. **Trail Rendering**: Show tag movement history on map
5. **Analytics Dashboard**: Chart tag movements over time

---

**Status**: ✅ READY FOR INTEGRATION  
**Compatibility**: Works with existing Provider/GetX architecture  
**Breaking Changes**: None - all additions are backward compatible  
**Date**: 2025-10-22
