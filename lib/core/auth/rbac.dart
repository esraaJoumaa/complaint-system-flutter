import 'package:get_storage/get_storage.dart';

class Rbac {
  Rbac._();


  // ──────────────────────────────────────────────
  static Map<String, dynamic>? _userData() {
    final raw = GetStorage().read('user_data');
    if (raw == null) return null;
    try { return Map<String, dynamic>.from(raw as Map); }
    catch (_) { return null; }
  }

  static String? currentRole() {
    final role = _userData()?['role_name']?.toString().trim();
    return (role == null || role.isEmpty) ? null : role.toLowerCase();
  }


  // ──────────────────────────────────────────────

  /// مدير الجهة (role_id=2, name="manager")
  static bool isAuthorityManager() => currentRole() == 'manager';

  /// مدير القسم (role_id=3, name="dept_manager")
  static bool isDeptManager() => currentRole() == 'dept_manager';

  /// الموظف (role_id=4, name="employee")
  static bool isEmployee() => currentRole() == 'employee';

  /// مدير النظام (role_id=1, name="admin")
  static bool isAdmin() => currentRole() == 'admin';

  /// المواطن (role_id=5, name="user")
  static bool isCitizen() {
    final r = currentRole();
    return r == 'user' || r == null;
  }

  static bool isOfficialUser() {
    final r = currentRole();
    return r == 'admin' ||
        r == 'manager' ||
        r == 'dept_manager' ||
        r == 'employee';
  }

  static bool hasAccess(List<String> roles) =>
      roles.contains(currentRole());
}
