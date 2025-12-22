import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

/// Relay control service for managing GPIO35/36 relays on ESP32 anchors
class RelayControlService {
  static RelayControlService? _instance;

  final MqttService _mqttService = MqttService.instance;

  // Manual override states
  final Map<String, Map<int, bool>> _manualOverrides = {};

  RelayControlService._();

  /// Get singleton instance
  static RelayControlService get instance {
    _instance ??= RelayControlService._();
    return _instance!;
  }

  /// Trigger a relay on a specific anchor
  void triggerRelay(String anchorId, int relayNumber, {int duration = 3000}) {
    if (relayNumber != 1 && relayNumber != 2) {
      debugPrint('Invalid relay number: $relayNumber. Must be 1 or 2.');
      return;
    }

    try {
      _mqttService.publish(
        '${AppConstants.mqttTopicRtlsPosition}/anchor/$anchorId/relay',
        {
          'command': 'trigger_relay',
          'relay_number': relayNumber,
          'duration_ms': duration,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
        'Triggered relay $relayNumber on anchor $anchorId for ${duration}ms',
      );
    } catch (e) {
      debugPrint('Error triggering relay: $e');
    }
  }

  /// Set relay state (on/off) on a specific anchor
  void setRelayState(String anchorId, int relayNumber, bool isOn) {
    if (relayNumber != 1 && relayNumber != 2) {
      debugPrint('Invalid relay number: $relayNumber. Must be 1 or 2.');
      return;
    }

    try {
      _mqttService.publish(
        '${AppConstants.mqttTopicRtlsPosition}/anchor/$anchorId/relay',
        {
          'command': isOn ? 'relay_on' : 'relay_off',
          'relay_number': relayNumber,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
        '${isOn ? 'Enabled' : 'Disabled'} relay $relayNumber on anchor $anchorId',
      );
    } catch (e) {
      debugPrint('Error setting relay state: $e');
    }
  }

  /// Manually override relay state
  void setManualOverride(String anchorId, int relayNumber, bool isOverridden) {
    if (relayNumber != 1 && relayNumber != 2) {
      debugPrint('Invalid relay number: $relayNumber. Must be 1 or 2.');
      return;
    }

    _manualOverrides.putIfAbsent(anchorId, () => {})[relayNumber] =
        isOverridden;

    debugPrint(
      'Set manual override for relay $relayNumber on anchor $anchorId: $isOverridden',
    );
  }

  /// Check if a relay is manually overridden
  bool isManuallyOverridden(String anchorId, int relayNumber) {
    return _manualOverrides[anchorId]?[relayNumber] ?? false;
  }

  /// Get all manual overrides for an anchor
  Map<int, bool> getManualOverridesForAnchor(String anchorId) {
    return Map.from(_manualOverrides[anchorId] ?? {});
  }

  /// Clear manual override for a specific relay
  void clearManualOverride(String anchorId, int relayNumber) {
    _manualOverrides[anchorId]?.remove(relayNumber);
  }

  /// Clear all manual overrides for an anchor
  void clearAllOverridesForAnchor(String anchorId) {
    _manualOverrides.remove(anchorId);
  }

  /// Send emergency stop command to all anchors
  void emergencyStopAllRelays() {
    try {
      _mqttService.publish(
        '${AppConstants.mqttTopicRtlsPosition}/emergency_stop',
        {
          'command': 'emergency_stop_all_relays',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('Emergency stop sent to all relays');
    } catch (e) {
      debugPrint('Error sending emergency stop: $e');
    }
  }

  /// Send heartbeat to verify relay connectivity
  void sendHeartbeat(String anchorId) {
    try {
      _mqttService.publish(
        '${AppConstants.mqttTopicRtlsPosition}/anchor/$anchorId/heartbeat',
        {
          'command': 'relay_heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error sending heartbeat: $e');
    }
  }
}
