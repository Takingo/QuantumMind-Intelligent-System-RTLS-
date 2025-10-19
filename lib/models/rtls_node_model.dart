/// RTLS Node (Anchor) Model
class RtlsNodeModel {
  final String id;
  final String name;
  final double coordX; // X coordinate in meters
  final double coordY; // Y coordinate in meters
  final double? coordZ; // Z coordinate (height) in meters
  final double signalQuality; // RSSI or signal strength
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastSyncAt;
  final String? ipAddress;
  final String? macAddress;
  final String? firmwareVersion;
  
  RtlsNodeModel({
    required this.id,
    required this.name,
    required this.coordX,
    required this.coordY,
    this.coordZ,
    this.signalQuality = 0.0,
    this.isActive = true,
    required this.createdAt,
    this.lastSyncAt,
    this.ipAddress,
    this.macAddress,
    this.firmwareVersion,
  });
  
  /// Create RtlsNodeModel from JSON
  factory RtlsNodeModel.fromJson(Map<String, dynamic> json) {
    return RtlsNodeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coordX: (json['coord_x'] as num).toDouble(),
      coordY: (json['coord_y'] as num).toDouble(),
      coordZ: json['coord_z'] != null ? (json['coord_z'] as num).toDouble() : null,
      signalQuality: (json['signal_quality'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      ipAddress: json['ip_address'] as String?,
      macAddress: json['mac_address'] as String?,
      firmwareVersion: json['firmware_version'] as String?,
    );
  }
  
  /// Convert RtlsNodeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coord_x': coordX,
      'coord_y': coordY,
      'coord_z': coordZ,
      'signal_quality': signalQuality,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'firmware_version': firmwareVersion,
    };
  }
  
  /// Get signal strength text
  String get signalStrengthText {
    if (signalQuality > -50) return 'Excellent';
    if (signalQuality > -60) return 'Good';
    if (signalQuality > -70) return 'Fair';
    return 'Poor';
  }
  
  /// Get status text
  String get statusText {
    if (!isActive) return 'Inactive';
    if (lastSyncAt == null) return 'Never Synced';
    
    final diff = DateTime.now().difference(lastSyncAt!);
    if (diff.inMinutes < 5) return 'Online';
    return 'Offline';
  }
  
  /// Copy with method
  RtlsNodeModel copyWith({
    String? id,
    String? name,
    double? coordX,
    double? coordY,
    double? coordZ,
    double? signalQuality,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastSyncAt,
    String? ipAddress,
    String? macAddress,
    String? firmwareVersion,
  }) {
    return RtlsNodeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coordX: coordX ?? this.coordX,
      coordY: coordY ?? this.coordY,
      coordZ: coordZ ?? this.coordZ,
      signalQuality: signalQuality ?? this.signalQuality,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }
}
