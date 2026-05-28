/// ملف ثوابت الـ API — مرجع مركزي لجميع روابط الباك إند
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "http://192.168.33.133:8000/api";

  // ── Auth ──
  static const String register    = "/auth/register";
  static const String verifyEmail = "/auth/verify-email";
  static const String login       = "/auth/login";
  static const String logout      = "/auth/logout";
  static const String me          = "/auth/me";

  // ── Complaints — المواطن ──
  static const String storeComplaint = "/complaints";
  static const String myComplaints   = "/my-complaints";
  static String complaintById(int id) => "/complaints/$id";

  // ── Complaints — الموظف والمدراء ──
  static String filterComplaints(String status) => "/complaints/filter/$status";
  static const String managerComplaints = "/manager/complaints";
  static String viewComplaint(int id)       => "/employee/view/$id";
  static String updateStatus(int id)        => "/complaints/$id/status";
  static String respondToComplaint(int id)  => "/employee/complaints/$id/respond";
  static String rejectComplaint(int id)     => "/complaints/$id/reject";

  // ── ثوابت حالات الشكاوي ──
  static const String statusPending    = "Pending";
  static const String statusInProgress = "In Progress";
  static const String statusResolved   = "Resolved";

  // ── Department Manager ──
  static const String myDepartments = "/manager/my-departments";
  static const String managerStats  = "/manager/statistics";

  // ── Authority Manager ──
  static const String allDepartments = "/departments";
  static const String adminCreateUser = "/admin/create-user";

  // ── Chat ──
  static String openChat(int id)    => "/chat/open/$id";
  static String chatHistory(int id) => "/chat/complaints/$id";
  static String sendMessage(int id) => "/chat/send-message/$id";
  static const String allChats         = "/chat/all";
  static const String toggleChatStatus = "/chat/toggle-status";

  // ── Notifications ──
  static const String notifications            = "/notifications";
  static const String notificationsLatest      = "/notifications/latest";
  static const String unreadNotificationsCount = "/notifications/unread-count";
  static const String markAllNotificationsRead = "/notifications/read-all";
  static String markNotificationRead(int id)   => "/notifications/$id/read";
  static String deleteNotification(int id)     => "/notifications/$id";

  // ── Escalation ──
  static const String runAutomaticEscalation = "/escalate-complaints";
}
