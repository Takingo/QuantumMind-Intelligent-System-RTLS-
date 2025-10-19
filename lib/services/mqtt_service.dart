import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// MQTT Service for real-time communication with ESP32
class MqttService {
  static MqttService? _instance;
  MqttServerClient? _client;
  bool _isConnected = false;
  
  MqttService._();
  
  /// Get singleton instance
  static MqttService get instance {
    _instance ??= MqttService._();
    return _instance!;
  }
  
  /// Check if connected
  bool get isConnected => _isConnected;
  
  /// Get client
  MqttServerClient? get client => _client;
  
  // ========== Connection Methods ==========
  
  /// Initialize and connect to MQTT broker
  Future<bool> connect({
    String? broker,
    int? port,
    String? clientId,
  }) async {
    try {
      final mqttBroker = broker ?? AppConstants.mqttBroker;
      final mqttPort = port ?? AppConstants.mqttPort;
      final id = clientId ?? 'quantummind_${Helpers.generateUuid()}';
      
      _client = MqttServerClient(mqttBroker, id);
      _client!.port = mqttPort;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 20;
      _client!.connectTimeoutPeriod = 2000;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;
      
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(id)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      _client!.connectionMessage = connMessage;
      
      await _client!.connect();
      
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _isConnected = true;
        return true;
      } else {
        _isConnected = false;
        return false;
      }
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }
  
  /// Disconnect from MQTT broker
  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
  }
  
  // ========== Subscription Methods ==========
  
  /// Subscribe to a topic
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT not connected');
    }
    _client!.subscribe(topic, qos);
  }
  
  /// Unsubscribe from a topic
  void unsubscribe(String topic) {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT not connected');
    }
    _client!.unsubscribe(topic);
  }
  
  /// Listen to messages from a topic
  Stream<Map<String, dynamic>> listenToTopic(String topic) {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT not connected');
    }
    
    subscribe(topic);
    
    return _client!.updates!
        .where((List<MqttReceivedMessage<MqttMessage>> messages) {
          return messages.any((msg) => msg.topic == topic);
        })
        .map((List<MqttReceivedMessage<MqttMessage>> messages) {
          final msg = messages.firstWhere((msg) => msg.topic == topic);
          final payload = msg.payload as MqttPublishMessage;
          final messageStr = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message,
          );
          
          try {
            return jsonDecode(messageStr) as Map<String, dynamic>;
          } catch (e) {
            return {'raw': messageStr};
          }
        });
  }
  
  // ========== Publishing Methods ==========
  
  /// Publish message to topic
  void publish(
    String topic,
    Map<String, dynamic> payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT not connected');
    }
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(payload));
    
    _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
  }
  
  /// Publish string message
  void publishString(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT not connected');
    }
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    
    _client!.publishMessage(topic, qos, builder.payload!, retain: retain);
  }
  
  // ========== Door Control Methods ==========
  
  /// Send door open command
  void sendDoorOpenCommand(String doorId, {int duration = 3000}) {
    publish(
      AppConstants.mqttTopicDoorControl,
      {
        'command': 'open',
        'door_id': doorId,
        'duration': duration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Send door close command
  void sendDoorCloseCommand(String doorId) {
    publish(
      AppConstants.mqttTopicDoorControl,
      {
        'command': 'close',
        'door_id': doorId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Send door lock command
  void sendDoorLockCommand(String doorId) {
    publish(
      AppConstants.mqttTopicDoorControl,
      {
        'command': 'lock',
        'door_id': doorId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  // ========== RTLS Methods ==========
  
  /// Listen to RTLS position updates
  Stream<Map<String, dynamic>> listenToRtlsUpdates() {
    return listenToTopic(AppConstants.mqttTopicRtlsPosition);
  }
  
  /// Listen to sensor data
  Stream<Map<String, dynamic>> listenToSensorData() {
    return listenToTopic(AppConstants.mqttTopicSensorData);
  }
  
  // ========== Callback Handlers ==========
  
  void _onConnected() {
    _isConnected = true;
  }
  
  void _onDisconnected() {
    _isConnected = false;
  }
  
  void _onSubscribed(String topic) {
    // Handle subscription confirmation
  }
}
