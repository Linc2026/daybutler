import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../components/text_field.dart';
import '../../main.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
import 'day_butler_add_flower_logic.dart';
class DayButlerAddFlowerView extends GetView<DayButlerAddFlowerLogic> {
  const DayButlerAddFlowerView({super.key});
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
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 14.sp, color: primaryColor),
          ),
        ),
        leadingWidth: 72.w,
        title: Text(
          controller.pageTitle,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.isSaving.value ? null : controller.onSaveTap,
              child: controller.isSaving.value
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        child: Column(
          children: [
            _buildHero(),
            _buildWhoSection(),
            SizedBox(height: 12.h),
            _buildFlowersSection(),
            SizedBox(height: 12.h),
            _buildWhenSection(context),
            SizedBox(height: 12.h),
            _buildNotesSection(),
            SizedBox(height: 16.h),
            _buildInfoHint(),
          ],
        ),
      ),
    );
  }
  Widget _buildHero() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0EC),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text('🌹', style: TextStyle(fontSize: 24.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isEditMode ? 'Update flower log' : 'Log a flower gift',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Keep a soft trail of what you sent — and when.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF999999),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildWhoSection() {
    return _buildCard(
      child: _buildFormRow(
        isLast: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('For', required: true),
            SizedBox(height: 4.h),
            Obx(() {
              final people =
                  controller.allPeople.where((p) => p.id != null).toList();
              final selectedId = controller.selectedPersonId.value;
              final value =
                  people.any((p) => p.id == selectedId) ? selectedId : null;
              return _softDropdown<int?>(
                icon: Icons.person_outline_rounded,
                value: value,
                hint: 'Select person',
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Select person',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  ...people.map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                ],
                onChanged: controller.onPersonSelected,
              );
            }),
            Obx(
              () => controller.personError.value
                  ? Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'Required',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFFE74C3C),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFlowersSection() {
    return _buildCard(
      child: _buildFormRow(
        isLast: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Flowers', required: true),
            SizedBox(height: 4.h),
            Obx(
              () => Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: controller.quickFlowers
                    .where((q) => q != 'Custom...')
                    .map(
                      (q) => _buildChip(
                        q,
                        controller.flowers.value == q,
                        () => controller.onQuickFlowerTap(q),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 6.h),
            Obx(
              () => MyTextField(
                value: controller.flowers.value,
                onChange: controller.onFlowersChanged,
                hintText: 'e.g. 12 Red Roses',
                maxLength: 80,
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Obx(
              () => controller.flowersError.value
                  ? Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        'Required',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFFE74C3C),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(() {
              final tip = controller.duplicateWarning.value;
              if (tip.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E8),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14.sp,
                        color: const Color(0xFFC97E45),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFFC97E45),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _buildWhenSection(BuildContext context) {
    return _buildCard(
      child: Column(
        children: [
          _buildFormRow(
            isLast: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Date'),
                SizedBox(height: 4.h),
                Obx(() {
                  final d = controller.selectedDate.value;
                  final label = formatDateDisplay(getDateString(d));
                  return GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: d,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) controller.onDateSelected(picked);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16.sp,
                            color: primaryColor,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16.sp,
                            color: const Color(0xFFBBBBBB),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 3.h),
                Text(
                  'When the flowers were given or delivered.',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          _buildFormRow(
            isLast: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Occasion'),
                SizedBox(height: 4.h),
                Obx(() {
                  final occasions =
                      controller.occasions.where((sd) => sd.id != null).toList();
                  final selectedId = controller.selectedOccasionId.value;
                  final value = occasions.any((sd) => sd.id == selectedId)
                      ? selectedId
                      : null;
                  final enabled = controller.selectedPersonId.value != null;
                  return Opacity(
                    opacity: enabled ? 1 : 0.55,
                    child: _softDropdown<int?>(
                      icon: Icons.event_outlined,
                      value: value,
                      hint: enabled ? 'None' : 'Select a person first',
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'None',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        ...occasions.map(
                          (sd) => DropdownMenuItem(
                            value: sd.id,
                            child: Text(
                              controller.occasionLabel(sd),
                              style: TextStyle(fontSize: 14.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: enabled ? controller.onOccasionSelected : null,
                    ),
                  );
                }),
                SizedBox(height: 8.h),
                _buildFieldLabel('Occasion note'),
                SizedBox(height: 2.h),
                Obx(
                  () => MyTextField(
                    value: controller.occasionNote.value,
                    onChange: controller.onOccasionNoteChanged,
                    hintText: 'e.g. Anniversary surprise',
                    maxLength: 60,
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNotesSection() {
    return _buildCard(
      child: _buildFormRow(
        isLast: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Notes'),
            SizedBox(height: 2.h),
            Obx(
              () => MyTextField(
                value: controller.notes.value,
                onChange: controller.onNotesChanged,
                hintText: 'Color, florist, reaction…',
                maxLines: 3,
                minLines: 2,
                maxLength: 200,
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Optional — helpful for next time.',
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
            ),
          ],
        ),
      ),
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
              'Logging flowers helps you avoid repeats and never miss a romantic moment.',
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF666666),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _softDropdown<T>({
    required IconData icon,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: primaryColor),
          SizedBox(width: 6.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                borderRadius: BorderRadius.circular(12.r),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: const Color(0xFFBBBBBB),
                ),
                hint: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                ),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
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
  Widget _buildFormRow({required Widget child, required bool isLast}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF5EBE6))),
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
        if (required)
          Text(
            ' *',
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C)),
          ),
      ],
    );
  }
  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withValues(alpha: 0.12) : const Color(0xFFF5EBE6),
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: selected ? primaryColor : const Color(0x00000000),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? primaryColor : const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}
