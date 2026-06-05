import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/department_manager/department_manager_controller.dart';
import '../../services/authority_service.dart';

class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  int? _selectedDepartmentId;
  static const int _employeeRoleId = 4;
  static const int _authorityId = 1;

  final RxList<Map<String, dynamic>> _departments =
      <Map<String, dynamic>>[].obs;
  final RxBool _loadingDepts = false.obs;

  late final DepartmentManagerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DepartmentManagerController>();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      _loadingDepts.value = true;
      final result = await AuthorityService.instance.fetchAllDepartments();
      _departments.assignAll(result);
    } catch (_) {
      // fallback: حاول من controller
      if (_controller.myDepartments.isNotEmpty) {
        _departments.assignAll(_controller.myDepartments);
      }
    } finally {
      _loadingDepts.value = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
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

                _buildSectionTitle(
                  'البيانات الشخصية',
                  Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _buildField(
                  _nameController,
                  'الاسم الكامل للموظف',
                  Icons.badge_outlined,
                  TextDirection.rtl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'الاسم الكامل مطلوب';
                    if (v.trim().length < 3) return 'الاسم قصير جداً';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  _usernameController,
                  'اسم المستخدم (بالإنجليزية)',
                  Icons.alternate_email_rounded,
                  TextDirection.ltr,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'اسم المستخدم مطلوب';
                    if (v.trim().length < 4) return 'اسم المستخدم قصير جداً';
                    if (v.contains(' ')) return 'لا يجوز استخدام المسافات';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  _phoneController,
                  'رقم الهاتف',
                  Icons.phone_outlined,
                  TextDirection.ltr,
                  keyboard: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'رقم الهاتف مطلوب';
                    if (v.trim().length < 9) return 'رقم الهاتف غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('بيانات الحساب', Icons.lock_outline_rounded),
                const SizedBox(height: 12),
                _buildField(
                  _emailController,
                  'البريد الإلكتروني',
                  Icons.email_outlined,
                  TextDirection.ltr,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'البريد الإلكتروني مطلوب';
                    if (!GetUtils.isEmail(v.trim()))
                      return 'البريد الإلكتروني غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  _passwordController,
                  'كلمة المرور',
                  Icons.lock_outline_rounded,
                  _obscurePassword,
                  () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                    if (v.length < 8) return 'يجب أن تكون 8 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  _confirmPassController,
                  'تأكيد كلمة المرور',
                  Icons.lock_reset_outlined,
                  _obscureConfirmPassword,
                  () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'تأكيد كلمة المرور مطلوب';
                    if (v != _passwordController.text)
                      return 'كلمتا المرور غير متطابقتين';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('بيانات التعيين', Icons.business_outlined),
                const SizedBox(height: 12),
                _buildDepartmentDropdown(),
                const SizedBox(height: 32),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // AppBar
  // ──────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _dark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'إضافة موظف جديد',
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
                'إضافة موظف جديد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'أدخل بيانات الموظف الجديد بدقة',
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

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon,
    TextDirection dir, {
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

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool obscure,
    VoidCallback onToggle, {
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

  Widget _buildDepartmentDropdown() {
    return Obx(() {
      if (_loadingDepts.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withOpacity(0.2)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primary,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'جاري تحميل الأقسام...',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
              ),
            ],
          ),
        );
      }

      if (_departments.isEmpty) {
        return GestureDetector(
          onTap: _fetchDepartments,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, color: Color(0xFF00838F), size: 18),
                SizedBox(width: 8),
                Text(
                  'لم يتم تحميل الأقسام — اضغط للمحاولة',
                  style: TextStyle(color: Color(0xFF546E7A), fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      return DropdownButtonFormField<int>(
        value: _selectedDepartmentId,
        isExpanded: true,
        decoration: _dec('اختر القسم', Icons.business_outlined),
        items: _departments.map((dept) {
          return DropdownMenuItem<int>(
            value: dept['id'] as int?,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                dept['name']?.toString() ?? '',
                style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
              ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartmentId == null) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار القسم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _controller.createEmployee(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPassController.text,
      roleId: _employeeRoleId,
      authorityId: _authorityId,
      departmentId: _selectedDepartmentId!,
    );
  }
}
