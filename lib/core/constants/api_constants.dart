class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "http://192.168.111.133:8000/api";

  static const String register = "/auth/register";
  static const String verifyEmail = "/auth/verify-email";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";
  static const String me = "/auth/me";

  static const String storeComplaint = "/complaints";
  static const String myComplaints = "/my-complaints";
  static String complaintById(int id) => "/complaints/$id";

  static const String allComplaints = "/employee/list";

  static String viewComplaint(int id) => "/employee/view/$id";

  static String updateStatus(int id) => "/complaints/$id/status";

  static String respondToComplaint(int id) =>
      "/employee/complaints/$id/respond";

  static String rejectComplaint(int id) => "/complaints/$id/reject";

  static String filterComplaints(String status) => "/complaints/filter/$status";

  static const String statusPending = "Pending";
  static const String statusInProgress = "In Progress";
  static const String statusResolved = "Resolved";

  static const String myDepartments = "/manager/my-departments";
  static const String managerStats = "/manager/statistics";
  static const String createEmployee = "/manager/create-employee";

  static const String adminCreateUser = "/admin/create-user";
  static const String authorityDashboardStats = "/dashboard/statistics";
  static const String statsByAuthority = "/dashboard/complaints-by-authority";
  static const String statsByDepartment = "/dashboard/complaints-by-department";
  static const String monthlyStats = "/dashboard/monthly-complaints";

  static String openChat(int complainId) => "/chat/open/$complainId";
  static String chatHistory(int complainId) => "/chat/complaints/$complainId";
  static String sendMessage(int complainId) => "/chat/send-message/$complainId";
  static const String allChats = "/chat/all";
  static const String toggleChatStatus = "/chat/toggle-status";

  static const String notifications = "/notifications";
  static const String unreadNotificationsCount = "/notifications/unread-count";

  static const String runAutomaticEscalation = "/escalate-complaints";
}
