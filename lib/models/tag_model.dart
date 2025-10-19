/// UWB Tag Model
class TagModel {
  final String id;
  final String uid; // Unique identifier (UUID)
  final String secretKey; // AES-256 encrypted key
  final String? userId; // Associated user ID
  final String? userName; // Associated user name (for display)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final double? lastX; // Last known X position
  final double? lastY; // Last known Y position
  final String? department; // Department or zone
  final String? description;
  
  TagModel({
    required this.id,
    required this.uid,
    required this.secretKey,
    this.userId,
    this.userName,
    this.isActive = true,
    required this.createdAt,
    this.lastSeenAt,
    this.lastX,
    this.lastY,
    this.department,
    this.description,
  });
  
  /// Create TagModel from JSON
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      uid: json['uid'] as String,
      secretKey: json['secret_key'] as String,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
      isActive: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : null,
      lastX: json['last_x'] as double?,
      lastY: json['last_y'] as double?,
      department: json['department'] as String?,
      description: json['description'] as String?,
    );
  }
  
  /// Convert TagModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'secret_key': secretKey,
      'user_id': userId,
      'user_name': userName,
      'active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'last_x': lastX,
      'last_y': lastY,
      'department': department,
      'description': description,
    };
  }
  
  /// Check if tag is assigned to a user
  bool get isAssigned => userId != null;
  
  /// Get status text
  String get statusText {
    if (!isActive) return 'Inactive';
    if (lastSeenAt == null) return 'Never Seen';
    
    final diff = DateTime.now().difference(lastSeenAt!);
    if (diff.inMinutes < 5) return 'Online';
    if (diff.inHours < 1) return 'Recently Active';
    return 'Offline';
  }
  
  /// Copy with method
  TagModel copyWith({
    String? id,
    String? uid,
    String? secretKey,
    String? userId,
    String? userName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    double? lastX,
    double? lastY,
    String? department,
    String? description,
  }) {
    return TagModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      secretKey: secretKey ?? this.secretKey,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastX: lastX ?? this.lastX,
      lastY: lastY ?? this.lastY,
      department: department ?? this.department,
      description: description ?? this.description,
    );
  }
}
