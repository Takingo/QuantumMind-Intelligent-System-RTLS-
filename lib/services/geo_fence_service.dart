import 'dart:async';
import 'package:flutter/material.dart';
import '../models/zone_model.dart';
import '../services/supabase_service.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';
import '../providers/rtls_provider.dart';

/// Geo-fence service for monitoring tag positions and triggering relay actions
class GeoFenceService {
  static GeoFenceService? _instance;

  final SupabaseService _supabaseService = SupabaseService.instance;
  final MqttService _mqttService = MqttService.instance;
  final RtlsProvider _rtlsProvider;

  // Zones cache
  final List<Zone> _zones = [];
  List<Zone> get zones => List.unmodifiable(_zones);

  // Active zone entries (tagId -> zoneId)
  final Map<String, String> _activeEntries = {};

  // Timer for periodic checks
  Timer? _monitoringTimer;

  GeoFenceService._(this._rtlsProvider);

  /// Get singleton instance
  static GeoFenceService getInstance(RtlsProvider rtlsProvider) {
    _instance ??= GeoFenceService._(rtlsProvider);
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _loadZonesFromDatabase();
    _startMonitoring();
  }

  /// Load zones from database
  Future<void> _loadZonesFromDatabase() async {
    try {
      final zonesData = await _supabaseService.getAll('zones');
      _zones.clear();

      for (final zoneData in zonesData) {
        try {
          final zone = Zone.fromJson(zoneData);
          _zones.add(zone);
        } catch (e) {
          debugPrint('Error parsing zone data: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading zones from database: $e');
    }
  }

  /// Add a new zone
  Future<bool> addZone(Zone zone) async {
    try {
      final zoneData = zone.toJson();
      await _supabaseService.insert('zones', zoneData);
      _zones.add(zone);
      return true;
    } catch (e) {
      debugPrint('Error adding zone: $e');
      return false;
    }
  }

  /// Update an existing zone
  Future<bool> updateZone(Zone zone) async {
    try {
      final zoneData = zone.toJson();
      await _supabaseService.update('zones', zone.id, zoneData);

      // Update in local cache
      final index = _zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        _zones[index] = zone;
      }

      return true;
    } catch (e) {
      debugPrint('Error updating zone: $e');
      return false;
    }
  }

  /// Delete a zone
  Future<bool> deleteZone(String zoneId) async {
    try {
      await _supabaseService.delete('zones', zoneId);

      // Remove from local cache
      _zones.removeWhere((zone) => zone.id == zoneId);

      return true;
    } catch (e) {
      debugPrint('Error deleting zone: $e');
      return false;
    }
  }

  /// Start monitoring tag positions
  void _startMonitoring() {
    // Cancel existing timer if any
    _monitoringTimer?.cancel();

    // Start periodic monitoring
    _monitoringTimer = Timer.periodic(
      const Duration(
        milliseconds: 200,
      ), // Check every 200ms for <200ms latency requirement
      (_) => _checkTagPositions(),
    );
  }

  /// Check tag positions against zones
  void _checkTagPositions() {
    // Get current tag positions from RTLS provider
    final tagPositions = _rtlsProvider.tagPositions;

    // Check each tag position
    tagPositions.forEach((tagId, position) {
      final tagPoint = Offset(position.x, position.y);

      // Check against all zones
      for (final zone in _zones) {
        final wasInside = _activeEntries[tagId] == zone.id;
        final isInside = zone.containsPoint(tagPoint);

        // Handle entry event
        if (!wasInside && isInside) {
          _handleZoneEntry(tagId, zone);
        }
        // Handle exit event
        else if (wasInside && !isInside) {
          _handleZoneExit(tagId, zone);
        }
      }
    });
  }

  /// Handle tag entering a zone
  void _handleZoneEntry(String tagId, Zone zone) {
    // Record entry
    _activeEntries[tagId] = zone.id;

    // Trigger relay action based on zone type
    switch (zone.actionType) {
      case ZoneActionType.forbidden:
        // Trigger Relay 1 (GPIO35) for safety
        _triggerRelay(tagId, zone, 1);
        break;
      case ZoneActionType.accessControl:
        // Trigger Relay 2 (GPIO36) for access control
        _triggerRelay(tagId, zone, 2);
        break;
      case ZoneActionType.monitoring:
        // No relay action, just log
        _logEvent('Tag $tagId entered monitoring zone ${zone.name}');
        break;
    }
  }

  /// Handle tag exiting a zone
  void _handleZoneExit(String tagId, Zone zone) {
    // Remove entry record
    _activeEntries.remove(tagId);

    // Log exit event
    _logEvent('Tag $tagId exited zone ${zone.name}');
  }

  /// Trigger relay action
  void _triggerRelay(String tagId, Zone zone, int relayNumber) {
    try {
      // Send MQTT command to nearest anchor
      // In a real implementation, we would determine the nearest anchor
      // For now, we'll send to a general relay control topic
      _mqttService.publish(
        '${AppConstants.mqttTopicRtlsPosition}/relay_control',
        {
          'command': 'trigger_relay',
          'relay_number': relayNumber,
          'tag_id': tagId,
          'zone_id': zone.id,
          'zone_name': zone.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Log the action
      _logEvent(
        'Relay $relayNumber triggered for tag $tagId in zone ${zone.name}',
        eventType: 'RELAY_TRIGGER',
        tagId: tagId,
        relayStatus: 'TRIGGERED',
      );
    } catch (e) {
      debugPrint('Error triggering relay: $e');
    }
  }

  /// Log events to database
  Future<void> _logEvent(
    String message, {
    String eventType = 'ZONE_EVENT',
    String? tagId,
    String? relayStatus,
  }) async {
    try {
      await _supabaseService.insert('logs', {
        'event_type': eventType,
        'message': message,
        'tag_id': tagId,
        'relay_status': relayStatus,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error logging event: $e');
    }
  }

  /// Get zones that contain a specific point
  List<Zone> getZonesContainingPoint(Offset point) {
    return _zones.where((zone) => zone.containsPoint(point)).toList();
  }

  /// Check if a tag is currently in any forbidden zone
  bool isTagInForbiddenZone(String tagId) {
    final zoneId = _activeEntries[tagId];
    if (zoneId == null) return false;

    final zone = _zones.firstWhereOrNull((z) => z.id == zoneId);
    return zone?.actionType == ZoneActionType.forbidden;
  }

  /// Dispose of the service
  void dispose() {
    _monitoringTimer?.cancel();
  }
}

// Extension to add firstWhereOrNull method to Iterable
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
