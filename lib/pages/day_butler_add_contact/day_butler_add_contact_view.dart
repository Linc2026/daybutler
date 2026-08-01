import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/gradient_app_bar.dart';
import '../../components/text_field.dart';
import '../../main.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_add_contact_logic.dart';
class DayButlerAddContactView extends GetView<DayButlerAddContactLogic> {
  const DayButlerAddContactView({super.key});
  static const _cardShadow = [
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: GradientAppBar(
        toolbarHeight: 44.h,
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: controller.onCancelTap,
          child: Text('Cancel', style: TextStyle(fontSize: 14.sp, color: primaryColor)),
        ),
        leadingWidth: 72.w,
        title: Text(controller.pageTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSaving.value ? null : () => controller.onSaveTap(),
                child: controller.isSaving.value
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                      )
                    : Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: primaryColor)),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          children: [
            _buildAvatarPicker(),
            _buildBasicInfoSection(),
            SizedBox(height: 12.h),
            _buildBirthdaySection(),
            SizedBox(height: 12.h),
            _buildOptionalSection(),
            if (!controller.isEditMode) ...[
              SizedBox(height: 16.h),
              _buildSaveAnotherButton(),
            ],
            SizedBox(height: 16.h),
            _buildInfoHint(),
          ],
        ),
      ),
    );
  }
  Widget _buildAvatarPicker() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showAvatarSheet(Get.context!),
            child: Obx(() {
              final path = controller.avatarPath.value;
              final color = Color(controller.avatarColor);
              final hasPhoto = controller.hasAvatarPhoto;
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      image: hasPhoto
                          ? DecorationImage(image: FileImage(File(path!)), fit: BoxFit.cover)
                          : null,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: hasPhoto
                        ? null
                        : Center(
                            child: Text(
                              controller.avatarLetter,
                              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                  ),
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A06A),
                      shape: BoxShape.circle,
                      border: Border.all(color: bgColor, width: 2),
                    ),
                    child: Icon(Icons.camera_alt, size: 11.sp, color: Colors.white),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 8.h),
          Text('Tap to add photo or style', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999))),
        ],
      ),
    );
  }
  void _showAvatarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 6.h),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0D6D2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 4.h),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.camera_alt, color: primaryColor, size: 22.sp),
                  title: Text('Take Photo', style: TextStyle(fontSize: 15.sp)),
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.photo_library, color: primaryColor, size: 22.sp),
                  title: Text('Choose from Library', style: TextStyle(fontSize: 15.sp)),
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.palette_outlined, color: primaryColor, size: 22.sp),
                  title: Text('Choose Style', style: TextStyle(fontSize: 15.sp)),
                  onTap: () {
                    Get.back();
                    _showStylePackSheet(context);
                  },
                ),
                if (controller.avatarPath.value != null)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_outline, color: Colors.red, size: 22.sp),
                    title: Text('Remove Photo / Style', style: TextStyle(fontSize: 15.sp, color: Colors.red)),
                    onTap: () {
                      Get.back();
                      controller.removeAvatar();
                    },
                  ),
                ListTile(
                  dense: true,
                  title: Text('Cancel', textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, color: Colors.grey)),
                  onTap: () => Get.back(),
                ),
              ],
            )),
      ),
    );
  }
  void _showStylePackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0D6D2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text('Avatar Style', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 4.h),
              Text('Pick a color for the letter avatar.',
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999))),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: avatarStyleColors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.onStyleColorSelect(c);
                    },
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(color: Color(c).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _cardShadow,
      ),
      child: child,
    );
  }
  Widget _buildBasicInfoSection() {
    return _buildCard(
      child: Column(
        children: [
          _buildFormRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Name', required: true),
                SizedBox(height: 2.h),
                Obx(() => MyTextField(
                      value: controller.name.value,
                      onChange: controller.onNameChanged,
                      hintText: 'Full name',
                      maxLength: 50,
                      textStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A)),
                    )),
                Obx(() => controller.nameError.value
                    ? Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text('Required', style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C))),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            isLast: false,
          ),
          _buildFormRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Relationship', required: true),
                SizedBox(height: 4.h),
                Obx(() => Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: controller.relationships
                          .map((rel) => _buildChip(
                                rel,
                                controller.relationship.value == rel,
                                () => controller.onRelationshipSelect(rel),
                              ))
                          .toList(),
                    )),
                Obx(() => controller.relationshipError.value
                    ? Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text('Required', style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C))),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }
  Widget _buildBirthdaySection() {
    return _buildCard(
      child: _buildFormRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Birthday'),
            SizedBox(height: 4.h),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.onPickBirthday,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EBE6),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cake_outlined, size: 16.sp, color: primaryColor),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  controller.birthdayLabel,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: controller.birthday.value == null
                                        ? const Color(0xFF999999)
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 16.sp, color: const Color(0xFFBBBBBB)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (controller.birthday.value != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.only(left: 4.w),
                        constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
                        onPressed: controller.onClearBirthday,
                        icon: Icon(Icons.close, size: 16.sp, color: const Color(0xFF999999)),
                      ),
                  ],
                )),
            SizedBox(height: 3.h),
            Text(
              'Optional — reminders start right after save.',
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
            ),
          ],
        ),
        isLast: true,
      ),
    );
  }
  Widget _buildOptionalSection() {
    return _buildCard(
      child: Column(
        children: [
          _buildFormRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Annual Gift Budget'),
                SizedBox(height: 4.h),
                Obx(() => Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: controller.budgetPresets.map((amount) {
                        final label = '\$${amount.toStringAsFixed(0)}';
                        final selected = controller.budget.value == amount.toStringAsFixed(2) ||
                            controller.budget.value == amount.toStringAsFixed(0);
                        return _buildChip(label, selected, () => controller.onBudgetPresetTap(amount));
                      }).toList(),
                    )),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text('\$', style: TextStyle(fontSize: 15.sp, color: const Color(0xFF999999))),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Obx(() => MyTextField(
                            value: controller.budget.value,
                            onChange: controller.onBudgetChanged,
                            hintText: '0.00 (optional)',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            isNumber: true,
                            maxDecimalLength: 2,
                            maxValue: 99999.99,
                            textStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A)),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Obx(() => Text(
                      controller.budgetHint.value.isEmpty
                          ? 'Leave blank for no budget limit'
                          : controller.budgetHint.value,
                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
                    )),
              ],
            ),
            isLast: false,
          ),
          _buildFormRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Notes'),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: controller.noteTemplates
                      .map((t) => _buildChip(t.trim(), false, () => controller.onNoteTemplateTap(t), compact: true))
                      .toList(),
                ),
                SizedBox(height: 6.h),
                Obx(() => MyTextField(
                      value: controller.notes.value,
                      onChange: controller.onNotesChanged,
                      hintText: 'Add notes about this person...',
                      maxLength: 200,
                      maxLines: 3,
                      minLines: 2,
                      textStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A), height: 1.4),
                    )),
                Obx(() => Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${controller.notes.value.length} / 200',
                        style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
                      ),
                    )),
              ],
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }
  Widget _buildSaveAnotherButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() => TextButton(
            onPressed: controller.isSaving.value ? null : () => controller.onSaveTap(addAnother: true),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              backgroundColor: primaryColor.withOpacity(0.08),
              minimumSize: Size(double.infinity, 44.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text('Save & Add Another', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
          )),
    );
  }
  Widget _buildInfoHint() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: _cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: primaryColor, size: 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Birthday + gift budget in one step — more than a calendar.',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFormRow({required Widget child, required bool isLast}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF5EBE6))),
      ),
      child: child,
    );
  }
  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF999999),
            letterSpacing: 0.5,
          ),
        ),
        if (required) Text(' *', style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C))),
      ],
    );
  }
  Widget _buildChip(String label, bool selected, VoidCallback onTap, {bool compact = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12.w : 14.w,
          vertical: compact ? 6.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: selected ? primaryColor : const Color(0xFFF5EBE6),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 12.sp : 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}
