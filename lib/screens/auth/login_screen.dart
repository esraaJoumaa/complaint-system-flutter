import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primary    = Color(0xFF00838F);
  static const Color _dark       = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  _buildLogo(),
                  const SizedBox(height: 40),

                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل بياناتك للوصول إلى حسابك',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildUsernameField(),
                  const SizedBox(height: 16),

                  _buildPasswordField(),
                  const SizedBox(height: 32),

                  _buildLoginButton(),
                  const SizedBox(height: 24),

                  _buildRegisterLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  // ──────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_dark, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.assignment_outlined,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // حقل اسم المستخدم
  // ──────────────────────────────────────────────
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
      decoration: InputDecoration(
        hintText: 'اسم المستخدم',
        hintTextDirection: TextDirection.rtl,
        hintStyle:
            const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
        prefixIcon:
            const Icon(Icons.person_outline_rounded, color: _primary, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال اسم المستخدم';
        }
        return null;
      },
    );
  }

  // ──────────────────────────────────────────────
  // حقل كلمة المرور
  // ──────────────────────────────────────────────
  Widget _buildPasswordField() {
    return StatefulBuilder(
      builder: (_, setInnerState) {
        return TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'كلمة المرور',
            hintTextDirection: TextDirection.rtl,
            hintStyle:
                const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
            prefixIcon:
                const Icon(Icons.lock_outline_rounded, color: _primary, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _primary,
                size: 20,
              ),
              onPressed: () {
                setInnerState(
                    () => _obscurePassword = !_obscurePassword);
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _primary.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _primary.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            return null;
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // زر الدخول
  // ──────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Obx(() {
      final isLoading = _authController.isLoading.value;
      return GestureDetector(
        onTap: isLoading ? null : _handleLogin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: isLoading
                ? const LinearGradient(
                    colors: [Color(0xFF80CBC4), Color(0xFF80CBC4)],
                  )
                : const LinearGradient(
                    colors: [_dark, _primary],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: isLoading
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
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'دخول',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      );
    });
  }

  // ──────────────────────────────────────────────
  // رابط التسجيل
  // ──────────────────────────────────────────────
  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () => Get.toNamed('/register'),
      child: RichText(
        text: const TextSpan(
          text: 'ليس لديك حساب؟ ',
          style: TextStyle(color: Colors.black54, fontSize: 14),
          children: [
            TextSpan(
              text: 'سجل الآن',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // تنفيذ الدخول
  // ──────────────────────────────────────────────
  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    _authController.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
  }
}
