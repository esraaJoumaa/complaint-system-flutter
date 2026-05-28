import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rating_controller.dart';
import '../../core/constants/app_colors.dart'; // primary / dark / background
import '../../models/rating_model.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String complainId = args['complainId']?.toString() ?? '';
    final String authorityName = args['authorityName']?.toString() ?? 'الجهة';

    final controller = Get.find<RatingController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        title: const Text('تقييم الخدمة'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.hasRated.value &&
            controller.ratingResponse.value != null) {
          return _SuccessView(response: controller.ratingResponse.value!);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'كيف تقيّم استجابة',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                authorityName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _StarSelector(controller: controller),
              const SizedBox(height: 8),
              _ScoreLabel(score: controller.selectedScore.value),
              const SizedBox(height: 32),

              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'تعليق (اختياري)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                maxLength: 300,
                onChanged: (v) => controller.comment.value = v,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'شاركنا رأيك حول سرعة الاستجابة وجودة الخدمة...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isRatingLoading.value
                      ? null
                      : () => controller.submitRating(complainId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isRatingLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'إرسال التقييم',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _StarSelector extends StatelessWidget {
  final RatingController controller;
  const _StarSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final starIndex = 5 - i; // RTL: 5 على اليسار، 1 على اليمين
          final isSelected = controller.selectedScore.value >= starIndex;
          return GestureDetector(
            onTap: () => controller.setScore(starIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  key: ValueKey('$starIndex-$isSelected'),
                  size: 46,
                  color: isSelected
                      ? const Color(0xFFFFC107)
                      : Colors.grey[300],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ScoreLabel extends StatelessWidget {
  final int score;
  const _ScoreLabel({required this.score});

  static const _labels = {
    1: ('سيئ جداً', Color(0xFFE53935)),
    2: ('سيئ', Color(0xFFFF7043)),
    3: ('مقبول', Color(0xFFFFA000)),
    4: ('جيد', Color(0xFF43A047)),
    5: ('ممتاز! 🎉', Color(0xFF00838F)),
  };

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const SizedBox(height: 22);
    final (label, color) = _labels[score]!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        label,
        key: ValueKey(score),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final RatingResponse response;
  const _SuccessView({required this.response});

  @override
  Widget build(BuildContext context) {
    final avg = response.authority.averageRating;
    final total = response.authority.totalRatings;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'شكراً لتقييمك! ⭐',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'متوسط تقييم ${response.authority.name}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 32,
                ),
              ],
            ),
            Text(
              'من $total تقييم',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'العودة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
