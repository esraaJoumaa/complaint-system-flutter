import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/complaint_controller.dart';

class ComplaintFormPage extends StatelessWidget {
  ComplaintFormPage({super.key});

  static const Color _primary = Color(0xFF00838F);
  static const Color _dark = Color(0xFF006064);
  static const Color _background = Color(0xFFE0F7FA);

  final ComplaintController controller = Get.put(ComplaintController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تقديم شكوى جديدة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
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
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            // ✅ محاذاة لليمين
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── البيانات الشخصية ──
              _sectionHeader('البيانات الشخصية', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _textField(
                controller: controller.fullNameController,
                hint: 'الاسم الثلاثي بالعربية أو الإنجليزية',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),

              // ── بيانات الشكوى ──
              _sectionHeader('بيانات الشكوى', Icons.description_outlined),
              const SizedBox(height: 12),
              _buildAuthorityDropdown(),
              const SizedBox(height: 14),
              _buildDepartmentDropdown(),
              const SizedBox(height: 14),
              _textField(
                controller: controller.titleController,
                hint: 'عنوان مختصر وواضح',
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 14),
              _textField(
                controller: controller.descriptionController,
                hint: 'اكتب تفاصيل شكواك هنا...',
                icon: Icons.edit_note_rounded,
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // ── المرفقات ──
              _sectionHeader('المرفقات (اختياري)', Icons.attach_file_rounded),
              const SizedBox(height: 12),
              _buildAttachmentBox(),
              const SizedBox(height: 28),

              // ── زر التقديم ──
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _dark,
            fontSize: 16,
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
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: Color(0xFF37474F), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: _primary, size: 20)
            : null,
        suffixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(top: 12, right: 4),
                child: Icon(icon, color: _primary, size: 20),
              )
            : null,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 14,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  Widget _buildAuthorityDropdown() {
    return Obx(
      () => DropdownButtonFormField<int>(
        value: controller.selectedAuthorityId.value == 0
            ? null
            : controller.selectedAuthorityId.value,
        decoration: _dropdownDec('الجهة', Icons.domain_rounded),
        items: controller.authorities.entries
            .map(
              (e) => DropdownMenuItem<int>(
                value: e.key,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      color: Color(0xFF37474F),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) {
          controller.selectedAuthorityId.value = val ?? 0;
          controller.selectedDepartmentId.value = 0;
        },
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
        dropdownColor: Colors.white,
        isExpanded: true,
      ),
    );
  }

  // ──────────────────────────────────────────────
  Widget _buildDepartmentDropdown() {
    return Obx(() {
      final depts = controller.currentDepartments;
      return DropdownButtonFormField<int>(
        key: ValueKey(controller.selectedAuthorityId.value),
        value: controller.selectedDepartmentId.value == 0
            ? null
            : controller.selectedDepartmentId.value,
        decoration: _dropdownDec('القسم', Icons.business_outlined),
        items: depts.entries
            .map(
              (e) => DropdownMenuItem<int>(
                value: e.key,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    e.value,
                    style: const TextStyle(
                      color: Color(0xFF37474F),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: depts.isEmpty
            ? null
            : (val) => controller.selectedDepartmentId.value = val ?? 0,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
        dropdownColor: Colors.white,
        isExpanded: true,
      );
    });
  }

  InputDecoration _dropdownDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _primary, fontSize: 13),
      prefixIcon: Icon(icon, color: _primary, size: 20),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ──────────────────────────────────────────────
  Widget _buildAttachmentBox() {
    return GestureDetector(
      onTap: () => controller.pickAttachment(),
      child: Obx(() {
        final count = controller.attachmentPaths.length;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: count > 0 ? _primary : _primary.withOpacity(0.3),
              width: count > 0 ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  count > 0
                      ? Icons.check_circle_outline_rounded
                      : Icons.cloud_upload_outlined,
                  size: 28,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                count == 0
                    ? 'أضف صوراً أو ملفات توضيحية'
                    : 'تم اختيار $count ملف',
                style: TextStyle(
                  color: count == 0 ? const Color(0xFF90A4AE) : _dark,
                  fontSize: 13,
                  fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر ملفاً',
                style: TextStyle(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ──────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = controller.isUploading.value;
      return GestureDetector(
        onTap: loading ? null : () => controller.submitComplaint(),
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
            borderRadius: BorderRadius.circular(16),
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تقديم الشكوى',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
