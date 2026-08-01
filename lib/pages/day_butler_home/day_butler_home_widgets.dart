import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_home_logic.dart';
Widget homeAvatar(
  String name,
  String letter,
  int fallbackColor,
  double size,
  String? avatarPath, {
  bool wished = false,
}) {
  final color = Color(resolveAvatarColor(name, avatarPath));
  final hasPhoto = isAvatarPhotoPath(avatarPath) && File(avatarPath!).existsSync();
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: hasPhoto ? Color(fallbackColor) : color,
          shape: BoxShape.circle,
          image: hasPhoto ? DecorationImage(image: FileImage(File(avatarPath)), fit: BoxFit.cover) : null,
        ),
        child: hasPhoto
            ? null
            : Center(
                child: Text(
                  letter,
                  style: TextStyle(color: Colors.white, fontSize: (size * 0.4).sp, fontWeight: FontWeight.w700),
                ),
              ),
      ),
      if (wished)
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(Icons.check_rounded, size: (size * 0.21).sp, color: Colors.white),
          ),
        ),
    ],
  );
}
class HomeCareRadar extends StatelessWidget {
  final DayButlerHomeLogic c;
  const HomeCareRadar({super.key, required this.c});
  Color _chipBg(int days) {
    if (days == 0) return AppColors.primary.withValues(alpha: 0.14);
    if (days <= 2) return AppColors.warningBg;
    return AppColors.primaryLight;
  }
  Color _chipFg(int days) {
    if (days == 0) return AppColors.primary;
    if (days <= 2) return AppColors.warning;
    return AppColors.primaryDark;
  }
  @override
  Widget build(BuildContext context) {
    final items = c.careRadarItems;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 6.h),
            child: Row(
              children: [
                Text('⚡', style: TextStyle(fontSize: 13.sp)),
                SizedBox(width: 4.w),
                Text('Care Radar', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
                SizedBox(width: 6.w),
                Text('· next 7 days', style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () => c.onCareRadarTap(item),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _chipBg(item.daysUntil),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: _chipFg(item.daysUntil).withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.checklist_rounded, size: 12.sp, color: _chipFg(item.daysUntil)),
                          SizedBox(width: 4.w),
                          Text(
                            item.chipLabel,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _chipFg(item.daysUntil)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
class HomeQuietDayNudge extends StatelessWidget {
  final DayButlerHomeLogic c;
  const HomeQuietDayNudge({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    final next = c.quietDayNext;
    if (next == null) return const SizedBox.shrink();
    final prep = next.incompletePrepCount;
    return GestureDetector(
      onTap: c.onQuietDayTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primaryLight, AppColors.bg],
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.event_rounded, size: 18.sp, color: AppColors.primary),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next up: ${next.personName}',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${next.typeName} · ${next.countdown}${prep > 0 ? '  ·  $prep prep left' : '  ·  All set ✓'}',
                    style: TextStyle(fontSize: 11.sp, color: prep > 0 ? AppColors.warning : AppColors.success),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16.sp, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
class HomeTodayActionStrip extends StatelessWidget {
  final DayButlerHomeLogic c;
  const HomeTodayActionStrip({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    if (!c.showTodayActionStrip) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Row(
        children: [
          _chip('✉️', 'Wish', c.onTodayWishTap, filled: true),
          SizedBox(width: 6.w),
          _chip('🎁', 'Gift', c.onTodayGiftTap),
          SizedBox(width: 6.w),
          _chip('🎂', 'Cake', c.onTodayCakeTap),
        ],
      ),
    );
  }
  Widget _chip(String emoji, String label, VoidCallback onTap, {bool filled = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: filled ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 13.sp)),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class HomePrepSheet extends StatelessWidget {
  final DayButlerHomeLogic c;
  const HomePrepSheet({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = c.prepSheetItem.value;
      if (item == null) return const SizedBox.shrink();
      final done = prepChecklistKeys.where((k) => c.prepSheetMap[k] == true).length;
      final total = prepChecklistKeys.length;
      return GestureDetector(
        onTap: c.closePrepSheet,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.typeName} · ${item.countdown}',
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            SizedBox(height: 1.h),
                            Text(item.personName, style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: done == total ? AppColors.successBg : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$done / $total',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: done == total ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: done / total,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      color: done == total ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ...prepChecklistKeys.map((key) {
                    final checked = c.prepSheetMap[key] == true;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: GestureDetector(
                        onTap: () => c.onTogglePrep(key, !checked),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22.w,
                              height: 22.w,
                              decoration: BoxDecoration(
                                color: checked ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: checked ? AppColors.primary : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: checked
                                  ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                                  : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                prepChecklistLabels[key] ?? key,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  decoration: checked ? TextDecoration.lineThrough : null,
                                  decorationColor: AppColors.textTertiary,
                                  color: checked ? AppColors.textTertiary : AppColors.text,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => c.onPrepActionTap(key),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Go →', style: TextStyle(fontSize: 12.sp, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
class HomeWishCardOverlay extends StatelessWidget {
  final DayButlerHomeLogic c;
  const HomeWishCardOverlay({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final person = c.wishCardPerson.value;
      if (!c.wishCardVisible.value || person == null) return const SizedBox.shrink();
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 40, offset: const Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.wishCounterLabel, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      homeAvatar(person.name, person.avatarLetter, person.avatarColor, 48.w, person.avatarPath, wished: person.wishedToday),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.name, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
                            SizedBox(height: 2.h),
                            Text(
                              person.age != null ? '🎂 Turns ${person.age} today' : '🎂 Birthday',
                              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
                            ),
                            if (person.wishedToday)
                              Padding(
                                padding: EdgeInsets.only(top: 3.h),
                                child: Text('✓ Wished today', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.success)),
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
                        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                      ),
                      child: Text(
                        '"${c.currentWishContent}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, height: 1.55, fontStyle: FontStyle.italic, color: AppColors.text),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F0F5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 12.sp, height: 1.5, color: AppColors.textSub),
                        children: [
                          const TextSpan(text: 'Preview  ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text)),
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
                                color: i == idx ? AppColors.primary : AppColors.border,
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
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 13.h)),
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
                          child: Text('🎁 Gift', style: TextStyle(fontSize: 13.sp)),
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
                          child: Text('🎂 Cake', style: TextStyle(fontSize: 13.sp)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: c.onViewProfileTap,
                    child: Text('View Profile →', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
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
        decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
        child: Icon(icon, size: 18.sp, color: AppColors.textSub),
      ),
    );
  }
}
