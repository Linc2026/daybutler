import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../day_butler_calendar/day_butler_calendar_view.dart';
import '../day_butler_gifts/day_butler_gifts_binding.dart';
import '../day_butler_gifts/day_butler_gifts_logic.dart';
import '../day_butler_gifts/day_butler_gifts_view.dart';
import '../day_butler_home/day_butler_home_view.dart';
import '../day_butler_settings/day_butler_settings_binding.dart';
import '../day_butler_settings/day_butler_settings_logic.dart';
import '../day_butler_settings/day_butler_settings_view.dart';
import 'day_butler_tab_logic.dart';
class DayButlerTabView extends GetView<DayButlerTabLogic> {
  const DayButlerTabView({super.key});
  static const _tabs = [
    _TabMeta(icon: Icons.house_rounded, iconOutline: Icons.house_outlined, label: 'Home'),
    _TabMeta(icon: Icons.calendar_month_rounded, iconOutline: Icons.calendar_month_outlined, label: 'Calendar'),
    _TabMeta(icon: Icons.card_giftcard_rounded, iconOutline: Icons.card_giftcard_outlined, label: 'Gifts'),
    _TabMeta(icon: Icons.settings_rounded, iconOutline: Icons.settings_outlined, label: 'Settings'),
  ];
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DayButlerGiftsLogic>()) DayButlerGiftsBinding().dependencies();
    if (!Get.isRegistered<DayButlerSettingsLogic>()) DayButlerSettingsBinding().dependencies();
    final pages = const [
      DayButlerHomeView(),
      DayButlerCalendarView(),
      DayButlerGiftsView(),
      DayButlerSettingsView(),
    ];
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: _BottomBar(
            currentIndex: controller.currentIndex.value,
            tabs: _tabs,
            onTap: controller.onTabTap,
          ),
        ));
  }
}
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final List<_TabMeta> tabs;
  final ValueChanged<int> onTap;
  const _BottomBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.85), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 16.h),
          child: SizedBox(
            height: 56.h,
            child: Row(
              children: tabs.asMap().entries.map((e) {
                return _TabItem(
                  meta: e.value,
                  isActive: currentIndex == e.key,
                  onTap: () => onTap(e.key),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
class _TabItem extends StatelessWidget {
  final _TabMeta meta;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({
    required this.meta,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: isActive ? 52.w : 40.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primarySurface : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isActive ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    isActive ? meta.icon : meta.iconOutline,
                    size: 22.sp,
                    color: color,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1.1,
                letterSpacing: isActive ? 0.1 : 0,
              ),
              child: Text(meta.label),
            ),
          ],
        ),
      ),
    );
  }
}
class _TabMeta {
  final IconData icon;
  final IconData iconOutline;
  final String label;
  const _TabMeta({required this.icon, required this.iconOutline, required this.label});
}
