/// Door Model
class DoorModel {
  final String id;
  final String name;
  final double threshold; // Distance threshold in meters
  final int relayPin; // GPIO pin for relay control
  final String status; // open, closed, locked
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final String? lastTriggeredBy; // User ID or Tag ID
  final String? location; // Physical location
  final int? openDuration; // Duration in milliseconds
  
  DoorModel({
    required this.id,
    required this.name,
    required this.threshold,
    required this.relayPin,
    this.status = 'closed',
    this.isEnabled = true,
    required this.createdAt,
    this.lastTriggeredAt,
    this.lastTriggeredBy,
    this.location,
    this.openDuration = 3000,
  });
  
  /// Create DoorModel from JSON
  factory DoorModel.fromJson(Map<String, dynamic> json) {
    return DoorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      threshold: (json['threshold'] as num).toDouble(),
      relayPin: json['relay_pin'] as int,
      status: json['status'] as String? ?? 'closed',
      isEnabled: json['is_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastTriggeredAt: json['last_triggered_at'] != null
          ? DateTime.parse(json['last_triggered_at'] as String)
          : null,
      lastTriggeredBy: json['last_triggered_by'] as String?,
      location: json['location'] as String?,
      openDuration: json['open_duration'] as int? ?? 3000,
    );
  }
  
  /// Convert DoorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'threshold': threshold,
      'relay_pin': relayPin,
      'status': status,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'last_triggered_at': lastTriggeredAt?.toIso8601String(),
      'last_triggered_by': lastTriggeredBy,
      'location': location,
      'open_duration': openDuration,
    };
  }
  
  /// Check if door is open
  bool get isOpen => status == 'open';
  
  /// Check if door is closed
  bool get isClosed => status == 'closed';
  
  /// Check if door is locked
  bool get isLocked => status == 'locked';
  
  /// Get status color
  String get statusColor {
    switch (status) {
      case 'open':
        return '#10B981'; // Green
      case 'closed':
        return '#6B7280'; // Gray
      case 'locked':
        return '#EF4444'; // Red
      default:
        return '#3B82F6'; // Blue
    }
  }
  
  /// Copy with method
  DoorModel copyWith({
    String? id,
    String? name,
    double? threshold,
    int? relayPin,
    String? status,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastTriggeredAt,
    String? lastTriggeredBy,
    String? location,
    int? openDuration,
  }) {
    return DoorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      threshold: threshold ?? this.threshold,
      relayPin: relayPin ?? this.relayPin,
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      lastTriggeredBy: lastTriggeredBy ?? this.lastTriggeredBy,
      location: location ?? this.location,
      openDuration: openDuration ?? this.openDuration,
    );
  }
}
