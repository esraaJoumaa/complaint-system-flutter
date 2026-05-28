import 'package:get/get.dart';

import '../../models/complaint_model.dart';
import '../../models/employee_model.dart';
import '../../services/department_manager_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/routes/app_routes.dart';

class DepartmentManagerController extends GetxController {
  final DepartmentManagerService _service = DepartmentManagerService.instance;

  final RxBool isLoadingComplaints = false.obs;
  final RxBool isLoadingAction     = false.obs;

  final RxList<ComplaintModel> complaints     = <ComplaintModel>[].obs;
  final Rx<ComplaintModel?> selectedComplaint = Rx<ComplaintModel?>(null);
  final RxString currentStatus               = 'new'.obs;

  final RxList<Map<String, dynamic>> myDepartments = <Map<String, dynamic>>[].obs;
  final Rx<EmployeeModel?> createdEmployee         = Rx<EmployeeModel?>(null);

  final RxString complaintsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComplaintsByStatus(currentStatus.value);
    fetchMyDepartments();
  }

  // ──────────────────────────────────────────────
  // 1. الشكاوي
  // ──────────────────────────────────────────────

  Future<void> fetchComplaintsByStatus(String status) async {
    try {
      currentStatus(status);
      isLoadingComplaints(true);
      complaintsError('');
      final result = await _service.fetchComplaintsByStatus(status);
      complaints.assignAll(result);
    } catch (e) {
      complaintsError(e.toString());
      _showError('تعذر جلب الشكاوى');
    } finally {
      isLoadingComplaints(false);
    }
  }

  Future<void> fetchComplaints() async =>
      fetchComplaintsByStatus(currentStatus.value);

  Future<void> openComplaint(ComplaintModel complaint) async {
    selectedComplaint.value = complaint;

    if (complaint.status.toLowerCase() == 'pending') {
      try {
        await _service.updateComplaintStatus(complaint.id!, 'in_progress');
        selectedComplaint.value =
            _copyWithStatus(complaint, ApiConstants.statusInProgress);
      } catch (_) {
      }
    }

    Get.toNamed(
      Routes.MANAGER_COMPLAINT_DETAIL,
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
      isLoadingAction(true);
      await _service.respondToComplaint(id, replyText);
      Get.back();
      _showSuccess('تم إغلاق الشكوى وإشعار المواطن بنجاح');
      await fetchComplaintsByStatus(currentStatus.value);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingAction(false);
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      isLoadingAction(true);
      await _service.updateComplaintStatus(id, status);
      await fetchComplaintsByStatus(currentStatus.value);
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingAction(false);
    }
  }

  // ──────────────────────────────────────────────
  // 2. الشات
  // ──────────────────────────────────────────────
  void openChat(ComplaintModel complaint) {
    Get.toNamed(Routes.CHAT, arguments: {
      'complaint_id': complaint.id,
      'complaint_title': complaint.title,
    });
  }

  // ──────────────────────────────────────────────
  // 3. إنشاء موظف
  // ──────────────────────────────────────────────
  Future<void> fetchMyDepartments() async {
    try {
      final result = await _service.fetchMyDepartments();
      myDepartments.assignAll(result);
    } catch (_) {}
  }

  Future<void> createEmployee({
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
      isLoadingAction(true);
      final employee = await _service.createEmployee(
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
      createdEmployee.value = employee;
      Get.back();
      _showSuccess('تم إنشاء حساب ${employee.name} بنجاح');
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingAction(false);
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
        'نجاح ✓', message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

  void _showError(String message) => Get.snackbar(
        'خطأ', message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
}
