import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../components/text_field.dart';
import '../../db_day_butler/db_day_butler_entity.dart';
import '../../theme/app_theme.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_flowers_logic.dart';
import 'day_butler_flowers_widgets.dart';
class DayButlerFlowersView extends GetView<DayButlerFlowersLogic> {
  const DayButlerFlowersView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: GradientAppBar(
        title: Text(
          'Romantic Flowers',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: AppColors.text,
          ),
        ),
        actions: [
          Obx(
            () => controller.currentTab.value == 1
                ? GestureDetector(
                    onTap: controller.onAddRecordTap,
                    child: Container(
                      margin: EdgeInsets.only(right: 14.w),
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              switch (controller.currentTab.value) {
                case 0:
                  return _buildFlowerLanguage();
                case 1:
                  return _buildMyRecords();
                default:
                  return _buildFlorist();
              }
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildTabBar() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            _tabBtn('Flower Language', 0),
            SizedBox(width: 6.w),
            _tabBtn('My Records', 1),
            SizedBox(width: 6.w),
            _tabBtn('Florist', 2),
          ],
        ),
      ),
    );
  }
  Widget _tabBtn(String label, int idx) {
    final active = controller.currentTab.value == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabSwitch(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 7.h),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.bg,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildFlowerLanguage() {
    return Obx(() {
      final upcoming = controller.upcomingFlowers;
      final flowers = controller.filteredFlowers;
      final expandedId = controller.expandedFlowerId.value;
      return Column(
        children: [
          _buildChipBar(
            children: controller.occasionOptions
                .map(
                  (o) => _chip(
                    o,
                    controller.flowerFilter.value == o,
                    () => controller.onFlowerFilterTap(o),
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadData,
              color: AppColors.primary,
              child: flowers.isEmpty && upcoming.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 100.h),
                        _emptyState(
                          'No flowers found',
                          'Try another occasion filter',
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: flowers.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return FlowersUpcomingBanner(
                            items: upcoming,
                            onLog: controller.onUpcomingLogTap,
                          );
                        }
                        final f = flowers[i - 1];
                        return _buildLanguageCard(
                          f,
                          expanded: expandedId == f.id,
                        );
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
  Widget _buildLanguageCard(FlowerLanguageItem f, {required bool expanded}) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () {
          final id = f.id;
          if (id != null) controller.onFlowerCardTap(id);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 10.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(f.emoji, style: TextStyle(fontSize: 22.sp)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          f.shortMeaning,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textDisabled,
                    size: 20.sp,
                  ),
                ],
              ),
              if (expanded) ...[
              SizedBox(height: 8.h),
              Divider(height: 1, color: AppColors.border.withValues(alpha: 0.9)),
              SizedBox(height: 8.h),
              Text(
                f.fullMeaning,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSub,
                  height: 1.4,
                ),
              ),
              if (f.colorVariants?.isNotEmpty == true) ...[
                SizedBox(height: 6.h),
                _infoRow('🎨', f.colorVariants!),
              ],
              if (f.tips?.isNotEmpty == true) ...[
                SizedBox(height: 4.h),
                _infoRow('💡', f.tips!),
              ],
              SizedBox(height: 6.h),
              Wrap(
                spacing: 5.w,
                runSpacing: 4.h,
                children: f.occasionsList.map(_tag).toList(),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 34.h,
                child: OutlinedButton.icon(
                  onPressed: () => controller.onLogFromLanguageTap(f),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Log this flower',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
  Widget _buildMyRecords() {
    return Obx(() {
      final records = controller.filteredRecords;
      final summary = controller.rhythmSummary;
      return Column(
        children: [
          _buildChipBar(
            children: [
              _chip(
                'All',
                controller.filterPersonId.value == null,
                () => controller.onFilterPersonTap(null),
              ),
              ...controller.allPeople.map(
                (p) => _chip(
                  p.name,
                  controller.filterPersonId.value == p.id,
                  () => controller.onFilterPersonTap(p.id),
                ),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadData,
              color: AppColors.primary,
              child: records.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        FlowersRhythmBar(summary: summary),
                        SizedBox(height: 72.h),
                        _emptyState(
                          'No records yet',
                          'Tap + to add your first flower record',
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: records.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return FlowersRhythmBar(summary: summary);
                        }
                        return _buildRecordRow(records[i - 1]);
                      },
                    ),
            ),
          ),
        ],
      );
    });
  }
  Widget _buildRecordRow(FlowerRecord record) {
    final name = controller.personName(record.personId);
    final dateStr = formatDateDisplay(record.date);
    final note = record.occasionNote;
    final notes = record.notes;
    final dup = controller.duplicateHint(record);
    return Slidable(
      key: ValueKey(record.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.62,
        children: [
          SlidableAction(
            onPressed: (_) => controller.onReorderTap(record),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            label: 'Again',
            icon: Icons.replay_rounded,
          ),
          SlidableAction(
            onPressed: (_) => controller.onEditRecordTap(record.id!),
            backgroundColor: const Color(0xFF5B9BD5),
            foregroundColor: Colors.white,
            label: 'Edit',
            icon: Icons.edit_rounded,
          ),
          SlidableAction(
            onPressed: (_) => controller.onDeleteRecord(record.id!),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            label: 'Delete',
            icon: Icons.delete_rounded,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => controller.onEditRecordTap(record.id!),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 10.h),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    controller.flowerEmoji(record.flowers),
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.flowers,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'For $name · $dateStr',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dup != null)
                      Text(
                        dup,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    if (note != null && note.isNotEmpty)
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSub,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (notes != null && notes.isNotEmpty)
                      Text(
                        notes,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFlorist() {
    return Obx(() {
      if (controller.floristEditing.value) return _buildFloristForm();
      final f = controller.florist.value;
      if (f == null) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌺', style: TextStyle(fontSize: 40.sp)),
                SizedBox(height: 12.h),
                Text(
                  'No florist saved yet',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Save your favorite florist\'s details for quick access',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: controller.onAddFloristTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Add Florist',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return SingleChildScrollView(
        child: Column(
          children: [
            FlowersFloristActionBar(
              next: controller.nextFloristAction,
              onCall: controller.onCallTap,
              onLog: controller.onFloristLogTap,
              canCall: f.phone?.isNotEmpty == true,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.shopName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.onEditFloristTap,
                        child: Icon(
                          Icons.edit_rounded,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: controller.onDeleteFlorist,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: const Color(0xFFE74C3C),
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  if (f.phone?.isNotEmpty == true) ...[
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: controller.onCallTap,
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            color: AppColors.primary,
                            size: 15.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            f.phone ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (f.address?.isNotEmpty == true) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: controller.onAddressTap,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 15.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              f.address ?? '',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (f.notes?.isNotEmpty == true) ...[
                    SizedBox(height: 8.h),
                    Text(
                      f.notes ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildFloristForm() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        color: AppColors.surface,
        child: Column(
          children: [
            _floristRow(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('SHOP NAME', required: true),
                  MyTextField(
                    value: controller.floristShopName.value,
                    onChange: (v) {
                      controller.floristShopName.value = v;
                      controller.floristShopNameError.value = false;
                    },
                    hintText: 'Flower shop name',
                    textStyle: TextStyle(fontSize: 14.sp),
                  ),
                  Obx(
                    () => controller.floristShopNameError.value
                        ? Text(
                            'Required',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFFE74C3C),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              isLast: false,
            ),
            _floristRow(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('PHONE'),
                  MyTextField(
                    value: controller.floristPhone.value,
                    onChange: (v) => controller.floristPhone.value = v,
                    hintText: 'Phone number',
                    keyboardType: TextInputType.phone,
                    textStyle: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
              isLast: false,
            ),
            _floristRow(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('ADDRESS'),
                  MyTextField(
                    value: controller.floristAddress.value,
                    onChange: (v) => controller.floristAddress.value = v,
                    hintText: 'Address (optional)',
                    textStyle: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
              isLast: false,
            ),
            _floristRow(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('NOTES'),
                  MyTextField(
                    value: controller.floristNotes.value,
                    onChange: (v) => controller.floristNotes.value = v,
                    hintText: 'e.g. preferred arrangements, budget range...',
                    maxLines: 3,
                    minLines: 2,
                    textStyle: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
              isLast: true,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: OutlinedButton(
                        onPressed: controller.onCancelFloristEdit,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: controller.onSaveFlorist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildChipBar({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 0, 6.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      ),
    );
  }
  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bg,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.9),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSub,
          ),
        ),
      ),
    );
  }
  Widget _infoRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: TextStyle(fontSize: 12.sp)),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSub,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
  Widget _tag(String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
  Widget _floristRow({required Widget child, required bool isLast}) =>
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: child,
      );
  Widget _emptyState(String title, String subtitle) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌹', style: TextStyle(fontSize: 40.sp)),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textDisabled),
            ),
          ],
        ),
      );
  Widget _label(String label, {bool required = false}) => Padding(
        padding: EdgeInsets.only(bottom: 3.h),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.4,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFFE74C3C),
                ),
              ),
          ],
        ),
      );
}
