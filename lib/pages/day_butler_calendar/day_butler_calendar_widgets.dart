import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/calendar.dart';
import '../../theme/app_theme.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_calendar_logic.dart';
Color calendarTypeColor(EventType type) {
  switch (type) {
    case EventType.birthday:
      return const Color(0xFFFF69B4);
    case EventType.anniversary:
      return const Color(0xFF9B59B6);
    case EventType.custom:
      return const Color(0xFFF39C12);
  }
}
Widget calendarAvatar(
  String name,
  String letter,
  int fallbackColor,
  double size,
  String? avatarPath,
) {
  final color = Color(resolveAvatarColor(name, avatarPath));
  final hasPhoto =
      isAvatarPhotoPath(avatarPath) && File(avatarPath!).existsSync();
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: hasPhoto ? Color(fallbackColor) : color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: (hasPhoto ? Color(fallbackColor) : color).withValues(alpha: 0.22),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      image: hasPhoto
          ? DecorationImage(
              image: FileImage(File(avatarPath)),
              fit: BoxFit.cover,
            )
          : null,
    ),
    child: hasPhoto
        ? null
        : Center(
            child: Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: (size * 0.42).sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
  );
}
Widget calendarStatusPill(CalendarEventItem item) {
  final wished = item.wishedToday;
  final ready = item.prepReady;
  final label = wished
      ? '✓ Wished'
      : ready
          ? 'Ready'
          : item.prepProgressLabel;
  final Color fg = wished || ready ? AppColors.success : AppColors.warning;
  final Color bg = wished || ready ? AppColors.successBg : AppColors.warningBg;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(100.r),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}
class CalendarControlPanel extends StatelessWidget {
  final DayButlerCalendarLogic c;
  const CalendarControlPanel({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      c.monthEventsObs.length;
      c.typeFilter.value;
      c.selectedDay.value;
      final level = c.busyLevel;
      final showFocus = c.showFocusStrip;
      final focus = c.focusEvents;
      final Color tone;
      switch (level) {
        case MonthBusyLevel.quiet:
          tone = AppColors.success;
        case MonthBusyLevel.steady:
          tone = AppColors.warning;
        case MonthBusyLevel.busy:
          tone = AppColors.primary;
      }
      return Container(
        margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration:
                            BoxDecoration(color: tone, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        c.busyLevelLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: tone,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    c.busyScoreText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSub,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', CalendarTypeFilter.all, null),
                  SizedBox(width: 6.w),
                  _filterChip(
                    'Birthday',
                    CalendarTypeFilter.birthday,
                    const Color(0xFFFF69B4),
                  ),
                  SizedBox(width: 6.w),
                  _filterChip(
                    'Anniversary',
                    CalendarTypeFilter.anniversary,
                    const Color(0xFF9B59B6),
                  ),
                  SizedBox(width: 6.w),
                  _filterChip(
                    'Custom',
                    CalendarTypeFilter.custom,
                    const Color(0xFFF39C12),
                  ),
                ],
              ),
            ),
            if (showFocus) ...[
              SizedBox(height: 12.h),
              Text(
                'Next up',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 6.h),
              ...focus.map((e) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: _focusCard(e),
                  )),
            ],
          ],
        ),
      );
    });
  }
  Widget _filterChip(
    String label,
    CalendarTypeFilter value,
    Color? dot,
  ) {
    final on = c.typeFilter.value == value;
    return GestureDetector(
      onTap: () => c.onTypeFilterTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: on ? AppColors.primarySurface : AppColors.bg,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: on ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              SizedBox(width: 5.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: on ? AppColors.primary : AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _focusCard(CalendarEventItem e) {
    final when = c.focusCountdown(e);
    final typeColor = calendarTypeColor(e.type);
    return GestureDetector(
      onTap: () => c.onFocusChipTap(e),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(0, 8.h, 10.w, 8.h),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 3.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(3.r),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            calendarAvatar(
              e.personName,
              e.avatarLetter,
              e.avatarColor,
              28.w,
              e.avatarPath,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.personName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '$when · ${e.eventType}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (e.prepIncomplete > 0)
              calendarStatusPill(e)
            else
              Icon(Icons.chevron_right_rounded,
                  size: 18.sp, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
class CalendarDaySheetOverlay extends StatelessWidget {
  final DayButlerCalendarLogic c;
  const CalendarDaySheetOverlay({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!c.daySheetVisible.value) return const SizedBox.shrink();
      final events = c.daySheetEvents;
      final isToday =
          c.daySheetDay.value != null && c.isToday(c.daySheetDay.value!);
      final tight = c.daySheetIsTight;
      return GestureDetector(
        onTap: c.onCloseDaySheet,
        child: Container(
          color: Colors.black.withValues(alpha: 0.38),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: 0.62.sh),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primarySurface.withValues(alpha: 0.65),
                          AppColors.surface,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24.r)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  c.daySheetTitle,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              if (isToday) ...[
                                SizedBox(width: 8.w),
                                _tag('Today', AppColors.primary,
                                    AppColors.primarySurface),
                              ],
                              if (tight) ...[
                                SizedBox(width: 6.w),
                                _tag('Tight', AppColors.warning,
                                    AppColors.warningBg),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              c.daySheetSubtitle,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (tight)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningBg,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          c.daySheetTightHint,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  Divider(height: 1, color: AppColors.divider),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 30.h),
                      itemCount: events.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (_, i) =>
                          _DaySheetEventRow(c: c, item: events[i]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _tag(String text, Color fg, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
class _DaySheetEventRow extends StatelessWidget {
  final DayButlerCalendarLogic c;
  final CalendarEventItem item;
  const _DaySheetEventRow({required this.c, required this.item});
  @override
  Widget build(BuildContext context) {
    final icon = eventTypeIcon(item.raw.type);
    final sub = item.eventMeta.isEmpty
        ? '$icon ${item.eventType}'
        : '$icon ${item.eventType} · ${item.eventMeta}';
    final typeColor = calendarTypeColor(item.type);
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(width: 3.w, color: typeColor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => c.onPersonTap(item.personId),
                    child: calendarAvatar(
                      item.personName,
                      item.avatarLetter,
                      item.avatarColor,
                      44.w,
                      item.avatarPath,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => c.onPersonTap(item.personId),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.personName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            sub,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          calendarStatusPill(item),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => c.onSendWishTap(item),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded,
                              size: 13.sp, color: Colors.white),
                          SizedBox(width: 6.w),
                          Text(
                            'Wish',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        ],
      ),
    );
  }
}
class CalendarWishCardOverlay extends StatelessWidget {
  final DayButlerCalendarLogic c;
  const CalendarWishCardOverlay({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = c.wishCardEvent.value;
      if (!c.wishCardVisible.value || event == null) {
        return const SizedBox.shrink();
      }
      final total = c.wishCardWishes.length;
      final idx = c.wishCardIndex.value;
      return GestureDetector(
        onTap: c.onWishCardClose,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.wishCounterLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      calendarAvatar(
                        event.personName,
                        event.avatarLetter,
                        event.avatarColor,
                        48.w,
                        event.avatarPath,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.personName,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              c.wishCardSubtitle,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (event.wishedToday)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: calendarStatusPill(event),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onHorizontalDragEnd: (d) {
                      if ((d.primaryVelocity ?? 0) < -80) c.onWishNext();
                      if ((d.primaryVelocity ?? 0) > 80) c.onWishPrev();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14.r),
                        border: const Border(
                          left: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                      child: Text(
                        '"${c.currentWishContent}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.55,
                          fontStyle: FontStyle.italic,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.5,
                          color: AppColors.textSub,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Preview  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          TextSpan(text: c.currentWishPreview),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _navBtn(Icons.chevron_left_rounded, c.onWishPrev),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 5.w,
                          children: List.generate(total, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: i == idx ? 16.w : 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: i == idx
                                    ? AppColors.primary
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _navBtn(Icons.chevron_right_rounded, c.onWishNext),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: c.onWishCopy,
                      icon: Icon(Icons.copy_rounded, size: 16.sp),
                      label: const Text('Copy Card'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: c.onWishCardGiftTap,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Text('🎁 Gift',
                              style: TextStyle(fontSize: 13.sp)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: c.onWishCardCakeTap,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Text('🎂 Cake',
                              style: TextStyle(fontSize: 13.sp)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: c.onViewProfileTap,
                    child: Text(
                      'View Profile →',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.textSub),
      ),
    );
  }
}
