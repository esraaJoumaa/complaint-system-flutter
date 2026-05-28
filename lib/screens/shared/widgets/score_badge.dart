import 'package:flutter/material.dart';

class ScoreBadge extends StatelessWidget {
  final int score;
  final bool showLabel;

  const ScoreBadge({super.key, required this.score, this.showLabel = true});

  Color get _badgeColor {
    if (score >= 80) return const Color(0xFF00838F);
    if (score >= 50) return const Color(0xFF43A047);
    if (score >= 20) return const Color(0xFFFFA000);
    return const Color(0xFFE53935);
  }

  String get _trustLabel {
    if (score >= 80) return 'موثوق';
    if (score >= 50) return 'مقبول';
    if (score >= 20) return 'محدود';
    return 'مشبوه';
  }

  IconData get _trustIcon {
    if (score >= 80) return Icons.verified_user_rounded;
    if (score >= 50) return Icons.person_rounded;
    if (score >= 20) return Icons.warning_amber_rounded;
    return Icons.gpp_bad_rounded;
  }

  @override
  Widget build(BuildContext context) {
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
            'سكور: $score',
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
