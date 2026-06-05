import 'package:flutter/material.dart';

class ScoreBadge extends StatelessWidget {
  final int? score;
  final bool showLabel;
  final bool isNew;

  const ScoreBadge({
    super.key,
    required this.score,
    this.showLabel = true,
    this.isNew = false,
  });

  bool get _isNewUser => isNew || score == null;

  Color get _badgeColor {
    if (_isNewUser) return const Color(0xFF78909C); // رمادي — جديد
    final s = score!;
    if (s >= 80) return const Color(0xFF00838F); // تيل   — موثوق
    if (s >= 50) return const Color(0xFF43A047); // أخضر  — جيد
    if (s >= 20) return const Color(0xFFFFA000); // أصفر  — مقبول
    if (s > 0) return const Color(0xFFE53935); // أحمر  — منخفض
    return const Color(0xFFE53935); // أحمر  — صفر/سلبي
  }

  String get _trustLabel {
    if (_isNewUser) return 'New';
    final s = score!;
    if (s >= 80) return 'Trusted';
    if (s >= 50) return 'Good';
    if (s >= 20) return 'Fair';
    return 'Low';
  }

  IconData get _trustIcon {
    if (_isNewUser) return Icons.person_add_rounded;
    final s = score!;
    if (s >= 80) return Icons.verified_user_rounded;
    if (s >= 50) return Icons.thumb_up_rounded;
    if (s >= 20) return Icons.warning_amber_rounded;
    return Icons.gpp_bad_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final displayScore = _isNewUser ? '--' : '$score';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _badgeColor.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_trustIcon, size: 14, color: _badgeColor),
          const SizedBox(width: 4),
          Text(
            'Score: $displayScore',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _badgeColor,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              '· $_trustLabel',
              style: TextStyle(fontSize: 11, color: _badgeColor),
            ),
          ],
        ],
      ),
    );
  }
}
