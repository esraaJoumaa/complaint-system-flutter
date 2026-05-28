import 'package:get/get.dart';

import '../../models/complaint_model.dart';
import '../../models/employee_model.dart';
import '../../services/authority_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/routes/app_routes.dart';

class AuthorityController extends GetxController {
  final AuthorityService _service = AuthorityService.instance;

  final RxBool isLoadingComplaints = false.obs;
  final RxBool isLoadingAction = false.obs;
  final RxBool isLoadingDepts = false.obs;

  final RxList<ComplaintModel> complaints = <ComplaintModel>[].obs;
  final RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;
  final Rx<ComplaintModel?> selectedComplaint = Rx<ComplaintModel?>(null);
  final Rx<EmployeeModel?> createdUser = Rx<EmployeeModel?>(null);
  final RxString currentStatus = 'new'.obs;

  final RxString complaintsError = ''.obs;
  final RxString deptsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComplaintsByStatus('new');
    fetchAllDepartments();
  }

  // ──────────────────────────────────────────────
  // 1. الشكاوي
  // ──────────────────────────────────────────────
  Future<void> fetchComplaintsByStatus(String status) async {
    try {
      currentStatus.value = status;
      isLoadingComplaints.value = true;
      complaintsError.value = '';
      final result = await _service.fetchComplaintsByStatus(status);
      complaints.assignAll(result);
    } catch (e) {
      complaintsError.value = e.toString();
      _showError('تعذر جلب الشكاوى');
    } finally {
      isLoadingComplaints.value = false;
    }
  }

  Future<void> fetchComplaints() async =>
      fetchComplaintsByStatus(currentStatus.value);

  Future<void> openComplaint(ComplaintModel complaint) async {
    selectedComplaint.value = complaint;

    if (complaint.status.toLowerCase() == 'pending') {
      try {
        await _service.updateComplaintStatus(complaint.id!, 'in_progress');
        selectedComplaint.value = _copyWithStatus(
          complaint,
          ApiConstants.statusInProgress,
        );
      } catch (_) {
        // لا نوقف التنقل
      }
    }

    Get.toNamed(
      Routes.AUTHORITY_COMPLAINT_DETAIL,
      arguments: selectedComplaint.value,
    );
  }

  /// إغلاق الشكوى مع الرد الرسمي
  Future<void> closeComplaint(int id, String replyText) async {
    if (replyText.trim().isEmpty) {
      _showError('يرجى كتابة الرد قبل الإغلاق');
      return;
    }
    try {
      isLoadingAction.value = true;
      await _service.respondToComplaint(id, replyText);
      Get.back();
      _showSuccess('تم إغلاق الشكوى وإشعار المواطن بنجاح');
      await fetchComplaintsByStatus(currentStatus.value);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingAction.value = false;
    }
  }

  void openChat(ComplaintModel complaint) {
    Get.toNamed(
      Routes.CHAT,
      arguments: {
        'complaint_id': complaint.id,
        'complaint_title': complaint.title,
      },
    );
  }

  // ──────────────────────────────────────────────
  // 2. الأقسام
  // ──────────────────────────────────────────────
  Future<void> fetchAllDepartments() async {
    try {
      isLoadingDepts.value = true;
      deptsError.value = '';
      final result = await _service.fetchAllDepartments();
      departments.assignAll(result);
    } catch (e) {
      deptsError.value = e.toString();
    } finally {
      isLoadingDepts.value = false;
    }
  }

  // ──────────────────────────────────────────────
  // 3. إنشاء مستخدم جديد
  // ──────────────────────────────────────────────
  Future<void> createUser({
    required String name,
    required String email,
    required String username,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required int roleId,
    required int authorityId,
    required int departmentId,
  }) async {
    try {
      isLoadingAction.value = true;
      final user = await _service.createUser(
        name: name,
        email: email,
        username: username,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        roleId: roleId,
        authorityId: authorityId,
        departmentId: departmentId,
      );
      createdUser.value = user;
      Get.back();
      _showSuccess('تم إنشاء حساب ${user.name} بنجاح');
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingAction.value = false;
    }
  }

  // ──────────────────────────────────────────────

  ComplaintModel _copyWithStatus(ComplaintModel c, String status) {
    return ComplaintModel(
      id: c.id,
      complainNumber: c.complainNumber,
      userId: c.userId,
      authorityId: c.authorityId,
      departmentId: c.departmentId,
      currentDepartmentId: c.currentDepartmentId,
      attachmentsId: c.attachmentsId,
      attachments: c.attachments,
      fullName: c.fullName,
      title: c.title,
      description: c.description,
      status: status,
      isValid: c.isValid,
      createdAt: c.createdAt,
      resolvedAt: c.resolvedAt,
      assignedLevel: c.assignedLevel,
      canChat: c.canChat,
      currentLevelName: c.currentLevelName,
      levelName: c.levelName,
      priority: c.priority,
    );
  }

  void _showSuccess(String message) => Get.snackbar(
    'نجاح ✓',
    message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
  );

  void _showError(String message) => Get.snackbar(
    'خطأ',
    message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
  );
}
