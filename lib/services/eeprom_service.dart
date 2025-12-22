import '../models/rtls_node_model.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

/// EEPROM Service for synchronizing anchor coordinates to AT24C256 EEPROM
class EepromService {
  static EepromService? _instance;

  EepromService._();

  /// Get singleton instance
  static EepromService get instance {
    _instance ??= EepromService._();
    return _instance!;
  }

  /// Sync anchor coordinates to EEPROM
  Future<bool> syncAnchorToEeprom(RtlsNodeModel anchor) async {
    try {
      // Prepare EEPROM data payload
      final payload = {
        'command': 'sync_eeprom',
        'anchor_id': anchor.id,
        'coordinates': {
          'x': anchor.coordX,
          'y': anchor.coordY,
          'z': anchor.coordZ,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send to anchor via MQTT
      MqttService.instance.publish(
        '${AppConstants.mqttTopicRtlsPosition}/eeprom_sync',
        payload,
      );

      return true;
    } catch (e) {
      // Log error
      print('Failed to sync anchor ${anchor.id} to EEPROM: $e');
      return false;
    }
  }

  /// Sync multiple anchors to EEPROM
  Future<List<bool>> syncAnchorsToEeprom(List<RtlsNodeModel> anchors) async {
    final results = <bool>[];

    for (final anchor in anchors) {
      final result = await syncAnchorToEeprom(anchor);
      results.add(result);
    }

    return results;
  }

  /// Bulk sync all anchors to EEPROM
  Future<bool> bulkSyncAnchorsToEeprom(List<RtlsNodeModel> anchors) async {
    try {
      // Prepare bulk EEPROM data payload
      final payload = {
        'command': 'bulk_eeprom_sync',
        'anchors': anchors.map((anchor) {
          return {
            'id': anchor.id,
            'coordinates': {
              'x': anchor.coordX,
              'y': anchor.coordY,
              'z': anchor.coordZ,
            },
          };
        }).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send bulk sync command via MQTT
      MqttService.instance.publish(
        '${AppConstants.mqttTopicRtlsPosition}/bulk_eeprom_sync',
        payload,
      );

      return true;
    } catch (e) {
      // Log error
      print('Failed to bulk sync anchors to EEPROM: $e');
      return false;
    }
  }
}
