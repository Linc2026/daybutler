import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import 'day_butler_flowers_logic.dart';
class FlowersUpcomingBanner extends StatelessWidget {
  final List<UpcomingFlowerItem> items;
  final void Function(UpcomingFlowerItem) onLog;
  const FlowersUpcomingBanner({
    super.key,
    required this.items,
    required this.onLog,
  });
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.bg,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('🌹', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Upcoming — order flowers',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...items.map(_row),
        ],
      ),
    );
  }
  Widget _row(UpcomingFlowerItem item) {
    final when = item.daysUntil == 0
        ? 'Today'
        : item.daysUntil == 1
            ? 'Tomorrow'
            : 'in ${item.daysUntil}d';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.personName,
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
                  '${item.occasionLabel} · $when'
                  '${item.flowerReminderOn ? ' · reminder on' : ''}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => onLog(item),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                'Log',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class FlowersRhythmBar extends StatelessWidget {
  final FlowerRhythmSummary summary;
  const FlowersRhythmBar({super.key, required this.summary});
  @override
  Widget build(BuildContext context) {
    final lastLabel = summary.daysSinceLast == null
        ? '—'
        : summary.daysSinceLast == 0
            ? 'Today'
            : '${summary.daysSinceLast}d ago';
    final top = summary.topFlower;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.personName != null) ...[
            Text(
              summary.dueSoon
                  ? '${summary.personName} · Due soon'
                  : '${summary.personName} · Rhythm',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: summary.dueSoon
                    ? AppColors.warning
                    : AppColors.textTertiary,
              ),
            ),
            SizedBox(height: 6.h),
          ],
          Row(
            children: [
              _stat('This year', '${summary.yearCount}'),
              _divider(),
              _stat('This month', '${summary.monthCount}'),
              _divider(),
              _stat('Last gift', lastLabel),
            ],
          ),
          if (top != null && top.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              'Most sent: $top',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                height: 1.1,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
  Widget _divider() => Container(
        width: 1,
        height: 24.h,
        color: AppColors.border,
      );
}
class FlowersFloristActionBar extends StatelessWidget {
  final UpcomingFlowerItem? next;
  final VoidCallback onCall;
  final VoidCallback onLog;
  final bool canCall;
  const FlowersFloristActionBar({
    super.key,
    required this.next,
    required this.onCall,
    required this.onLog,
    required this.canCall,
  });
  @override
  Widget build(BuildContext context) {
    if (next == null) return const SizedBox.shrink();
    final when = next!.daysUntil == 0
        ? 'today'
        : next!.daysUntil == 1
            ? 'tomorrow'
            : 'in ${next!.daysUntil} days';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.bg],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEXT ORDER WINDOW',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${next!.personName} · ${next!.occasionLabel} · $when',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              height: 1.25,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (canCall)
                Expanded(
                  child: SizedBox(
                    height: 36.h,
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: Icon(Icons.phone_rounded, size: 15.sp, color: AppColors.primary),
                      label: Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ),
              if (canCall) SizedBox(width: 8.w),
              Expanded(
                child: SizedBox(
                  height: 36.h,
                  child: ElevatedButton.icon(
                    onPressed: onLog,
                    icon: Icon(
                      Icons.local_florist_rounded,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Log flowers',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
