import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/connection_type.dart';
import '../models/rtls_node_model.dart';

/// Network Manager for handling dual-path communication (Ethernet/WiFi)
class NetworkManager {
  static NetworkManager? _instance;

  // Ethernet client
  MqttServerClient? _ethernetClient;
  bool _isEthernetConnected = false;

  // WiFi client
  MqttServerClient? _wifiClient;
  bool _isWifiConnected = false;

  // Active connection type
  ConnectionType _activeConnection = ConnectionType.wifi;

  NetworkManager._();

  /// Get singleton instance
  static NetworkManager get instance {
    _instance ??= NetworkManager._();
    return _instance!;
  }

  /// Get active connection type
  ConnectionType get activeConnection => _activeConnection;

  /// Check if any connection is active
  bool get isConnected => _isEthernetConnected || _isWifiConnected;

  /// Check if Ethernet is connected
  bool get isEthernetConnected => _isEthernetConnected;

  /// Check if WiFi is connected
  bool get isWifiConnected => _isWifiConnected;

  // ========== Connection Methods ==========

  /// Initialize and connect to both Ethernet and WiFi networks
  Future<void> initializeConnections({
    String? ethernetBroker,
    int? ethernetPort,
    String? wifiBroker,
    int? wifiPort,
  }) async {
    // Connect to Ethernet (primary)
    await _connectEthernet(ethernetBroker, ethernetPort);

    // Connect to WiFi (secondary)
    await _connectWifi(wifiBroker, wifiPort);

    // Set initial active connection
    _updateActiveConnection();
  }

  /// Connect to Ethernet broker
  Future<bool> _connectEthernet(String? broker, int? port) async {
    try {
      final mqttBroker = broker ?? AppConstants.mqttBroker;
      final mqttPort = port ?? AppConstants.mqttPort;
      final id = 'quantummind_ethernet_${Helpers.generateUuid()}';

      _ethernetClient = MqttServerClient('$mqttBroker-eth', id);
      _ethernetClient!.port = mqttPort;
      _ethernetClient!.logging(on: false);
      _ethernetClient!.keepAlivePeriod = 20;
      _ethernetClient!.connectTimeoutPeriod = AppConstants.ethernetTimeoutMs;
      _ethernetClient!.onDisconnected = _onEthernetDisconnected;
      _ethernetClient!.onConnected = _onEthernetConnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(id)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _ethernetClient!.connectionMessage = connMessage;

      await _ethernetClient!.connect();

      if (_ethernetClient!.connectionStatus!.state ==
          MqttConnectionState.connected) {
        _isEthernetConnected = true;
        _updateActiveConnection();
        return true;
      } else {
        _isEthernetConnected = false;
        return false;
      }
    } catch (e) {
      _isEthernetConnected = false;
      return false;
    }
  }

  /// Connect to WiFi broker
  Future<bool> _connectWifi(String? broker, int? port) async {
    try {
      final mqttBroker = broker ?? AppConstants.mqttBroker;
      final mqttPort = port ?? AppConstants.mqttPort;
      final id = 'quantummind_wifi_${Helpers.generateUuid()}';

      _wifiClient = MqttServerClient('$mqttBroker-wifi', id);
      _wifiClient!.port = mqttPort;
      _wifiClient!.logging(on: false);
      _wifiClient!.keepAlivePeriod = 20;
      _wifiClient!.connectTimeoutPeriod = AppConstants.wifiTimeoutMs;
      _wifiClient!.onDisconnected = _onWifiDisconnected;
      _wifiClient!.onConnected = _onWifiConnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(id)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _wifiClient!.connectionMessage = connMessage;

      await _wifiClient!.connect();

      if (_wifiClient!.connectionStatus!.state ==
          MqttConnectionState.connected) {
        _isWifiConnected = true;
        _updateActiveConnection();
        return true;
      } else {
        _isWifiConnected = false;
        return false;
      }
    } catch (e) {
      _isWifiConnected = false;
      return false;
    }
  }

  /// Update active connection based on priority
  void _updateActiveConnection() {
    // Prefer Ethernet if connected
    if (_isEthernetConnected) {
      _activeConnection = ConnectionType.ethernet;
    }
    // Fall back to WiFi if connected
    else if (_isWifiConnected) {
      _activeConnection = ConnectionType.wifi;
    }
  }

  /// Disconnect all connections
  void disconnectAll() {
    _ethernetClient?.disconnect();
    _wifiClient?.disconnect();
    _isEthernetConnected = false;
    _isWifiConnected = false;
    _activeConnection = ConnectionType.wifi;
  }

  // ========== Subscription Methods ==========

  /// Subscribe to a topic on active connection
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (_activeConnection == ConnectionType.ethernet && _isEthernetConnected) {
      _ethernetClient!.subscribe(topic, qos);
    } else if (_isWifiConnected) {
      _wifiClient!.subscribe(topic, qos);
    } else {
      throw Exception('No active connection available');
    }
  }

  /// Unsubscribe from a topic on active connection
  void unsubscribe(String topic) {
    if (_activeConnection == ConnectionType.ethernet && _isEthernetConnected) {
      _ethernetClient!.unsubscribe(topic);
    } else if (_isWifiConnected) {
      _wifiClient!.unsubscribe(topic);
    }
  }

  // ========== Publishing Methods ==========

  /// Publish message to topic using active connection
  void publish(
    String topic,
    Map<String, dynamic> payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (_activeConnection == ConnectionType.ethernet && _isEthernetConnected) {
      _publishToClient(
        _ethernetClient!,
        topic,
        payload,
        qos: qos,
        retain: retain,
      );
    } else if (_isWifiConnected) {
      _publishToClient(_wifiClient!, topic, payload, qos: qos, retain: retain);
    } else {
      throw Exception('No active connection available for publishing');
    }
  }

  /// Publish to specific client
  void _publishToClient(
    MqttServerClient client,
    String topic,
    Map<String, dynamic> payload, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(payload));
    client.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  /// Publish string message using active connection
  void publishString(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (_activeConnection == ConnectionType.ethernet && _isEthernetConnected) {
      _publishStringToClient(
        _ethernetClient!,
        topic,
        message,
        qos: qos,
        retain: retain,
      );
    } else if (_isWifiConnected) {
      _publishStringToClient(
        _wifiClient!,
        topic,
        message,
        qos: qos,
        retain: retain,
      );
    } else {
      throw Exception('No active connection available for publishing');
    }
  }

  /// Publish string to specific client
  void _publishStringToClient(
    MqttServerClient client,
    String topic,
    String message, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  // ========== Callback Handlers ==========

  void _onEthernetConnected() {
    _isEthernetConnected = true;
    _updateActiveConnection();
  }

  void _onEthernetDisconnected() {
    _isEthernetConnected = false;
    _updateActiveConnection();
  }

  void _onWifiConnected() {
    _isWifiConnected = true;
    _updateActiveConnection();
  }

  void _onWifiDisconnected() {
    _isWifiConnected = false;
    _updateActiveConnection();
  }

  // ========== Node Management ==========

  /// Update node connection status
  RtlsNodeModel updateNodeConnectionStatus(
    RtlsNodeModel node,
    ConnectionType connectionType,
  ) {
    final now = DateTime.now();

    switch (connectionType) {
      case ConnectionType.ethernet:
        return node.copyWith(
          connectionType: ConnectionType.ethernet,
          lastEthernetSync: now,
          lastSyncAt: now,
        );
      case ConnectionType.wifi:
        return node.copyWith(
          connectionType: ConnectionType.wifi,
          lastWifiSync: now,
          lastSyncAt: now,
        );
    }
  }
}
