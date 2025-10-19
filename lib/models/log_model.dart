/// Log Model for tracking events
class LogModel {
  final String id;
  final String event; // Event type (door_opened, tag_detected, user_login, etc.)
  final String? tagId; // Associated tag ID
  final String? tagUid; // Tag UID for display
  final String? userId; // Associated user ID
  final String? userName; // User name for display
  final String? doorId; // Associated door ID
  final String? doorName; // Door name for display
  final double? distance; // Distance measurement (for proximity events)
  final String? location; // Location where event occurred
  final String? details; // Additional details in JSON format
  final String severity; // info, warning, error, critical
  final DateTime timestamp;
  
  LogModel({
    required this.id,
    required this.event,
    this.tagId,
    this.tagUid,
    this.userId,
    this.userName,
    this.doorId,
    this.doorName,
    this.distance,
    this.location,
    this.details,
    this.severity = 'info',
    required this.timestamp,
  });
  
  /// Create LogModel from JSON
  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] as String,
      event: json['event'] as String,
      tagId: json['tag_id'] as String?,
      tagUid: json['tag_uid'] as String?,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
      doorId: json['door_id'] as String?,
      doorName: json['door_name'] as String?,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      location: json['location'] as String?,
      details: json['details'] as String?,
      severity: json['severity'] as String? ?? 'info',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  /// Convert LogModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'tag_id': tagId,
      'tag_uid': tagUid,
      'user_id': userId,
      'user_name': userName,
      'door_id': doorId,
      'door_name': doorName,
      'distance': distance,
      'location': location,
      'details': details,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Get event icon based on event type
  String get eventIcon {
    if (event.contains('door')) return '🚪';
    if (event.contains('tag')) return '🏷️';
    if (event.contains('user') || event.contains('login')) return '👤';
    if (event.contains('sensor')) return '🌡️';
    if (event.contains('error')) return '❌';
    if (event.contains('warning')) return '⚠️';
    if (event.contains('success')) return '✅';
    return 'ℹ️';
  }
  
  /// Get severity color
  String get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return '#EF4444'; // Red
      case 'error':
        return '#F59E0B'; // Orange
      case 'warning':
        return '#FBBF24'; // Yellow
      case 'success':
        return '#10B981'; // Green
      default:
        return '#3B82F6'; // Blue (info)
    }
  }
  
  /// Get readable event text
  String get eventText {
    switch (event.toLowerCase()) {
      case 'door_opened':
        return 'Door Opened';
      case 'door_closed':
        return 'Door Closed';
      case 'door_locked':
        return 'Door Locked';
      case 'door_unlocked':
        return 'Door Unlocked';
      case 'tag_detected':
        return 'Tag Detected';
      case 'tag_lost':
        return 'Tag Lost';
      case 'user_login':
        return 'User Login';
      case 'user_logout':
        return 'User Logout';
      case 'unauthorized_access':
        return 'Unauthorized Access';
      case 'sensor_alert':
        return 'Sensor Alert';
      case 'system_error':
        return 'System Error';
      case 'connection_lost':
        return 'Connection Lost';
      case 'connection_restored':
        return 'Connection Restored';
      default:
        return event.replaceAll('_', ' ').split(' ').map(
          (word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        ).join(' ');
    }
  }
  
  /// Get description for display
  String get description {
    final parts = <String>[];
    
    if (userName != null) parts.add('User: $userName');
    if (tagUid != null) parts.add('Tag: $tagUid');
    if (doorName != null) parts.add('Door: $doorName');
    if (distance != null) parts.add('Distance: ${distance!.toStringAsFixed(2)}m');
    if (location != null) parts.add('Location: $location');
    
    return parts.isNotEmpty ? parts.join(' | ') : eventText;
  }
  
  /// Copy with method
  LogModel copyWith({
    String? id,
    String? event,
    String? tagId,
    String? tagUid,
    String? userId,
    String? userName,
    String? doorId,
    String? doorName,
    double? distance,
    String? location,
    String? details,
    String? severity,
    DateTime? timestamp,
  }) {
    return LogModel(
      id: id ?? this.id,
      event: event ?? this.event,
      tagId: tagId ?? this.tagId,
      tagUid: tagUid ?? this.tagUid,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      doorId: doorId ?? this.doorId,
      doorName: doorName ?? this.doorName,
      distance: distance ?? this.distance,
      location: location ?? this.location,
      details: details ?? this.details,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
