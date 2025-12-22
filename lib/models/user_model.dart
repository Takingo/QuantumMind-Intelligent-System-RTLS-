/// User Profile Model (based on profiles table)
class UserModel {
  final String id;
  final String? employeeId;
  final String? username;
  final String role; // admin, employee
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? nfcId;

  UserModel({
    required this.id,
    this.employeeId,
    this.username,
    required this.role,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    this.nfcId,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String?,
      username: json['username'] as String?,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      nfcId: json['nfc_id'] as String?,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'username': username,
      'role': role,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nfc_id': nfcId,
    };
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is employee
  bool get isEmployee => role == 'employee';

  /// Get display name (backward compatibility)
  String get name => fullName;
  String get email => username ?? '';
  bool get isActive => true;

  /// Copy with method
  UserModel copyWith({
    String? id,
    String? employeeId,
    String? username,
    String? role,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nfcId,
  }) {
    return UserModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      username: username ?? this.username,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nfcId: nfcId ?? this.nfcId,
    );
  }
}
