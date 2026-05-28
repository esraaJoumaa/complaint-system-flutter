import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';

class RatingController extends GetxController {
  final RatingService _ratingService = RatingService();

  final RxInt selectedScore = 0.obs;
  final RxString comment = ''.obs;
  final RxBool isRatingLoading = false.obs;
  final RxBool hasRated = false.obs;
  final Rx<RatingResponse?> ratingResponse = Rx<RatingResponse?>(null);

  final RxString rejectionReason = ''.obs;
  final RxBool isRejectLoading = false.obs;
  final Rx<RejectComplaintResponse?> rejectResponse = Rx<RejectComplaintResponse?>(null);

  // ─────────────────────────────────────────────────────────────────────────
  Future<void> submitRating(String complainId) async {
    if (selectedScore.value == 0) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار تقييم من 1 إلى 5 نجوم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isRatingLoading.value = true;
    try {
      final result = await _ratingService.rateAuthority(
        complainId: complainId,
        responseSpeedScore: selectedScore.value,
        comment: comment.value.isEmpty ? null : comment.value,
      );

      ratingResponse.value = result;
      hasRated.value = true;

      Get.snackbar(
        'شكراً لك! ⭐',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRatingLoading.value = false;
    }
  }


  // ─────────────────────────────────────────────────────────────────────────
  Future<void> rejectComplaint(String complainId) async {
    if (rejectionReason.value.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى كتابة سبب الرفض',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isRejectLoading.value = true;
    try {
      final result = await _ratingService.rejectComplaint(
        complainId: complainId,
        rejectionReason: rejectionReason.value,
      );

      rejectResponse.value = result;

      if (result.isUserBanned) {
        Get.snackbar(
          '🚫 تم الحظر',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFFB71C1C),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'تم الرفض',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }

      Get.back(); // إغلاق الـ Dialog
      _refreshComplaintsIfAvailable();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRejectLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  void setScore(int score) => selectedScore.value = score;

  void resetRating() {
    selectedScore.value = 0;
    comment.value = '';
    hasRated.value = false;
    ratingResponse.value = null;
  }

  void resetRejection() {
    rejectionReason.value = '';
    rejectResponse.value = null;
  }

  void _refreshComplaintsIfAvailable() {
    for (final tag in ['employee', 'dept_manager', 'authority']) {
      if (Get.isRegistered(tag: tag)) {
        try {
          (Get.find(tag: tag) as dynamic).loadComplaints();
        } catch (_) {}
      }
    }
  }
}

