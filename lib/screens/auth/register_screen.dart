import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                Container(
                  width: 80,
                  height: 80,
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
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'أدخل بياناتك للتسجيل في النظام',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),

                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'بعد التحقق ستحصل على اسم مستخدم للدخول لاحقاً',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF006064),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF00838F),
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _field(
                  controller: _nameController,
                  hint: 'الاسم الكامل',
                  icon: Icons.person_outline_rounded,
                  dir: TextDirection.rtl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
                    if (v.trim().length < 3) return 'الاسم قصير جداً';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _field(
                  controller: _phoneController,
                  hint: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  dir: TextDirection.ltr,
                  keyboard: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'رقم الهاتف مطلوب';
                    if (v.trim().length < 9) return 'رقم الهاتف غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── البريد ──
                _field(
                  controller: _emailController,
                  hint: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  dir: TextDirection.ltr,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'البريد مطلوب';
                    if (!GetUtils.isEmail(v.trim())) return 'البريد غير صالح';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  textAlign: TextAlign.right,
                  onTap: _pickDate,
                  style: const TextStyle(
                    color: Color(0xFF37474F),
                    fontSize: 14,
                  ),
                  decoration: _dec('تاريخ الميلاد', Icons.cake_outlined),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'يرجى تحديد تاريخ الميلاد'
                      : null,
                ),
                const SizedBox(height: 14),

                _passField(
                  controller: _passwordController,
                  hint: 'كلمة المرور',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePass,
                  onToggle: () => setState(() => _obscurePass = !_obscurePass),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                    if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── تأكيد كلمة المرور ──
                _passField(
                  controller: _confirmController,
                  hint: 'تأكيد كلمة المرور',
                  icon: Icons.lock_reset_outlined,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'تأكيد كلمة المرور مطلوب';
                    if (v != _passwordController.text)
                      return 'كلمتا المرور غير متطابقتين';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                Obx(() {
                  final loading = _auth.isLoading.value;
                  return GestureDetector(
                    onTap: loading ? null : _onSubmit,
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
                                'متابعة',
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

                GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: const TextSpan(
                      text: 'لديك حساب؟ ',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'سجل دخول الآن',
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextDirection dir,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: dir == TextDirection.rtl ? TextAlign.right : TextAlign.left,
      textDirection: dir,
      keyboardType: keyboard,
      style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
      decoration: _dec(hint, icon),
      validator: validator,
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
      decoration: _dec(
        hint,
        icon,
        suffix: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _primary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
      prefixIcon: Icon(icon, color: _primary, size: 20),
      suffixIcon: suffix,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      birthdate: _dateController.text.trim(),
    );
  }
}
