import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rating_controller.dart';
import '../../models/rating_model.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String complainId = args['complainId']?.toString() ?? '';
    final String authorityName = args['authorityName']?.toString() ?? 'الجهة';
    final controller = Get.find<RatingController>();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        title: const Text('Rate the Service'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_dark, _primary]),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.hasRated.value &&
            controller.ratingResponse.value != null) {
          return _SuccessView(response: controller.ratingResponse.value!);
        }

        // ── نموذج التقييم ─────────────────────────────────────────────
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── أيقونة ──
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 44,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'How would you rate',
                style: TextStyle(fontSize: 16, color: Color(0xFF546E7A)),
              ),
              const SizedBox(height: 4),
              Text(
                authorityName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Rate the response speed and service quality',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
              ),
              const SizedBox(height: 32),

              _StarSelector(controller: controller),
              const SizedBox(height: 8),
              _ScoreLabel(score: controller.selectedScore.value),
              const SizedBox(height: 32),

              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'Comment (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _dark,
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
                  hintText: 'Share your experience...',
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
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isRatingLoading.value
                        ? null
                        : () => controller.submitRating(complainId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
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
                            'Submit Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

// ──────────────────────────────────────────────────────────────────────────
class _StarSelector extends StatelessWidget {
  final RatingController controller;
  const _StarSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final starIndex = 5 - i; // RTL: 5 يسار → 1 يمين
          final isSelected = controller.selectedScore.value >= starIndex;
          return GestureDetector(
            onTap: () => controller.setScore(starIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  key: ValueKey('$starIndex-$isSelected'),
                  size: 48,
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

// ──────────────────────────────────────────────────────────────────────────
class _ScoreLabel extends StatelessWidget {
  final int score;
  const _ScoreLabel({required this.score});

  static const _labels = {
    1: ('Very Poor', Color(0xFFE53935)),
    2: ('Poor', Color(0xFFFF7043)),
    3: ('Average', Color(0xFFFFA000)),
    4: ('Good', Color(0xFF43A047)),
    5: ('Excellent! 🎉', Color(0xFF00838F)),
  };

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const SizedBox(height: 22);
    final (label, color) = _labels[score]!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
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

// ──────────────────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final RatingResponse response;
  const _SuccessView({required this.response});

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);

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
                color: _primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: _primary,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Thank you for your rating! ⭐',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Average rating for ${response.authority.name}',
              style: const TextStyle(color: Color(0xFF546E7A), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avg.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 34,
                ),
              ],
            ),
            Text(
              'Based on $total ratings',
              style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Tracking',
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
