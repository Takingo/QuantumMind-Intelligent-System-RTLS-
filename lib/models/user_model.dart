/// User Model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // Admin, User, Viewer
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });
  
  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
  
  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
  
  /// Check if user is admin
  bool get isAdmin => role == 'Admin';
  
  /// Check if user is user
  bool get isUser => role == 'User';
  
  /// Check if user is viewer
  bool get isViewer => role == 'Viewer';
  
  /// Copy with method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
