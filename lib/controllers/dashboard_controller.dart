import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/notification_service.dart';

class DashboardController extends GetxController {
  final NotificationService _notifService = NotificationService.instance;

  final RxInt unreadCount = 0.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoadingNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  // ──────────────────────────────────────────────
  Future<void> _loadNotifications() async {
    try {
      isLoadingNotifications.value = true;
      final count = await _notifService.fetchUnreadCount();
      unreadCount.value = count;

      if (count > 0) {
        final latest = await _notifService.fetchLatest();
        notifications.assignAll(latest);
        final unread = latest.where((n) => !n.isRead).toList();
        if (unread.isNotEmpty) {
          _showNotificationsDialog(unread);
        }
      }
    } catch (_) {
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  Future<void> refreshNotifications() => _loadNotifications();

  Future<void> markAllAsRead() async {
    await _notifService.markAllAsRead();
    unreadCount.value = 0;
  }

  // ──────────────────────────────────────────────
  void _showNotificationsDialog(List<NotificationModel> unread) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (Get.isDialogOpen != true) {
        Get.dialog(
          _NotificationsDialog(
            notifications: unread,
            onMarkAllRead: () {
              Get.back();
              markAllAsRead();
            },
          ),
          barrierDismissible: true,
        );
      }
    });
  }
}

// ══════════════════════════════════════════════════════
class _NotificationsDialog extends StatelessWidget {
  final List<NotificationModel> notifications;
  final VoidCallback onMarkAllRead;

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);

  const _NotificationsDialog({
    required this.notifications,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_dark, _primary]),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Row(
                  children: [
                    const Text(
                      'إشعارات جديدة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${notifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) =>
                  _NotificationTile(notification: notifications[i]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: GestureDetector(
              onTap: onMarkAllRead,
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_dark, _primary],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'تعيين الكل كمقروء',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  static const Color _primary = Color(0xFF00838F);

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (notification.title.isNotEmpty)
                  Text(
                    notification.title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF006064),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (notification.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(notification.createdAt!),
                    style: const TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: _primary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
      '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
