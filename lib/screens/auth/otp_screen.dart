import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../controllers/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final TextEditingController _pinController = TextEditingController();
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String email = _auth.tempEmail ?? 'user@email.com';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _dark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 52,
                color: _primary,
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'التحقق من الحساب',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _dark,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'أدخل الرمز المكون من 6 أرقام\nالمرسل إلى:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(
                color: _primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            if ((_auth.tempUsername ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'اسم المستخدم الخاص بك (للدخول لاحقاً):',
                      style: TextStyle(color: Color(0xFF546E7A), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _auth.tempUsername!,
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            Pinput(
              length: 6,
              controller: _pinController,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              defaultPinTheme: PinTheme(
                width: 48,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 48,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              onCompleted: (pin) => _verify(pin),
            ),
            const SizedBox(height: 32),

            Obx(() {
              final loading = _auth.isLoading.value;
              return GestureDetector(
                onTap: loading ? null : () => _verify(_pinController.text),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: loading
                        ? const LinearGradient(
                            colors: [Color(0xFF80CBC4), Color(0xFF80CBC4)],
                          )
                        : const LinearGradient(
                            colors: [_dark, _primary],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: loading
                        ? []
                        : [
                            BoxShadow(
                              color: _primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'تأكيد الرمز',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: () => Get.snackbar(
                'تنبيه',
                'ميزة إعادة الإرسال ستُضاف قريباً',
                snackPosition: SnackPosition.BOTTOM,
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                color: _primary,
                size: 18,
              ),
              label: const Text(
                'لم يصلك الرمز؟ إعادة إرسال',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _verify(String pin) {
    if (pin.trim().length < 6) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال الرمز المكون من 6 أرقام كاملاً',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    _auth.verifyOtp(pin.trim());
  }
}
