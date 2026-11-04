class Profile {
  final String id; // UUID = auth.uid()
  final String fullName;
  final String role; // admin, accountant, manager
  final String? phone;
  final String loginId; // phone or email
  final bool active;
  final bool mustChangePassword;
  final DateTime? tempPasswordExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.role,
    this.phone,
    required this.loginId,
    required this.active,
    required this.mustChangePassword,
    this.tempPasswordExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      loginId: json['login_id'] as String,
      active: json['active'] as bool,
      mustChangePassword: json['must_change_password'] as bool,
      tempPasswordExpiresAt: json['temp_password_expires_at'] != null
          ? DateTime.parse(json['temp_password_expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'role': role,
        'phone': phone,
        'login_id': loginId,
        'active': active,
        'must_change_password': mustChangePassword,
        'temp_password_expires_at': tempPasswordExpiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Profile copyWith({
    String? id,
    String? fullName,
    String? role,
    String? phone,
    String? loginId,
    bool? active,
    bool? mustChangePassword,
    DateTime? tempPasswordExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      loginId: loginId ?? this.loginId,
      active: active ?? this.active,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      tempPasswordExpiresAt: tempPasswordExpiresAt ?? this.tempPasswordExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isAccountant => role == 'accountant';
  bool get isManager => role == 'manager';

  @override
  String toString() => 'Profile(id=$id, name=$fullName, role=$role, active=$active)';
}
