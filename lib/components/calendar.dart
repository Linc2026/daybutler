import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_theme.dart';
enum EventType { birthday, anniversary, custom }
class CalendarView extends StatelessWidget {
  final String monthTitle;
  final int daysInMonth;
  final int firstWeekdayOfMonth;
  final Map<int, List<EventType>> markedDates;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final Function(int day) isToday;
  final int? selectedDay;
  final Function(int day)? onDaySelected;
  final Color primaryColor;
  final Map<int, int> prepBadges;
  final Set<int> conflictDays;
  const CalendarView({
    super.key,
    required this.monthTitle,
    required this.daysInMonth,
    required this.firstWeekdayOfMonth,
    required this.markedDates,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.isToday,
    required this.primaryColor,
    this.selectedDay,
    this.onDaySelected,
    this.prepBadges = const {},
    this.conflictDays = const {},
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekdayLabels(),
        SizedBox(height: 6.h),
        _buildGrid(),
      ],
    );
  }
  Widget _buildWeekdayLabels() {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  Widget _buildGrid() {
    final totalCells = ((daysInMonth + firstWeekdayOfMonth) / 7).ceil() * 7;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.82,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final day = index - firstWeekdayOfMonth + 1;
        if (day <= 0 || day > daysInMonth) return const SizedBox.shrink();
        final events = markedDates[day] ?? [];
        return _buildDayCell(
          day: day,
          events: events,
          isCurrent: isToday(day),
          isSelected: selectedDay == day,
          prepCount: prepBadges[day] ?? 0,
          isConflict: conflictDays.contains(day),
        );
      },
    );
  }
  Widget _buildDayCell({
    required int day,
    required List<EventType> events,
    required bool isCurrent,
    required bool isSelected,
    required int prepCount,
    required bool isConflict,
  }) {
    Color? bgCircleColor;
    Color textColor = AppColors.text;
    bool hasBorder = false;
    if (isCurrent && isSelected) {
      bgCircleColor = primaryColor;
      textColor = AppColors.textOnPrimary;
    } else if (isCurrent) {
      hasBorder = true;
      textColor = primaryColor;
    } else if (isSelected) {
      bgCircleColor = AppColors.text;
      textColor = AppColors.textOnPrimary;
    }
    return GestureDetector(
      onTap: () => onDaySelected?.call(day),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 38.w,
            height: 38.w,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: bgCircleColor,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (bgCircleColor ?? primaryColor)
                                  .withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                    border: hasBorder
                        ? Border.all(color: primaryColor, width: 2)
                        : isConflict && !isSelected && !isCurrent
                            ? Border.all(color: AppColors.warning, width: 1.5)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.sp,
                        fontWeight: (isCurrent ||
                                isSelected ||
                                events.isNotEmpty)
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (prepCount > 0)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        prepCount > 9 ? '9+' : '$prepCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                if (isConflict)
                  Positioned(
                    left: -1,
                    top: -1,
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 11.sp,
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          _buildDots(events),
        ],
      ),
    );
  }
  Widget _buildDots(List<EventType> events) {
    if (events.isEmpty) return SizedBox(height: 8.h);
    final uniqueTypes = events.toSet().toList();
    const maxDots = 3;
    if (uniqueTypes.length <= maxDots) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            uniqueTypes.map((type) => _buildDot(_dotColor(type))).toList(),
      );
    }
    final shown = uniqueTypes.take(2).toList();
    final extra = uniqueTypes.length - 2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...shown.map((type) => _buildDot(_dotColor(type))),
        SizedBox(width: 2.w),
        Text(
          '+$extra',
          style: TextStyle(
            fontSize: 8.sp,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  Widget _buildDot(Color color) {
    return Container(
      width: 5.5.w,
      height: 5.5.w,
      margin: EdgeInsets.symmetric(horizontal: 1.5.w),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
  Color _dotColor(EventType type) {
    switch (type) {
      case EventType.birthday:
        return const Color(0xFFFF69B4);
      case EventType.anniversary:
        return const Color(0xFF9B59B6);
      case EventType.custom:
        return const Color(0xFFF39C12);
    }
  }
}
