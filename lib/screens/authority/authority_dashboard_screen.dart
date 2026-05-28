import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/authority/authority_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/routes/app_routes.dart';

class AuthorityDashboardScreen extends StatelessWidget {
  const AuthorityDashboardScreen({super.key});

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthorityController>();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: () async {
            await controller.fetchComplaintsByStatus(
              controller.currentStatus.value,
            );
            await controller.fetchAllDepartments();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(controller)),
              SliverToBoxAdapter(child: _buildComplaintsSection(controller)),
              SliverToBoxAdapter(child: _buildDepartmentsSection(controller)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  Widget _buildHeader(AuthorityController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_dark, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IconBtn(
                icon: Icons.logout_rounded,
                tooltip: 'تسجيل الخروج',
                onTap: _confirmLogout,
              ),
              Row(
                children: [
                  _IconBtn(
                    icon: Icons.person_add_alt_1_rounded,
                    tooltip: 'إنشاء مستخدم',
                    onTap: () => Get.toNamed(Routes.AUTHORITY_CREATE_USER),
                  ),
                  const SizedBox(width: 10),
                  _IconBtn(
                    icon: Icons.notifications_none_rounded,
                    tooltip: 'الإشعارات',
                    onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.domain_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'لوحة تحكم مدير الجهة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // عدد الأقسام
          Obx(
            () => Center(
              child: Text(
                '${controller.departments.length} قسم تحت إشرافك',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  Widget _buildComplaintsSection(AuthorityController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionHeader(title: 'إدارة الشكاوي'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CategoryCard(
                  icon: Icons.fiber_new_rounded,
                  label: 'الجديدة',
                  color: const Color(0xFF00838F),
                  onTap: () {
                    controller.fetchComplaintsByStatus('new');
                    Get.toNamed(Routes.AUTHORITY_COMPLAINTS, arguments: 'new');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'قيد المعالجة',
                  color: const Color(0xFF0097A7),
                  onTap: () {
                    controller.fetchComplaintsByStatus('in_progress');
                    Get.toNamed(
                      Routes.AUTHORITY_COMPLAINTS,
                      arguments: 'in_progress',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'المغلقة',
                  color: const Color(0xFF006064),
                  onTap: () {
                    controller.fetchComplaintsByStatus('closed');
                    Get.toNamed(
                      Routes.AUTHORITY_COMPLAINTS,
                      arguments: 'closed',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // قسم الأقسام
  // ──────────────────────────────────────────────
  Widget _buildDepartmentsSection(AuthorityController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionHeader(title: 'الأقسام التابعة للجهة'),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingDepts.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: _primary),
                ),
              );
            }

            if (controller.deptsError.value.isNotEmpty) {
              return _buildDeptsError(controller);
            }

            if (controller.departments.isEmpty) {
              return _buildDeptsEmpty();
            }

            return Column(
              children: controller.departments
                  .map((dept) => _DepartmentCard(dept: dept))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeptsError(AuthorityController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.red.shade300, size: 36),
          const SizedBox(height: 8),
          Text(
            controller.deptsError.value,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade400, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: controller.fetchAllDepartments,
            icon: const Icon(Icons.refresh_rounded, color: _primary, size: 16),
            label: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: _primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptsEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.business_outlined, color: Color(0xFF80CBC4), size: 40),
          SizedBox(height: 8),
          Text(
            'لا توجد أقسام مسجلة',
            style: TextStyle(color: Color(0xFF546E7A)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // تأكيد تسجيل الخروج
  // ──────────────────────────────────────────────
  void _confirmLogout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: _dark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'هل أنت متأكد من تسجيل الخروج؟',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF546E7A), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEFF1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'إلغاء',
                            style: TextStyle(color: Color(0xFF546E7A)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.find<AuthController>().logout();
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'خروج',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  static const Color _dark = Color(0xFF006064);
  static const Color _primary = Color(0xFF00838F);

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _dark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 48,
          height: 3,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final Map<String, dynamic> dept;
  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);

  const _DepartmentCard({required this.dept});

  @override
  Widget build(BuildContext context) {
    final name = dept['name']?.toString() ?? '';
    final isActive = dept['is_active'] == true || dept['is_active'] == 1;
    final authority = dept['authority'] is Map
        ? dept['authority']['name']?.toString() ?? ''
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? _primary.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'نشط' : 'غير نشط',
              style: TextStyle(
                color: isActive ? _primary : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (authority.isNotEmpty)
                Text(
                  authority,
                  style: const TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: _primary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
