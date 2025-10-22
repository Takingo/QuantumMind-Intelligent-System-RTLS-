import 'package:flutter/material.dart';
import 'dart:async';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

/// RTLS Data Provider
/// Manages real-time position data and door status from MQTT
class RtlsProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService.instance;

  // Tag positions: tagId -> {x, y, timestamp}
  final Map<String, TagPosition> _tagPositions = {};

  // Door statuses: doorId -> {status, timestamp}
  final Map<String, DoorStatus> _doorStatuses = {};

  // Subscriptions
  StreamSubscription? _positionSubscription;
  StreamSubscription? _doorSubscription;

  bool _isConnected = false;
  bool _isListening = false;

  // Getters
  bool get isConnected => _isConnected;
  bool get isListening => _isListening;
  Map<String, TagPosition> get tagPositions => Map.unmodifiable(_tagPositions);
  Map<String, DoorStatus> get doorStatuses => Map.unmodifiable(_doorStatuses);

  /// Initialize MQTT connection and start listening
  Future<bool> initialize() async {
    try {
      if (_mqttService.isConnected) {
        _isConnected = true;
        _startListening();
        return true;
      }

      final connected = await _mqttService.connect();
      _isConnected = connected;

      if (connected) {
        _startListening();
      }

      notifyListeners();
      return connected;
    } catch (e) {
      debugPrint('RTLS Provider initialization error: $e');
      return false;
    }
  }

  /// Start listening to MQTT topics
  void _startListening() {
    if (_isListening) return;

    try {
      // Listen to RTLS position updates
      _positionSubscription = _mqttService
          .listenToTopic(AppConstants.mqttTopicRtlsPosition)
          .listen(_handlePositionUpdate, onError: (error) {
        debugPrint('Position update error: $error');
      });

      // Listen to door status updates (use sensor topic as door status channel)
      _doorSubscription = _mqttService
          .listenToTopic('${AppConstants.mqttTopicDoorControl}/status')
          .listen(_handleDoorStatusUpdate, onError: (error) {
        debugPrint('Door status update error: $error');
      });

      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting MQTT listeners: $e');
    }
  }

  /// Handle incoming position update
  void _handlePositionUpdate(Map<String, dynamic> data) {
    try {
      // Expected format: {tag_id, x, y, z?, timestamp}
      final tagId = data['tag_id'] as String?;
      final x = (data['x'] as num?)?.toDouble();
      final y = (data['y'] as num?)?.toDouble();
      final z = (data['z'] as num?)?.toDouble();
      final timestamp = data['timestamp'] as String?;

      if (tagId != null && x != null && y != null) {
        _tagPositions[tagId] = TagPosition(
          tagId: tagId,
          x: x,
          y: y,
          z: z ?? 0.0,
          timestamp: timestamp != null
              ? DateTime.tryParse(timestamp) ?? DateTime.now()
              : DateTime.now(),
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error handling position update: $e');
    }
  }

  /// Handle incoming door status update
  void _handleDoorStatusUpdate(Map<String, dynamic> data) {
    try {
      // Expected format: {door_id, status, locked?, timestamp}
      final doorId = data['door_id'] as String?;
      final status = data['status'] as String?;
      final locked = data['locked'] as bool? ?? false;
      final timestamp = data['timestamp'] as String?;

      if (doorId != null && status != null) {
        _doorStatuses[doorId] = DoorStatus(
          doorId: doorId,
          status: _parseDoorState(status),
          isLocked: locked,
          timestamp: timestamp != null
              ? DateTime.tryParse(timestamp) ?? DateTime.now()
              : DateTime.now(),
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error handling door status update: $e');
    }
  }

  /// Parse door status string to enum
  DoorState _parseDoorState(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'opened':
      case 'unlocked':
        return DoorState.open;
      case 'closed':
        return DoorState.closed;
      case 'locked':
        return DoorState.locked;
      case 'opening':
        return DoorState.opening;
      case 'closing':
        return DoorState.closing;
      default:
        return DoorState.unknown;
    }
  }

  /// Get position for a specific tag
  TagPosition? getTagPosition(String tagId) {
    return _tagPositions[tagId];
  }

  /// Get door status
  DoorStatus? getDoorStatus(String doorId) {
    return _doorStatuses[doorId];
  }

  /// Send door open command
  Future<void> openDoor(String doorId, {int duration = 3000}) async {
    try {
      _mqttService.sendDoorOpenCommand(doorId, duration: duration);

      // Optimistic update
      _doorStatuses[doorId] = DoorStatus(
        doorId: doorId,
        status: DoorState.opening,
        isLocked: false,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error opening door: $e');
    }
  }

  /// Send door close command
  Future<void> closeDoor(String doorId) async {
    try {
      _mqttService.sendDoorCloseCommand(doorId);

      // Optimistic update
      _doorStatuses[doorId] = DoorStatus(
        doorId: doorId,
        status: DoorState.closing,
        isLocked: false,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error closing door: $e');
    }
  }

  /// Send door lock command
  Future<void> lockDoor(String doorId) async {
    try {
      _mqttService.sendDoorLockCommand(doorId);

      // Optimistic update
      _doorStatuses[doorId] = DoorStatus(
        doorId: doorId,
        status: DoorState.locked,
        isLocked: true,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error locking door: $e');
    }
  }

  /// Clear old tag positions (older than threshold)
  void clearOldPositions({Duration threshold = const Duration(minutes: 5)}) {
    final now = DateTime.now();
    _tagPositions.removeWhere((key, value) {
      return now.difference(value.timestamp) > threshold;
    });
    notifyListeners();
  }

  /// Stop listening and disconnect
  @override
  void dispose() {
    _positionSubscription?.cancel();
    _doorSubscription?.cancel();
    _isListening = false;
    super.dispose();
  }
}

/// Tag Position Model
class TagPosition {
  final String tagId;
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  TagPosition({
    required this.tagId,
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  /// Check if position is recent (within last N seconds)
  bool isRecent({int seconds = 10}) {
    return DateTime.now().difference(timestamp).inSeconds < seconds;
  }

  Map<String, dynamic> toJson() => {
        'tag_id': tagId,
        'x': x,
        'y': y,
        'z': z,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TagPosition.fromJson(Map<String, dynamic> json) => TagPosition(
        tagId: json['tag_id'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Door Status Model
class DoorStatus {
  final String doorId;
  final DoorState status;
  final bool isLocked;
  final DateTime timestamp;

  DoorStatus({
    required this.doorId,
    required this.status,
    required this.isLocked,
    required this.timestamp,
  });

  /// Get status color for UI
  Color getStatusColor() {
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
        return Colors.grey;
    }
  }

  /// Get status text
  String getStatusText() {
    switch (status) {
      case DoorState.open:
        return 'OPEN';
      case DoorState.closed:
        return 'CLOSED';
      case DoorState.locked:
        return 'LOCKED';
      case DoorState.opening:
        return 'OPENING...';
      case DoorState.closing:
        return 'CLOSING...';
      case DoorState.unknown:
        return 'UNKNOWN';
    }
  }

  Map<String, dynamic> toJson() => {
        'door_id': doorId,
        'status': status.name,
        'is_locked': isLocked,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Door State Enum
enum DoorState {
  open,
  closed,
  locked,
  opening,
  closing,
  unknown,
}
