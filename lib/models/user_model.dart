/// موديل المستخدم
class UserModel {
  final int? id;
  final int? roleId;
  final int? authorityId;
  final int? departmentId;
  final String? token;
  final String name;
  final String? username;
  final String phone;
  final String email;
  final String? birthDate;
  final bool isActive;
  final num? score;
  final String? roleName;
  final int? roleLevel;

  const UserModel({
    this.id,
    this.roleId,
    this.authorityId,
    this.departmentId,
    this.token,
    required this.name,
    this.username,
    required this.phone,
    required this.email,
    this.birthDate,
    required this.isActive,
    this.score,
    this.roleName,
    this.roleLevel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? roleName;
    int? roleLevel;

    if (json['role'] is Map) {
      final r = Map<String, dynamic>.from(json['role'] as Map);
      roleName = r['name']?.toString();
      roleLevel = _parseInt(r['level']);
    }
    roleName ??= json['role_name']?.toString();
    if (roleName == null) {
      roleName = _roleNameFromId(_parseInt(json['role_id']));
    }

    return UserModel(
      id: _parseInt(json['user_id'] ?? json['id']),
      roleId: _parseInt(json['role_id']),
      authorityId: _parseInt(json['authority_id']),
      departmentId: _parseInt(json['department_id']),
      token: json['token']?.toString(),
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString(),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      birthDate:
          json['birthdate']?.toString() ?? json['birth_date']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      score: json['score'] is num
          ? json['score'] as num
          : num.tryParse(json['score']?.toString() ?? ''),
      roleName: roleName?.toLowerCase().trim(),
      roleLevel: roleLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role_id': roleId,
    'authority_id': authorityId,
    'department_id': departmentId,
    'token': token,
    'name': name,
    'username': username,
    'phone': phone,
    'email': email,
    'birth_date': birthDate,
    'is_active': isActive ? 1 : 0,
    'score': score,
    'role_name': roleName,
    'role_level': roleLevel,
  };

  static String? _roleNameFromId(int? id) {
    switch (id) {
      case 1:
        return 'admin';
      case 2:
        return 'manager';
      case 3:
        return 'dept_manager';
      case 4:
        return 'employee';
      case 5:
        return 'user';
      default:
        return null;
    }
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}
