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

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    try {
      final user = await _authService.login(username, password);
      _saveUserSession(user);
      currentUser.value = user;
      _handleRoleBasedNavigation(user);
    } catch (e) {
      _showError('فشل تسجيل الدخول', e);
    } finally {
      isLoading.value = false;
    }
  }

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
      currentUser.value = user;

      Get.snackbar(
        'تم إرسال الرمز',
        'يرجى التحقق من بريدك الإلكتروني لرمز OTP',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );

      Get.toNamed(Routes.OTP);
    } catch (e) {
      _showError('خطأ في التسجيل', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String code) async {
    if (tempEmail == null) {
      Get.snackbar('خطأ', 'لم يتم العثور على البريد الإلكتروني');
      return;
    }

    isLoading.value = true;
    try {
      final bool isVerified = await _authService.verifyEmail(tempEmail!, code);
      if (isVerified) {
        _storage.write('isLoggedIn', true);
        _storage.write('isEmailVerified', true);
        if (currentUser.value != null) {
          _saveUserSession(currentUser.value!);
          _handleRoleBasedNavigation(currentUser.value!);
        }
      }
    } catch (e) {
      _showError('فشل التحقق', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _storage.erase();
    currentUser.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  void _handleRoleBasedNavigation(UserModel user) {
    final String role = user.roleName?.toLowerCase().trim() ?? 'citizen';

    switch (role) {
      case 'manager':
        Get.offAllNamed(Routes.MANAGER_DASHBOARD);
        break;
      case 'official':
        Get.offAllNamed(Routes.AUTHORITY_DASHBOARD);
        break;
      case 'employee':
        Get.offAllNamed(Routes.EMPLOYEE_DASHBOARD);
        break;
      case 'citizen':
      default:
        Get.offAllNamed(Routes.DASHBOARD);
        break;
    }
  }

  void _saveUserSession(UserModel user) {
    _storage.write('isLoggedIn', true);
    _storage.write('isEmailVerified', true);
    _storage.write('user_role', user.roleName);
    _storage.write('user_data', user.toJson());
  }

  void _showError(String title, Object e) {
    String message = e.toString().replaceAll('Exception: ', '');
    if (message.contains('1062')) {
      message = 'هذا البريد الإلكتروني مستخدم بالفعل';
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
