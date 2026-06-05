import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../core/auth/rbac.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildClosedBanner(),
          Expanded(child: _buildMessagesList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _dark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.complaintTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              controller.chatIsClosed.value ? 'مغلقة' : 'نشطة',
              style: TextStyle(
                color: controller.chatIsClosed.value
                    ? Colors.orange.shade200
                    : Colors.greenAccent.shade100,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (Rbac.isOfficialUser())
          Obx(
            () => IconButton(
              icon: Icon(
                controller.chatIsClosed.value
                    ? Icons.lock_open_rounded
                    : Icons.lock_rounded,
                color: Colors.white,
              ),
              tooltip: controller.chatIsClosed.value
                  ? 'فتح المحادثة'
                  : 'إغلاق المحادثة',
              onPressed: () =>
                  controller.toggleChatStatus(!controller.chatIsClosed.value),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: controller.refresh,
          tooltip: 'تحديث',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_dark, _primary]),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // شريط الإغلاق
  // ──────────────────────────────────────────────
  Widget _buildClosedBanner() {
    return Obx(() {
      if (!controller.chatIsClosed.value) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        color: Colors.orange.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, color: Colors.orange.shade600, size: 16),
            const SizedBox(width: 8),
            Text(
              'هذه المحادثة مغلقة حالياً',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ──────────────────────────────────────────────
  Widget _buildMessagesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: _primary));
      }

      final err = controller.error.value;
      if (err != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: Colors.red.shade300,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                err,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh_rounded, color: _primary),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: _primary),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: _primary.withOpacity(0.3),
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'لا توجد رسائل بعد',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 15),
              ),
              const SizedBox(height: 4),
              const Text(
                'ابدأ المحادثة الآن',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        physics: const BouncingScrollPhysics(),
        itemCount: controller.messages.length,
        itemBuilder: (_, i) {
          final m = controller.messages[i];

          final bool isMe = Rbac.isOfficialUser()
              ? m.isFromOfficial
              : m.isFromCitizen;

          return _MessageBubble(
            text: m.message,
            isMe: isMe,
            senderName: isMe ? '' : (m.senderName ?? ''),
            time: m.sentAt != null
                ? '${m.sentAt!.hour}:${m.sentAt!.minute.toString().padLeft(2, '0')}'
                : '',
          );
        },
      );
    });
  }

  // ──────────────────────────────────────────────
  Widget _buildInputArea() {
    return Obx(() {
      final bool canChat =
          controller.canSend.value && !controller.chatIsClosed.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── زر الإرسال ──
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: canChat && !controller.isSending.value
                      ? _primary
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: canChat
                      ? [
                          BoxShadow(
                            color: _primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: controller.isSending.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        onPressed: canChat ? controller.send : null,
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: controller.inputController,
                enabled: canChat,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
                decoration: InputDecoration(
                  hintText: canChat
                      ? 'اكتب رسالتك...'
                      : 'المحادثة مغلقة من قبل الإدارة',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: canChat
                        ? const Color(0xFFB0BEC5)
                        : Colors.orange.shade300,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: canChat
                      ? const Color(0xFFF5F5F5)
                      : Colors.orange.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: canChat ? (_) => controller.send() : null,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;
  final String time;

  static const Color _primary = Color(0xFF00838F);

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.senderName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withOpacity(0.3), width: 1),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _primary,
                size: 18,
              ),
            ),
          ],

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe && senderName.isNotEmpty) ...[
                    Text(
                      senderName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],

                  Text(
                    text,
                    textAlign: isMe ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF212121),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.75)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: _primary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
