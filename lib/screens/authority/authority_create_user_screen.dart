import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/authority/authority_controller.dart';

class AuthorityCreateUserScreen extends StatefulWidget {
  const AuthorityCreateUserScreen({super.key});

  @override
  State<AuthorityCreateUserScreen> createState() =>
      _AuthorityCreateUserScreenState();
}

class _AuthorityCreateUserScreenState extends State<AuthorityCreateUserScreen> {
  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  int _selectedRoleId = 4;

  // القسم المختار
  int? _selectedDepartmentId;

  late final AuthorityController _controller;

  static const int _authorityId = 1;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthorityController>();
    if (_controller.departments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.fetchAllDepartments();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 24),

                // ── اختيار الدور ──
                _buildSectionTitle('نوع الحساب', Icons.manage_accounts_rounded),
                const SizedBox(height: 12),
                _buildRoleSelector(),
                const SizedBox(height: 24),

                // ── البيانات الشخصية ──
                _buildSectionTitle(
                  'البيانات الشخصية',
                  Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _nameController,
                  hint: 'الاسم الكامل',
                  icon: Icons.badge_outlined,
                  direction: TextDirection.rtl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'الاسم الكامل مطلوب';
                    if (v.trim().length < 3) return 'الاسم قصير جداً';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _usernameController,
                  hint: 'اسم المستخدم (بالإنجليزية)',
                  icon: Icons.alternate_email_rounded,
                  direction: TextDirection.ltr,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'اسم المستخدم مطلوب';
                    if (v.contains(' ')) return 'لا يجوز استخدام المسافات';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _phoneController,
                  hint: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  direction: TextDirection.ltr,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'رقم الهاتف مطلوب';
                    if (v.trim().length < 9) return 'رقم الهاتف غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── بيانات الحساب ──
                _buildSectionTitle('بيانات الحساب', Icons.lock_outline_rounded),
                const SizedBox(height: 12),
                _buildField(
                  controller: _emailController,
                  hint: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  direction: TextDirection.ltr,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'البريد الإلكتروني مطلوب';
                    if (!GetUtils.isEmail(v.trim()))
                      return 'البريد الإلكتروني غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildPasswordField(),
                const SizedBox(height: 14),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),

                // ── بيانات التعيين ──
                _buildSectionTitle('بيانات التعيين', Icons.business_outlined),
                const SizedBox(height: 12),
                _buildDepartmentDropdown(),
                const SizedBox(height: 32),

                // ── زر الإنشاء ──
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _dark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'إنشاء مستخدم جديد',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
    );
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  Widget _buildPageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_dark, _primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'إنشاء مستخدم جديد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'موظف أو مدير قسم تابع لجهتك',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _RoleOption(
            label: 'موظف',
            icon: Icons.badge_rounded,
            roleId: 4,
            isSelected: _selectedRoleId == 4,
            onTap: () => setState(() => _selectedRoleId = 4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoleOption(
            label: 'مدير قسم',
            icon: Icons.manage_accounts_rounded,
            roleId: 3,
            isSelected: _selectedRoleId == 3,
            onTap: () => setState(() => _selectedRoleId = 3),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _dark,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primary, size: 18),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextDirection direction,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: direction == TextDirection.rtl
          ? TextAlign.right
          : TextAlign.left,
      textDirection: direction,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
      decoration: _fieldDecoration(hint, icon),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return StatefulBuilder(
      builder: (_, s) {
        return TextFormField(
          controller: _passwordController,
          obscureText: _obscurePass,
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
          decoration: _fieldDecoration(
            'كلمة المرور',
            Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _primary,
                size: 20,
              ),
              onPressed: () => s(() => _obscurePass = !_obscurePass),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
            if (v.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
            return null;
          },
        );
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return StatefulBuilder(
      builder: (_, s) {
        return TextFormField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
          decoration: _fieldDecoration(
            'تأكيد كلمة المرور',
            Icons.lock_reset_outlined,
            suffix: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _primary,
                size: 20,
              ),
              onPressed: () => s(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'تأكيد كلمة المرور مطلوب';
            if (v != _passwordController.text)
              return 'كلمتا المرور غير متطابقتين';
            return null;
          },
        );
      },
    );
  }

  InputDecoration _fieldDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  // ──────────────────────────────────────────────
  // Dropdown الأقسام
  // ──────────────────────────────────────────────
  Widget _buildDepartmentDropdown() {
    return Obx(() {
      final depts = _controller.departments;
      return DropdownButtonFormField<int>(
        value: _selectedDepartmentId,
        isExpanded: true,
        decoration: _fieldDecoration(
          depts.isEmpty ? 'جاري تحميل الأقسام...' : 'اختر القسم',
          Icons.business_outlined,
        ),
        items: depts.map((dept) {
          return DropdownMenuItem<int>(
            value: dept['id'] as int?,
            child: Text(
              dept['name']?.toString() ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedDepartmentId = val),
        validator: (v) => v == null ? 'يرجى اختيار القسم' : null,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
        dropdownColor: Colors.white,
      );
    });
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Obx(() {
      final isLoading = _controller.isLoadingAction.value;
      return GestureDetector(
        onTap: isLoading ? null : _onSubmit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
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
            borderRadius: BorderRadius.circular(16),
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }

  // ──────────────────────────────────────────────
  // ──────────────────────────────────────────────
  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartmentId == null) return;

    _controller.createUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
      roleId: _selectedRoleId,
      authorityId: _authorityId,
      departmentId: _selectedDepartmentId!,
    );
  }
}

// ══════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════
class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final int roleId;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.roleId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _primary : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? _primary : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _dark : Colors.grey,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
