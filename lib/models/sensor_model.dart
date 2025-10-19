/// Sensor Data Model
class SensorModel {
  final String id;
  final String nodeId; // Associated RTLS node ID
  final String? nodeName; // Node name for display
  final double? temperature; // Celsius
  final double? humidity; // Percentage
  final double? airQuality; // Air Quality Index
  final double? pressure; // hPa
  final double? lightLevel; // Lux
  final DateTime timestamp;
  
  SensorModel({
    required this.id,
    required this.nodeId,
    this.nodeName,
    this.temperature,
    this.humidity,
    this.airQuality,
    this.pressure,
    this.lightLevel,
    required this.timestamp,
  });
  
  /// Create SensorModel from JSON
  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'] as String,
      nodeId: json['node_id'] as String,
      nodeName: json['node_name'] as String?,
      temperature: json['temp'] != null ? (json['temp'] as num).toDouble() : null,
      humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
      airQuality: json['air_quality'] != null ? (json['air_quality'] as num).toDouble() : null,
      pressure: json['pressure'] != null ? (json['pressure'] as num).toDouble() : null,
      lightLevel: json['light_level'] != null ? (json['light_level'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  /// Convert SensorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'node_id': nodeId,
      'node_name': nodeName,
      'temp': temperature,
      'humidity': humidity,
      'air_quality': airQuality,
      'pressure': pressure,
      'light_level': lightLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Get temperature status
  String get temperatureStatus {
    if (temperature == null) return 'N/A';
    if (temperature! < 15) return 'Too Cold';
    if (temperature! < 20) return 'Cold';
    if (temperature! < 25) return 'Comfortable';
    if (temperature! < 30) return 'Warm';
    return 'Too Hot';
  }
  
  /// Get humidity status
  String get humidityStatus {
    if (humidity == null) return 'N/A';
    if (humidity! < 30) return 'Too Dry';
    if (humidity! < 40) return 'Dry';
    if (humidity! < 60) return 'Comfortable';
    if (humidity! < 70) return 'Humid';
    return 'Too Humid';
  }
  
  /// Get air quality status
  String get airQualityStatus {
    if (airQuality == null) return 'N/A';
    if (airQuality! < 50) return 'Good';
    if (airQuality! < 100) return 'Moderate';
    if (airQuality! < 150) return 'Unhealthy for Sensitive';
    if (airQuality! < 200) return 'Unhealthy';
    if (airQuality! < 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
  
  /// Check if temperature is in normal range
  bool get isTemperatureNormal {
    if (temperature == null) return true;
    return temperature! >= 15 && temperature! <= 30;
  }
  
  /// Check if humidity is in normal range
  bool get isHumidityNormal {
    if (humidity == null) return true;
    return humidity! >= 30 && humidity! <= 70;
  }
  
  /// Check if air quality is good
  bool get isAirQualityGood {
    if (airQuality == null) return true;
    return airQuality! < 100;
  }
  
  /// Copy with method
  SensorModel copyWith({
    String? id,
    String? nodeId,
    String? nodeName,
    double? temperature,
    double? humidity,
    double? airQuality,
    double? pressure,
    double? lightLevel,
    DateTime? timestamp,
  }) {
    return SensorModel(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      nodeName: nodeName ?? this.nodeName,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      airQuality: airQuality ?? this.airQuality,
      pressure: pressure ?? this.pressure,
      lightLevel: lightLevel ?? this.lightLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
