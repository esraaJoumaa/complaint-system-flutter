import 'package:get/get.dart';

import 'app_routes.dart';
import '../../middleware/auth_middleware.dart';

// Auth
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/dashboard_view.dart';
import '../../screens/auth/complaint_form_page.dart';
import '../../screens/auth/success_page.dart';
import '../../screens/auth/tracking_screen.dart';

// Home & Chat & Splash
import '../../screens/home/home_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/splash/splash_screen.dart';

// Notifications
import '../../screens/notifications/notifications_screen.dart';

//  Rating
import '../../screens/rating/rating_screen.dart';
import '../../bindings/rating_binding.dart';

// Employee
import '../../screens/employee/complaint_details_page.dart';
import '../../screens/employee/employee_dashboard_page.dart';
import '../../screens/employee/employee_complaints_list_page.dart';

// Department Manager
import '../../screens/department_manager/department_manager_dashboard_screen.dart';
import '../../screens/department_manager/department_complaints_screen.dart';
import '../../screens/department_manager/department_complaint_detail_screen.dart';
import '../../screens/department_manager/create_employee_screen.dart';

// Authority Manager
import '../../screens/authority/authority_dashboard_screen.dart';
import '../../screens/authority/authority_complaints_screen.dart';
import '../../screens/authority/authority_complaint_detail_screen.dart';
import '../../screens/authority/authority_create_user_screen.dart';

// Bindings
import '../../bindings/dashboard_binding.dart';
import '../../bindings/initial_binding.dart';
import '../../bindings/employee_binding.dart';
import '../../bindings/department_manager_binding.dart';
import '../../bindings/authority_binding.dart';

abstract class AppPages {
  AppPages._();

  static const String INITIAL = Routes.SPLASH;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    // ──────────────────────────────────────────────
    // Splash & Auth
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: InitialBinding(),
    ),
    GetPage<void>(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.native,
    ),
    GetPage<void>(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      middlewares: [AuthMiddleware()],
      transition: Transition.native,
    ),
    GetPage<void>(name: Routes.OTP, page: () => const OtpScreen()),

    // ──────────────────────────────────────────────
    // Citizen — المواطن
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage<void>(name: Routes.ADD_COMPLAINT, page: () => ComplaintFormPage()),
    GetPage<void>(
      name: Routes.SUCCESS,
      page: () {
        final dynamic args = Get.arguments;
        final String complaintId =
            (Get.parameters['complaintId'] ??
                    (args is Map ? args['complaintId'] : args))
                ?.toString() ??
            '';
        return SuccessPage(complaintId: complaintId);
      },
    ),
    GetPage<void>(name: Routes.TRACKING, page: () => TrackingScreen()),
    GetPage<void>(
      name: Routes.HOME,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),

    // ──────────────────────────────────────────────
    //  — تقييم الجهة بعد حل الشكوى
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.RATING,
      page: () => const RatingScreen(),
      binding: RatingBinding(),
      transition: Transition.cupertino,
    ),

    // ──────────────────────────────────────────────
    // Notifications
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsScreen(),
      transition: Transition.cupertino,
    ),

    // ──────────────────────────────────────────────
    // Chat — مشترك
    // ──────────────────────────────────────────────
    GetPage<void>(name: Routes.CHAT, page: () => ChatScreen()),

    // ──────────────────────────────────────────────
    // Employee — الموظف
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.EMPLOYEE_DASHBOARD,
      page: () => const EmployeeDashboardPage(),
      binding: EmployeeBinding(),
    ),
    GetPage<void>(
      name: Routes.EMPLOYEE_COMPLAINTS,
      page: () => const EmployeeComplaintsListPage(),
      binding: EmployeeBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: Routes.COMPLAINT_DETAILS,
      page: () => const ComplaintDetailsPage(),
    ),

    // ──────────────────────────────────────────────
    // Department Manager — مدير القسم
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.MANAGER_DASHBOARD,
      page: () => const DepartmentManagerDashboardScreen(),
      binding: DepartmentManagerBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: Routes.MANAGER_COMPLAINTS,
      page: () => const DepartmentComplaintsScreen(),
      binding: DepartmentManagerBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: Routes.MANAGER_COMPLAINT_DETAIL,
      page: () => const DepartmentComplaintDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: Routes.MANAGER_CREATE_EMPLOYEE,
      page: () => const CreateEmployeeScreen(),
      transition: Transition.cupertino,
    ),

    // ──────────────────────────────────────────────
    // Authority Manager — مدير الجهة
    // ──────────────────────────────────────────────
    GetPage<void>(
      name: Routes.AUTHORITY_DASHBOARD,
      page: () => const AuthorityDashboardScreen(),
      binding: AuthorityBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: Routes.AUTHORITY_COMPLAINTS,
      page: () => const AuthorityComplaintsScreen(),
      binding: AuthorityBinding(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: Routes.AUTHORITY_COMPLAINT_DETAIL,
      page: () => const AuthorityComplaintDetailScreen(),
      transition: Transition.cupertino,
    ),
    GetPage<void>(
      name: Routes.AUTHORITY_CREATE_USER,
      page: () => const AuthorityCreateUserScreen(),
      transition: Transition.cupertino,
    ),
  ];
}
