import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/gradient_app_bar.dart';
import '../../main.dart';
import 'day_butler_settings_logic.dart';
class DayButlerSettingsView extends GetView<DayButlerSettingsLogic> {
  const DayButlerSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: GradientAppBar(
        title: Text('Settings', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
      ),
      body: Obx(() => ListView(
        children: [
          SizedBox(height: 12.h),
          _buildMenuSection([
            _MenuItem(icon: '🌹', label: 'Romantic Flowers', onTap: controller.onFlowersTap),
            _MenuItem(icon: '💌', label: 'Wishes', onTap: controller.onWishesTap),
            _MenuItem(icon: '🏆', label: 'Year in Review', onTap: controller.onYearReviewTap),
          ]),
          SizedBox(height: 16.h),
          _sectionLabel('NOTIFICATIONS'),
          _settingsCard(children: [
            _switchRow(
              icon: Icons.notifications_rounded,
              label: 'Enable Notifications',
              subtitle: controller.notificationsEnabled.value
                  ? 'Notifications are enabled'
                  : 'Tap to enable notifications',
              value: controller.notificationsEnabled.value,
              onChanged: (_) => controller.onToggleNotifications(),
            ),
            _timeRow(
              icon: Icons.access_time,
              label: 'Default Reminder Time',
              subtitle: 'Used for new dates unless overridden',
              timeDisplay: controller.defaultReminderTime.value,
              onTap: () => controller.onReminderTimeTap(context),
            ),
          ]),
          SizedBox(height: 16.h),
          _sectionLabel('DATA'),
          _settingsCard(children: [
            _dangerRow(
              icon: Icons.delete_forever_rounded,
              label: 'Clear All Data',
              subtitle: 'Delete all people, dates, gifts & records',
              onTap: controller.isClearing.value ? null : controller.onClearAllDataTap,
            ),
          ]),
          SizedBox(height: 24.h),
          Center(child: Text('Birthday Butler v1.0.0', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFCCCCCC)))),
          SizedBox(height: 20.h),
        ],
      )),
    );
  }
  Widget _buildMenuSection(List<_MenuItem> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: items.asMap().entries.map((e) => _buildRow(e.value, e.key == items.length - 1)).toList(),
      ),
    );
  }
  Widget _buildRow(_MenuItem item, bool isLast) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: const Color(0xFFF0E6E2))),
        ),
        child: Row(
          children: [
            Text(item.icon, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(item.label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A1A))),
            ),
            Icon(Icons.chevron_right, color: const Color(0xFFBBBBBB), size: 18.sp),
          ],
        ),
      ),
    );
  }
  Widget _sectionLabel(String label) => Padding(
    padding: EdgeInsets.only(bottom: 8.h, left: 20.w),
    child: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF999999), letterSpacing: 0.5)),
  );
  Widget _settingsCard({required List<Widget> children}) => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 1))]),
    child: Column(children: children),
  );
  Widget _switchRow({required IconData icon, required String label, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(children: [
        Container(width: 36.w, height: 36.w, decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(icon, color: primaryColor, size: 18.sp)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
          Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999))),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: primaryColor),
      ]),
    );
  }
  Widget _timeRow({required IconData icon, required String label, required String subtitle, required String timeDisplay, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: const Color(0xFFF0E6E2)))),
        child: Row(children: [
          Container(width: 36.w, height: 36.w, decoration: BoxDecoration(color: const Color(0xFF5B9BD5).withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(icon, color: const Color(0xFF5B9BD5), size: 18.sp)),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
            Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999))),
          ])),
          Text(timeDisplay, style: TextStyle(fontSize: 15.sp, color: primaryColor, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
  Widget _dangerRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFFE74C3C), size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE74C3C),
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: const Color(0xFFBBBBBB), size: 18.sp),
        ]),
      ),
    );
  }
}
class _MenuItem {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
