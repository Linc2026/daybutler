import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/gradient_app_bar.dart';
import '../../components/text_field.dart';
import '../../main.dart';
import 'day_butler_add_date_logic.dart';
class DayButlerAddDateView extends GetView<DayButlerAddDateLogic> {
  const DayButlerAddDateView({super.key});
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
                onPressed: controller.isSaving.value ? null : controller.onSaveTap,
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
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        child: Column(
          children: [
            _buildDateInfoSection(context),
            Obx(() => controller.appliedFromLast.value || controller.relationshipHint.value.isNotEmpty
                ? Padding(padding: EdgeInsets.only(top: 12.h), child: _buildSmartHintBanner())
                : const SizedBox.shrink()),
            SizedBox(height: 12.h),
            _buildPresetSection(),
            SizedBox(height: 12.h),
            _buildEventReminderSection(context),
            SizedBox(height: 12.h),
            _buildCakeReminderSection(context),
            Obx(() => controller.showFlowerReminder
                ? Padding(padding: EdgeInsets.only(top: 12.h), child: _buildFlowerReminderSection(context))
                : const SizedBox.shrink()),
            SizedBox(height: 12.h),
            _buildTimelineSection(),
            Obx(() => controller.showNotificationWarning.value
                ? Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: GestureDetector(onTap: controller.onOpenSettings, child: _buildNotificationWarning()),
                  )
                : const SizedBox.shrink()),
            SizedBox(height: 16.h),
            _buildInfoHint(),
          ],
        ),
      ),
    );
  }
  Widget _buildDateInfoSection(BuildContext context) {
    return _buildCard(
      child: Column(
        children: [
          _buildFormRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Type'),
                SizedBox(height: 4.h),
                Obx(() => Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: controller.types.map((type) {
                        final label = type == 'Birthday'
                            ? '🎂 Birthday'
                            : type == 'Anniversary'
                                ? '💑 Anniversary'
                                : '⭐ Custom';
                        return _buildChip(
                          label,
                          controller.selectedType.value == type,
                          () => controller.onTypeSelect(type),
                        );
                      }).toList(),
                    )),
              ],
            ),
            isLast: false,
          ),
          Obx(() => controller.showCustomName
              ? _buildFormRow(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Custom Name', required: true),
                      SizedBox(height: 2.h),
                      MyTextField(
                        value: controller.customName.value,
                        onChange: controller.onCustomNameChanged,
                        hintText: 'e.g. Graduation Day',
                        maxLength: 30,
                        textStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A)),
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: controller.customNameTags
                            .map((tag) => _buildChip(
                                  tag,
                                  controller.customName.value == tag,
                                  () => controller.onCustomNameTagTap(tag),
                                  compact: true,
                                ))
                            .toList(),
                      ),
                      if (controller.customNameError.value)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text('Required', style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C))),
                        ),
                    ],
                  ),
                  isLast: false,
                )
              : const SizedBox.shrink()),
          Obx(() => _buildFormRow(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Date'),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () async {
                        final maxD = controller.maxDate;
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate.value.isAfter(maxD)
                              ? maxD
                              : controller.selectedDate.value,
                          firstDate: DateTime(1900),
                          lastDate: maxD,
                        );
                        if (picked != null) controller.onDateSelected(picked);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EBE6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16.sp, color: primaryColor),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                controller.formattedDate,
                                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A)),
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 16.sp, color: const Color(0xFFBBBBBB)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.schedule_rounded, size: 13.sp, color: primaryColor),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: controller.countdownLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    height: 1.3,
                                  ),
                                ),
                                if (controller.milestoneLabel != null)
                                  TextSpan(
                                    text: '  ·  ${controller.milestoneLabel}',
                                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999), height: 1.3),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.selectedType.value == 'Custom'
                          ? 'Custom events can be any date'
                          : 'Only past dates or today are allowed',
                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
                    ),
                  ],
                ),
                isLast: !controller.showRepeatYearly,
              )),
          Obx(() => controller.showRepeatYearly
              ? _buildFormRow(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Repeat Yearly',
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                            SizedBox(height: 2.h),
                            Text('Remind every year on this date',
                                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999))),
                          ],
                        ),
                      ),
                      _buildToggle(controller.repeatYearly.value, controller.onRepeatYearlyToggle),
                    ],
                  ),
                  isLast: true,
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
  Widget _buildSmartHintBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: _cardShadow,
      ),
      child: Obx(() {
        if (controller.appliedFromLast.value) {
          return Row(
            children: [
              Icon(Icons.history_rounded, size: 15.sp, color: primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('Applied from last time',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666))),
              ),
              GestureDetector(
                onTap: controller.onUndoLastPrefs,
                child: Text('Undo',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: primaryColor)),
              ),
            ],
          );
        }
        return Row(
          children: [
            Icon(Icons.auto_awesome, size: 15.sp, color: primaryColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(controller.relationshipHint.value,
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666))),
            ),
            if (!controller.relationshipHint.value.startsWith('Applied'))
              GestureDetector(
                onTap: controller.onApplyRelationshipSuggestion,
                child: Text('Apply',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: primaryColor)),
              ),
          ],
        );
      }),
    );
  }
  Widget _buildPresetSection() {
    return _buildCard(
      child: _buildFormRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Quick Setup'),
            SizedBox(height: 4.h),
            Obx(() => Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: controller.presetOptions
                      .map((p) => _buildChip(
                            p,
                            controller.selectedPreset.value == p,
                            () => controller.onPresetSelect(p),
                          ))
                      .toList(),
                )),
            SizedBox(height: 3.h),
            Text(
              'Apply a reminder pack in one tap.',
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
            ),
          ],
        ),
        isLast: true,
      ),
    );
  }
  Widget _buildEventReminderSection(BuildContext context) {
    return _buildCard(
      child: Column(
        children: [
          _buildFormRow(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Event Reminder'),
                SizedBox(height: 4.h),
                Obx(() => Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: controller.eventReminderOptions
                          .map((opt) => _buildChip(
                                opt,
                                controller.isEventReminderSelected(opt),
                                () => controller.toggleEventReminder(opt),
                              ))
                          .toList(),
                    )),
                Obx(() {
                  final preview = controller.eventNotifPreview;
                  if (preview == null) return const SizedBox.shrink();
                  return _buildNotifPreview(preview);
                }),
              ],
            ),
            isLast: false,
          ),
          _buildFormRow(
            child: Row(
              children: [
                Text('Remind me at', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666))),
                const Spacer(),
                Obx(() => GestureDetector(
                      onTap: () => controller.onReminderMainTimeTap(context),
                      child: _buildTimePill(controller.reminderTime.value),
                    )),
              ],
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }
  Widget _buildCakeReminderSection(BuildContext context) {
    return _buildCard(
      child: _buildFormRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🎂 Cake Reminder',
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                          SizedBox(height: 2.h),
                          Text('Remind me to order a cake',
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999))),
                        ],
                      ),
                    ),
                    _buildToggle(controller.cakeReminderEnabled.value, controller.onCakeReminderToggle),
                  ],
                )),
            Obx(() => controller.cakeReminderEnabled.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubSection(
                        chips: controller.cakeReminderOptions,
                        selectedChip: controller.cakeReminderDays.value,
                        onChipSelect: controller.onCakeDaysSelect,
                        time: controller.cakeReminderTime.value,
                        onTimeTap: () => controller.onCakeTimeTap(context),
                      ),
                      if (controller.cakeNotifPreview != null) _buildNotifPreview(controller.cakeNotifPreview!),
                      SizedBox(height: 8.h),
                      _buildActionLink('Browse gift ideas', controller.onBrowseGiftsTap),
                    ],
                  )
                : const SizedBox.shrink()),
          ],
        ),
        isLast: true,
      ),
    );
  }
  Widget _buildFlowerReminderSection(BuildContext context) {
    return _buildCard(
      child: _buildFormRow(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🌹 Flower Reminder',
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                          SizedBox(height: 2.h),
                          Text('Remind me to order flowers',
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999))),
                        ],
                      ),
                    ),
                    _buildToggle(controller.flowerReminderEnabled.value, controller.onFlowerReminderToggle),
                  ],
                )),
            Obx(() => controller.flowerReminderEnabled.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubSection(
                        chips: controller.flowerReminderOptions,
                        selectedChip: controller.flowerReminderDays.value,
                        onChipSelect: controller.onFlowerDaysSelect,
                        time: controller.flowerReminderTime.value,
                        onTimeTap: () => controller.onFlowerTimeTap(context),
                      ),
                      if (controller.flowerNotifPreview != null) _buildNotifPreview(controller.flowerNotifPreview!),
                      SizedBox(height: 8.h),
                      _buildActionLink('Log flowers', controller.onOrderFlowersTap),
                    ],
                  )
                : const SizedBox.shrink()),
          ],
        ),
        isLast: true,
      ),
    );
  }
  Widget _buildTimelineSection() {
    return Obx(() {
      final items = controller.timelineItems;
      controller.selectedReminderDays.length;
      controller.reminderTime.value;
      controller.cakeReminderEnabled.value;
      controller.cakeReminderDays.value;
      controller.cakeReminderTime.value;
      controller.flowerReminderEnabled.value;
      controller.flowerReminderDays.value;
      controller.flowerReminderTime.value;
      controller.selectedDate.value;
      controller.selectedType.value;
      controller.repeatYearly.value;
      return _buildCard(
        child: _buildFormRow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Upcoming Notifications'),
              SizedBox(height: 6.h),
              if (items.isEmpty)
                Text('No upcoming notification',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF999999)))
              else
                ...items.asMap().entries.map((e) {
                  final last = e.key == items.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: last ? 0 : 6.h),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 15.sp, color: primaryColor),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            controller.formatTimelineItem(e.value),
                            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
          isLast: true,
        ),
      );
    });
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
              'Event, cake & flower reminders — never miss a special day.',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildActionLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        '$label →',
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: primaryColor),
      ),
    );
  }
  Widget _buildNotifPreview(String text) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sms_outlined, size: 13.sp, color: const Color(0xFF999999)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666), height: 1.35)),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationWarning() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: _cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: const Color(0xFFC97E45), size: 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Notifications are off. Tap here to open Settings and enable reminders.',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF8A5000), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSubSection({
    required List<String> chips,
    required String selectedChip,
    required Function(String) onChipSelect,
    required String time,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REMIND ME',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF999999),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: chips
                .map((chip) => _buildChip(chip, selectedChip == chip, () => onChipSelect(chip), compact: true))
                .toList(),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text('At', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666))),
              const Spacer(),
              GestureDetector(onTap: onTimeTap, child: _buildTimePill(time, small: true)),
            ],
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
  Widget _buildTimePill(String time, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 12.w : 14.w, vertical: small ? 6.h : 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: small ? 13.sp : 14.sp,
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  Widget _buildToggle(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44.w,
        height: 26.h,
        decoration: BoxDecoration(
          color: value ? primaryColor : const Color(0xFFE0D6D2),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.all(2.5.w),
            width: 21.w,
            height: 21.w,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
