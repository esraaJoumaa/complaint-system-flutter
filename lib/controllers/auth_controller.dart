import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/routes/app_routes.dart';
import '../models/user_model.dart';
import '../core/storage/token_storage.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  final AuthService _authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  String? tempEmail;
  String? tempUsername;

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final user = await _authService.login(username, password);
      _saveUserSession(user);
      currentUser.value = user;
      _navigateByRole(user);
    } catch (e) {
      _showError('فشل تسجيل الدخول', e);
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String birthdate,
  }) async {
    isLoading.value = true;
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        birthdate: birthdate,
      );

      tempEmail = email;
      tempUsername = user.username;
      currentUser.value = user;

      if ((user.username ?? '').isNotEmpty) {
        _showUsernameDialog(user.username!);
      } else {
        Get.snackbar(
          'تم إرسال الرمز',
          'يرجى التحقق من بريدك الإلكتروني',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        Get.toNamed(Routes.OTP);
      }
    } catch (e) {
      _showError('خطأ في التسجيل', e);
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  void _showUsernameDialog(String username) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00838F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF00838F),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اسم المستخدم الخاص بك',
                  style: TextStyle(
                    color: Color(0xFF006064),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'احفظ اسم المستخدم هذا — ستحتاجه لتسجيل الدخول لاحقاً:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00838F).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF006064),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.OTP);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006064), Color(0xFF00838F)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'فهمت، انتقل للتحقق',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ──────────────────────────────────────────────
  Future<void> verifyOtp(String code) async {
    if (tempEmail == null) {
      Get.snackbar('خطأ', 'لم يتم العثور على البريد الإلكتروني');
      return;
    }
    isLoading.value = true;
    try {
      final user = await _authService.verifyEmail(tempEmail!, code);
      _saveUserSession(user);
      currentUser.value = user;

      Get.snackbar(
        'تم التحقق ✓',
        'مرحباً ${user.name}، تم تفعيل حسابك بنجاح',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      _navigateByRole(user);
    } catch (e) {
      _showError('فشل التحقق', e);
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────
  Future<void> logout() async {
    await TokenStorage.clear();
    _storage.erase();
    currentUser.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  // ──────────────────────────────────────────────
  void _navigateByRole(UserModel user) {
    final String role = user.roleName?.toLowerCase().trim() ?? '';
    switch (role) {
      case 'manager':
        Get.offAllNamed(Routes.AUTHORITY_DASHBOARD);
        break;
      case 'dept_manager':
        Get.offAllNamed(Routes.MANAGER_DASHBOARD);
        break;
      case 'employee':
        Get.offAllNamed(Routes.EMPLOYEE_DASHBOARD);
        break;
      case 'admin':
        Get.offAllNamed(Routes.AUTHORITY_DASHBOARD);
        break;
      case 'user':
      default:
        Get.offAllNamed(Routes.DASHBOARD);
        break;
    }
  }

  // ──────────────────────────────────────────────
  void _saveUserSession(UserModel user) {
    _storage.write('isLoggedIn', true);
    _storage.write('isEmailVerified', true);
    _storage.write('user_role', user.roleName);
    _storage.write('user_data', user.toJson());
  }

  void _showError(String title, Object e) {
    String msg = e.toString().replaceAll('Exception: ', '');
    if (msg.contains('1062')) msg = 'هذا البريد الإلكتروني مستخدم بالفعل';
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
