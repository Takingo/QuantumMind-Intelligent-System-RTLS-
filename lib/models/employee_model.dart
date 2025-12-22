/// Employee Model (Çalışan)
class EmployeeModel {
  final int id;
  final String? email;
  final String fullName;
  final String? phone;
  final int? departmentId;
  final int? roleId;
  final String? nfcId;
  final String? photoUrl;
  final DateTime? hireDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;

  EmployeeModel({
    required this.id,
    this.email,
    required this.fullName,
    this.phone,
    this.departmentId,
    this.roleId,
    this.nfcId,
    this.photoUrl,
    this.hireDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.username,
  });

  /// Create from JSON
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      email: json['email'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      departmentId: json['department_id'] as int?,
      roleId: json['role_id'] as int?,
      nfcId: json['nfc_id'] as String?,
      photoUrl: json['photo_url'] as String?,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      username: json['username'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'department_id': departmentId,
      'role_id': roleId,
      'nfc_id': nfcId,
      'photo_url': photoUrl,
      'hire_date': hireDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'username': username,
    };
  }

  /// Copy with
  EmployeeModel copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    int? departmentId,
    int? roleId,
    String? nfcId,
    String? photoUrl,
    DateTime? hireDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      departmentId: departmentId ?? this.departmentId,
      roleId: roleId ?? this.roleId,
      nfcId: nfcId ?? this.nfcId,
      photoUrl: photoUrl ?? this.photoUrl,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
    );
  }
}
