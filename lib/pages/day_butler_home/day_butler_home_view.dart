import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import 'day_butler_home_logic.dart';
import 'day_butler_home_widgets.dart';
class DayButlerHomeView extends GetView<DayButlerHomeLogic> {
  const DayButlerHomeView({super.key});
  static const _typeColors = {
    'Birthday': AppColors.primary,
    'Anniversary': Color(0xFF9B59B6),
  };
  static Color _typeColor(String type) => _typeColors[type] ?? const Color(0xFFF39C12);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  if (controller.todayBirthdays.isNotEmpty) ...[
                    _buildTodayBanner(),
                    HomeTodayActionStrip(c: controller),
                  ] else
                    HomeQuietDayNudge(c: controller),
                  HomeCareRadar(c: controller),
                  _buildPeopleEntry(),
                  _buildUpcomingSection(),
                ],
              ),
            ),
            HomeWishCardOverlay(c: controller),
            HomePrepSheet(c: controller),
          ],
        ),
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 58.h,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD4436C), AppColors.primary, Color(0xFFEF8DAF)],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33D4436C),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
      ),
      title: Obx(() {
        final subtitle = controller.todayBannerSubtitle;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎂', style: TextStyle(fontSize: 15.sp)),
                SizedBox(width: 5.w),
                Text(
                  'Birthday Butler',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
          ],
        );
      }),
      actions: [
        GestureDetector(
          onTap: controller.onAddPersonTap,
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
          ),
        ),
      ],
    );
  }
  Widget _buildTodayBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE8EF), Color(0xFFFFF4EC)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🎂 Today\'s Birthdays',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${controller.todayBirthdays.length}',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.todayBirthdays.map((item) {
                return GestureDetector(
                  onTap: () => controller.onBirthdayAvatarTap(item),
                  child: Container(
                    margin: EdgeInsets.only(right: 16.w),
                    child: Column(
                      children: [
                        homeAvatar(item.name, item.avatarLetter, item.avatarColor, 44.w, item.avatarPath, wished: item.wishedToday),
                        SizedBox(height: 4.h),
                        SizedBox(
                          width: 50.w,
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: AppColors.textSub),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            controller.todayBannerSubtitle,
            style: TextStyle(fontSize: 12.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  Widget _buildPeopleEntry() {
    final count = controller.peopleCount.value;
    return GestureDetector(
      onTap: controller.onPeopleTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.people_rounded, color: AppColors.primary, size: 17.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count == 0 ? 'No people yet' : '$count people',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                  Text('Manage contacts', style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 18.sp),
          ],
        ),
      ),
    );
  }
  Widget _buildUpcomingSection() {
    final hasAny = controller.upcomingItems.isNotEmpty;
    final filtered = controller.filteredUpcoming;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUpcomingHeader(hasAny),
        if (!hasAny)
          _buildEmptyState()
        else if (filtered.isEmpty)
          _buildFilterEmpty()
        else
          _buildUpcomingList(filtered),
        SizedBox(height: 24.h),
      ],
    );
  }
  Widget _buildUpcomingHeader(bool hasAny) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 12.w, 8.h),
      child: Row(
        children: [
          Text('Upcoming', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
          const Spacer(),
          if (hasAny) ..._horizonPills(),
        ],
      ),
    );
  }
  List<Widget> _horizonPills() {
    final options = [(HomeHorizon.all, 'All'), (HomeHorizon.d7, '7d'), (HomeHorizon.d30, '30d'), (HomeHorizon.d90, '90d')];
    return options.map((o) {
      final selected = controller.horizon.value == o.$1;
      return GestureDetector(
        onTap: () => controller.onHorizonTap(o.$1),
        child: Container(
          margin: EdgeInsets.only(left: 5.w),
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            o.$2,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textTertiary),
          ),
        ),
      );
    }).toList();
  }
  Widget _buildUpcomingList(List<UpcomingItem> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: items.asMap().entries.map((e) {
            return _buildUpcomingRow(e.value, e.key == items.length - 1);
          }).toList(),
        ),
      ),
    );
  }
  Widget _buildUpcomingRow(UpcomingItem item, bool isLast) {
    final typeCol = _typeColor(item.type);
    return GestureDetector(
      onTap: () => controller.onUpcomingItemTap(item.personId),
      child: Container(
        padding: EdgeInsets.fromLTRB(11.w, 10.h, 14.w, 10.h),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: typeCol, width: 3),
            bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          children: [
            homeAvatar(item.personName, item.avatarLetter, item.avatarColor, 38.w, item.avatarPath),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(item.date, style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary)),
                ],
              ),
            ),
            if (item.showPrep) _buildPrepBtn(item),
            _countdownBadge(item),
          ],
        ),
      ),
    );
  }
  Widget _buildPrepBtn(UpcomingItem item) {
    return GestureDetector(
      onTap: () => controller.openPrepSheet(item),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: item.prepAlert ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.checklist_rounded, size: 15.sp, color: item.prepAlert ? AppColors.primary : AppColors.textTertiary),
            if (item.prepAlert)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _countdownBadge(UpcomingItem item) {
    final Color bg;
    final Color fg;
    if (item.isToday) {
      bg = AppColors.primary.withValues(alpha: 0.1);
      fg = AppColors.primary;
    } else if (item.countdown == 'Tomorrow') {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
    } else {
      bg = const Color(0xFFF5F5F5);
      fg = AppColors.textSub;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Text(item.countdown, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: fg)),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_today_rounded, size: 32.sp, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            SizedBox(height: 16.h),
            Text('No upcoming dates', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
            SizedBox(height: 4.h),
            Text('Add someone to get started', style: TextStyle(fontSize: 13.sp, color: AppColors.textDisabled)),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: controller.onAddPersonTap,
              icon: Icon(Icons.person_add_rounded, size: 16.sp),
              label: const Text('Add Person'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: Center(
        child: Text('No dates in this range', style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary)),
      ),
    );
  }
}
