import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../components/text_field.dart';
import '../../main.dart';
import 'day_butler_add_gift_logic.dart';
class DayButlerAddGiftView extends GetView<DayButlerAddGiftLogic> {
  const DayButlerAddGiftView({super.key});
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
            _buildBasicSection(),
            SizedBox(height: 12.h),
            _buildDetailsSection(),
            SizedBox(height: 12.h),
            _buildOptionalSection(),
            Obx(() => controller.showReaction
                ? Column(children: [SizedBox(height: 12.h), _buildReactionSection()])
                : const SizedBox.shrink()),
            SizedBox(height: 12.h),
            _buildHistorySection(),
            SizedBox(height: 16.h),
            _buildInfoHint(),
          ],
        ),
      ),
    );
  }
  Widget _buildBasicSection() {
    return _buildCard(
      child: Column(children: [
        _buildFormRow(
          isLast: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel('For', required: true),
            SizedBox(height: 4.h),
            Obx(() {
              final people = controller.allPeople.where((p) => p.id != null).toList();
              final selectedId = controller.selectedPersonId.value;
              final value = people.any((p) => p.id == selectedId) ? selectedId : null;
              return _softDropdown<int?>(
                icon: Icons.person_outline_rounded,
                value: value,
                hint: 'Select person',
                items: [
                  DropdownMenuItem(value: null, child: Text('Select person', style: TextStyle(fontSize: 14.sp))),
                  ...people.map((p) => DropdownMenuItem(
                        value: p.id,
                        child: Text(p.name, style: TextStyle(fontSize: 14.sp)),
                      )),
                ],
                onChanged: controller.onPersonSelected,
              );
            }),
            Obx(() => controller.personError.value
                ? Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text('Required', style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C))),
                  )
                : const SizedBox.shrink()),
          ]),
        ),
        _buildFormRow(
          isLast: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel('Gift Name', required: true),
            SizedBox(height: 2.h),
            Obx(() => MyTextField(
                  value: controller.giftName.value,
                  onChange: controller.onNameChanged,
                  hintText: 'e.g. Leather Journal',
                  maxLength: 100,
                  textStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A)),
                )),
            Obx(() => controller.nameError.value
                ? Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text('Required', style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C))),
                  )
                : const SizedBox.shrink()),
            Obx(() {
              final hint = controller.similarGiftHint;
              if (hint == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(hint, style: TextStyle(fontSize: 10.sp, color: const Color(0xFFC97E45))),
              );
            }),
          ]),
        ),
      ]),
    );
  }
  Widget _buildDetailsSection() {
    return _buildCard(
      child: Column(children: [
        _buildFormRow(
          isLast: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel('Price'),
            SizedBox(height: 4.h),
            Row(children: [
              Text('\$', style: TextStyle(fontSize: 15.sp, color: const Color(0xFF999999))),
              SizedBox(width: 6.w),
              Expanded(
                child: Obx(() => MyTextField(
                      value: controller.price.value,
                      onChange: controller.onPriceChanged,
                      hintText: '0.00 (optional)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isNumber: true,
                      maxDecimalLength: 2,
                      maxValue: 99999.99,
                      textStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A)),
                    )),
              ),
            ]),
            Obx(() {
              if (!controller.showBudgetHint) return const SizedBox.shrink();
              final over = controller.isOverBudget;
              return Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  controller.budgetHintText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: over ? const Color(0xFFE74C3C) : const Color(0xFFAAAAAA),
                  ),
                ),
              );
            }),
          ]),
        ),
        _buildFormRow(
          isLast: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel('Status'),
            SizedBox(height: 4.h),
            Obx(() => Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: controller.statusOptions
                      .map((s) => _buildChip(
                            s,
                            controller.status.value == s,
                            () => controller.onStatusSelected(s),
                          ))
                      .toList(),
                )),
          ]),
        ),
        _buildFormRow(
          isLast: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel('Occasion'),
            SizedBox(height: 4.h),
            Obx(() {
              final occasions = controller.occasions.where((sd) => sd.id != null).toList();
              final selectedId = controller.selectedOccasionId.value;
              final value = occasions.any((sd) => sd.id == selectedId) ? selectedId : null;
              return _softDropdown<int?>(
                icon: Icons.event_outlined,
                value: value,
                hint: 'None',
                items: [
                  DropdownMenuItem(value: null, child: Text('None', style: TextStyle(fontSize: 14.sp))),
                  ...occasions.map((sd) => DropdownMenuItem(
                        value: sd.id,
                        child: Text(controller.occasionLabel(sd), style: TextStyle(fontSize: 14.sp)),
                      )),
                ],
                onChanged: controller.onOccasionSelected,
              );
            }),
            Obx(() {
              final hint = controller.occasionSuggestHint;
              if (hint == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(hint, style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA))),
              );
            }),
          ]),
        ),
      ]),
    );
  }
  Widget _buildOptionalSection() {
    return _buildCard(
      child: Column(children: [
        _buildFormRow(
          isLast: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _buildFieldLabel('Link')),
              _buildChip('Paste', false, controller.onPasteLinkTap, compact: true),
              SizedBox(width: 6.w),
              Obx(() => _buildChip(
                    'Open',
                    false,
                    controller.canOpenLink ? controller.onOpenLinkTap : () {},
                    compact: true,
                    enabled: controller.canOpenLink,
                  )),
            ]),
            SizedBox(height: 4.h),
            Obx(() => MyTextField(
                  value: controller.link.value,
                  onChange: controller.onLinkChanged,
                  hintText: 'https://...',
                  textStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A)),
                )),
            Obx(() => controller.linkError.value
                ? Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      'Please enter a valid URL (starting with http:// or https://)',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE74C3C)),
                    ),
                  )
                : const SizedBox.shrink()),
          ]),
        ),
        _buildFormRow(
          isLast: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildFieldLabel('Notes'),
            SizedBox(height: 4.h),
            Obx(() => MyTextField(
                  value: controller.notes.value,
                  onChange: controller.onNotesChanged,
                  hintText: 'Optional notes...',
                  maxLength: 300,
                  maxLines: 3,
                  minLines: 2,
                  textStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A), height: 1.4),
                )),
            Obx(() => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${controller.notes.value.length} / 300',
                    style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
                  ),
                )),
          ]),
        ),
      ]),
    );
  }
  Widget _buildReactionSection() {
    return _buildCard(
      child: _buildFormRow(
        isLast: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildFieldLabel('Reaction'),
          SizedBox(height: 4.h),
          Obx(() => Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: const [
                  ('😍', 'loved'),
                  ('😊', 'liked'),
                  ('😐', 'okay'),
                  ('😕', 'miss'),
                ].map((e) {
                  final selected = controller.reaction.value == e.$2;
                  return _buildChip(
                    '${e.$1} ${e.$2}',
                    selected,
                    () => controller.onReactionSelected(selected ? null : e.$2),
                  );
                }).toList(),
              )),
          SizedBox(height: 3.h),
          Text('Optional — how did they like it?', style: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA))),
        ]),
      ),
    );
  }
  Widget _buildHistorySection() {
    return Obx(() {
      final name = controller.selectedPersonName;
      if (name == null || controller.historicalGifts.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 8.h),
            child: Row(children: [
              Expanded(
                child: Text(
                  'Previously Gifted to $name'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (controller.showTasteInsight)
                Text(controller.tasteInsightText, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF666666))),
            ]),
          ),
          _buildCard(
            child: Column(
              children: controller.displayedHistory.asMap().entries.map((e) {
                final g = e.value;
                final isLast = e.key == controller.displayedHistory.length - 1 && !controller.hasMoreHistory;
                final dateStr = g.giftedDate != null ? _fmtDate(g.giftedDate!) : '';
                return _buildFormRow(
                  isLast: isLast,
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(g.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A1A))),
                        if (dateStr.isNotEmpty)
                          Text(dateStr, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999))),
                      ]),
                    ),
                    if (g.reaction != null)
                      Text(_reactionEmoji(g.reaction!), style: TextStyle(fontSize: 16.sp)),
                  ]),
                );
              }).toList(),
            ),
          ),
          if (controller.hasMoreHistory)
            Padding(
              padding: EdgeInsets.only(left: 20.w, top: 8.h),
              child: GestureDetector(
                onTap: controller.onViewMoreHistoryTap,
                child: Text(
                  'View ${controller.moreHistoryCount} more',
                  style: TextStyle(fontSize: 13.sp, color: primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
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
              'Track ideas to gifted — budget, history, and taste in one place.',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666), height: 1.4),
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
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EBE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(children: [
        Icon(icon, size: 16.sp, color: primaryColor),
        SizedBox(width: 6.w),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              borderRadius: BorderRadius.circular(12.r),
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: const Color(0xFFBBBBBB)),
              hint: Text(hint, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999))),
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1A1A)),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ]),
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
    return Row(children: [
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
    ]);
  }
  Widget _buildChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    bool compact = false,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12.w : 14.w,
          vertical: compact ? 6.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: !enabled
              ? const Color(0xFFF0E6E2)
              : selected
                  ? primaryColor
                  : const Color(0xFFF5EBE6),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 12.sp : 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: !enabled
                ? const Color(0xFFBBBBBB)
                : selected
                    ? Colors.white
                    : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
  String _fmtDate(String ds) {
    try {
      final d = DateTime.parse(ds);
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${m[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return ds;
    }
  }
  String _reactionEmoji(String r) {
    switch (r) {
      case 'loved':
        return '😍';
      case 'liked':
        return '😊';
      case 'okay':
        return '😐';
      default:
        return '😕';
    }
  }
}
