import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/calendar.dart';
import '../../components/gradient_app_bar.dart';
import '../../theme/app_theme.dart';
import 'day_butler_calendar_logic.dart';
import 'day_butler_calendar_widgets.dart';
class DayButlerCalendarView extends GetView<DayButlerCalendarLogic> {
  const DayButlerCalendarView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCalendarSection(),
              CalendarControlPanel(c: controller),
              Expanded(child: _buildEventList()),
            ],
          ),
          CalendarDaySheetOverlay(c: controller),
          CalendarWishCardOverlay(c: controller),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(44.h),
      child: Obx(
        () => GradientAppBar(
          toolbarHeight: 44.h,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 26.sp,
              color: AppColors.text,
            ),
            onPressed: controller.onPreviousMonth,
          ),
          title: Text(
            controller.monthTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.2,
            ),
          ),
          actions: [
            if (controller.showTodayBtn)
              TextButton(
                onPressed: controller.onTodayTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                size: 26.sp,
                color: AppColors.text,
              ),
              onPressed: controller.onNextMonth,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Obx(() {
        controller.typeFilter.value;
        controller.monthEventsObs.length;
        return CalendarView(
          monthTitle: controller.monthTitle,
          daysInMonth: controller.daysInMonth,
          firstWeekdayOfMonth: controller.firstWeekdayOfMonth,
          markedDates: controller.markedDates,
          onPreviousMonth: controller.onPreviousMonth,
          onNextMonth: controller.onNextMonth,
          isToday: controller.isToday,
          selectedDay: controller.selectedDay.value,
          onDaySelected: controller.onDaySelected,
          primaryColor: AppColors.primary,
          prepBadges: controller.prepBadges,
          conflictDays: controller.conflictDays,
        );
      }),
    );
  }
  Widget _buildEventList() {
    return Obx(() {
      controller.typeFilter.value;
      controller.monthEventsObs.length;
      final selected = controller.selectedDay.value;
      final grouped = controller.listGroupedEvents;
      final days = controller.listSortedDays;
      final key =
          '${controller.displayYear.value}-${controller.displayMonth.value}-${controller.typeFilter.value.name}-$selected';
      if (days.isEmpty) return _buildEmptyState();
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: ListView.builder(
          key: ValueKey(key),
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 24.h),
          itemCount: days.length + (selected != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (selected != null && index == 0) {
              return _buildDayFilterBanner();
            }
            final dayIndex = selected != null ? index - 1 : index;
            final day = days[dayIndex];
            final events = grouped[day]!;
            return _buildDayGroup(day, events);
          },
        ),
      );
    });
  }
  Widget _buildDayFilterBanner() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Events on ${controller.selectedDayLabel}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSub,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.onShowAllMonthTap,
            child: Text(
              'Show month',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDayGroup(int day, List<CalendarEventItem> events) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateGroupHeader(day),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, indent: 16.w, color: AppColors.divider),
                  _buildEventItem(events[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    final filter = controller.typeFilter.value;
    final isTypeFiltered = filter != CalendarTypeFilter.all;
    final isDayFiltered = controller.isDayListFiltered;
    final month = controller.monthTitle.split(' ').first;
    final filterLabel = switch (filter) {
      CalendarTypeFilter.birthday => 'birthday',
      CalendarTypeFilter.anniversary => 'anniversary',
      CalendarTypeFilter.custom => 'custom',
      CalendarTypeFilter.all => '',
    };
    final String title;
    final String subtitle;
    if (isDayFiltered) {
      title = 'No events on ${controller.selectedDayLabel}';
      subtitle = isTypeFiltered
          ? 'Try another filter, or show the full month.'
          : 'Pick another day, or show the full month.';
    } else if (isTypeFiltered) {
      title = 'No $filterLabel events in $month';
      subtitle = 'Try another filter or show all events.';
    } else {
      title = 'Quiet $month';
      subtitle = 'Enjoy the quiet month — or add someone special.';
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - 24.h).clamp(0.0, double.infinity)
            : 0.0;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 28.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (isDayFiltered)
                    TextButton(
                      onPressed: controller.onShowAllMonthTap,
                      child: Text(
                        'Show month',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (!isTypeFiltered)
                    ElevatedButton.icon(
                      onPressed: controller.onAddDateNudgeTap,
                      icon: Icon(Icons.add_rounded, size: 18.sp),
                      label: const Text('Add important date'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () =>
                          controller.onTypeFilterTap(CalendarTypeFilter.all),
                      child: Text(
                        'Show all events',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildDateGroupHeader(int day) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final date = DateTime(
      controller.displayYear.value,
      controller.displayMonth.value,
      day,
    );
    final isToday = controller.isToday(day);
    final isConflict = controller.conflictDays.contains(day);
    final monthAbbr = months[controller.displayMonth.value - 1];
    final weekdayName = weekdays[date.weekday % 7];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          if (isToday)
            Container(
              margin: EdgeInsets.only(right: 6.w),
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: isToday ? 'Today' : '$monthAbbr $day',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isToday ? AppColors.primary : AppColors.textSub,
                  ),
                ),
                TextSpan(
                  text: ' · $weekdayName',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isConflict) ...[
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 11.sp,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Tight',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildEventItem(CalendarEventItem item) {
    final meta = item.eventMeta.isEmpty
        ? item.eventType
        : '${item.eventType} · ${item.eventMeta}';
    final typeColor = calendarTypeColor(item.type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.onPersonTap(item.personId),
        child: Opacity(
          opacity: item.isPast ? 0.55 : 1.0,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 3.5.w, color: typeColor),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 11.h,
                    ),
                    child: Row(
                      children: [
                        calendarAvatar(
                          item.personName,
                          item.avatarLetter,
                          item.avatarColor,
                          38.w,
                          item.avatarPath,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.personName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                meta,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              calendarStatusPill(item),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Material(
                          color: AppColors.primaryLight,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => controller.onSendWishTap(item),
                            child: SizedBox(
                              width: 36.w,
                              height: 36.w,
                              child: Icon(
                                Icons.send_rounded,
                                color: AppColors.primary,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
