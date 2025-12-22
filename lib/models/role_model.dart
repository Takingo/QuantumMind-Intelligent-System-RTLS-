/// Role Model (Rol - Admin/Supervisor/Employee)
class RoleModel {
  final int id;
  final String name;
  final String? description;
  final Map<String, dynamic> permissions;
  final int level;
  final DateTime createdAt;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    required this.permissions,
    required this.level,
    required this.createdAt,
  });

  /// Create from JSON
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      permissions: json['permissions'] as Map<String, dynamic>? ?? {},
      level: json['level'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'level': level,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Check if role has specific permission
  bool hasPermission(String permissionKey) {
    return permissions[permissionKey] == true;
  }

  /// Get all permission keys
  List<String> get permissionKeys => permissions.keys.toList();

  /// Check if admin (level 1)
  bool get isAdmin => level == 1;

  /// Check if supervisor (level 2)
  bool get isSupervisor => level == 2;

  /// Check if employee (level 3)
  bool get isEmployee => level == 3;
}
