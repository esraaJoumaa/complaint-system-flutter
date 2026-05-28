abstract class Routes {
  Routes._();

  // ── Auth ──
  static const String SPLASH = '/splash';
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String OTP = '/otp';
  static const String PROFILE = '/profile';

  // ── Citizen — المواطن ──
  static const String DASHBOARD = '/dashboard';
  static const String SUCCESS = '/success';
  static const String TRACKING = '/tracking';
  static const String HOME = '/home';
  static const String ADD_COMPLAINT = '/add-complaint';
  static const String MY_COMPLAINTS = '/my-complaints';

  // ── Employee — الموظف ──
  static const String EMPLOYEE_DASHBOARD = '/employee-dashboard';
  static const String EMPLOYEE_COMPLAINTS = '/employee-complaints';
  static const String COMPLAINT_DETAILS = '/complaint-details';
  static const String COMPLAINT_RESPONSE = '/complaint-response';

  // ── Department Manager — مدير القسم ──
  static const String MANAGER_DASHBOARD = '/manager-dashboard';
  static const String MANAGER_COMPLAINTS = '/manager-complaints';
  static const String MANAGER_COMPLAINT_DETAIL = '/manager-complaint-detail';
  static const String MANAGER_CREATE_EMPLOYEE = '/manager-create-employee';

  // ── Authority Manager — مدير الجهة ──
  static const String AUTHORITY_DASHBOARD = '/authority-dashboard';
  static const String AUTHORITY_COMPLAINTS = '/authority-complaints';
  static const String AUTHORITY_COMPLAINT_DETAIL =
      '/authority-complaint-detail';
  static const String AUTHORITY_CREATE_USER = '/authority-create-user';

  // ── Communication ──
  static const String CHAT = '/chat';
  static const String NOTIFICATIONS = '/notifications';
  static const String RATING = '/rating';
}
