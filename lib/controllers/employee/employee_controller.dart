import 'package:get/get.dart';

import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';
import '../../core/routes/app_routes.dart';

class EmployeeController extends GetxController {
  final ComplaintService _service = ComplaintService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingAction = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentStatus = 'new'.obs;

  final RxList<ComplaintModel> complaints = <ComplaintModel>[].obs;
  final Rx<ComplaintModel?> selectedComplaint = Rx<ComplaintModel?>(null);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is String) {
      currentStatus.value = Get.arguments as String;
    }
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _service.getComplaintsByStatus(currentStatus.value);
      complaints.assignAll(result);
    } catch (e) {
      errorMessage(e.toString());
      _showError('تعذر جلب الشكاوى');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchComplaintsByStatus(String status) async {
    currentStatus.value = status;
    await fetchComplaints();
  }

  Future<void> openAndProcessComplaint(ComplaintModel complaint) async {
    selectedComplaint.value = complaint;

    if (complaint.status == 'new' || complaint.status == 'pending') {
      try {
        await _service.updateComplaintStatus(complaint.id!, 'in_progress');
        selectedComplaint.value = _copyWithStatus(complaint, 'in_progress');
      } catch (_) {}
    }

    Get.toNamed(Routes.COMPLAINT_DETAILS, arguments: selectedComplaint.value);
  }

  Future<void> closeComplaint(int id, String responseText) async {
    if (responseText.trim().isEmpty) {
      _showError('يرجى كتابة الرد قبل الإغلاق');
      return;
    }

    try {
      isLoadingAction(true);
      await _service.respondToComplaint(id, responseText);

      Get.back();
      Get.back();
      _showSuccess('تم إغلاق الشكوى وإشعار المواطن بنجاح');
      await fetchComplaints();
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingAction(false);
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

  ComplaintModel _copyWithStatus(ComplaintModel c, String status) {
    return ComplaintModel(
      id: c.id,
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
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'نجاح ✓',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
