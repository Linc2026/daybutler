import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_day_butler/index.dart';
import '../../services/notification_service.dart';
import '../../utils/index.dart';
import '../day_butler_calendar/day_butler_calendar_logic.dart';
import '../day_butler_gifts/day_butler_gifts_logic.dart';
import '../day_butler_home/day_butler_home_logic.dart';
class DayButlerSettingsLogic extends GetxController with WidgetsBindingObserver {
  final defaultReminderTime = '9:00 AM'.obs;
  final notificationsEnabled = false.obs;
  final isClearing = false.obs;
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadSettings();
  }
  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadSettings();
    }
  }
  void onResumed() => loadSettings();
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      defaultReminderTime.value =
          prefs.getString('default_reminder_time') ?? '9:00 AM';
      notificationsEnabled.value = await NotificationService().isEnabled();
    } catch (_) {}
  }
  Future<void> onReminderTimeTap(BuildContext context) async {
    final parsed = _parseTime(defaultReminderTime.value);
    final parts = parsed.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = int.tryParse(parts[1]) ?? 0;
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
    );
    if (result == null) return;
    final period = result.hour >= 12 ? 'PM' : 'AM';
    final hr = result.hour > 12
        ? result.hour - 12
        : (result.hour == 0 ? 12 : result.hour);
    await onReminderTimeChanged(
      '$hr:${result.minute.toString().padLeft(2, '0')} $period',
    );
  }
  Future<void> onReminderTimeChanged(String time) async {
    defaultReminderTime.value = time;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_reminder_time', time);
      successToast('Default reminder time updated');
    } catch (_) {
      errorToast('Failed to update reminder time');
    }
  }
  Future<void> onToggleNotifications() async {
    try {
      final notif = NotificationService();
      if (notificationsEnabled.value) {
        await notif.setAppEnabled(false);
        notificationsEnabled.value = false;
        successToast('Notifications disabled');
        return;
      }
      final status = await ph.Permission.notification.status;
      if (status.isPermanentlyDenied) {
        errorToast('Please enable notifications in system Settings');
        return;
      }
      final granted =
          status.isGranted ? true : await notif.requestPermission();
      if (granted) {
        await notif.setAppEnabled(true);
        notificationsEnabled.value = true;
        successToast('Notifications enabled');
      } else {
        errorToast('Please enable notifications in system Settings');
      }
    } catch (_) {
      errorToast('Failed to update notification settings');
    }
  }
  String _parseTime(String display) {
    try {
      final isPm = display.toUpperCase().contains('PM');
      final parts = display.replaceAll(RegExp(r'[APMapm\s]'), '').split(':');
      int h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return '09:00';
    }
  }
  Future<void> onClearAllDataTap() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all people, dates, gifts, flower records, and custom wishes. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    isClearing.value = true;
    try {
      await db.clearAllUserData();
      await NotificationService().cancelAll();
      await _clearUserPrefs();
      await _refreshTabs();
      successToast('All data cleared');
    } catch (_) {
      errorToast('Failed to clear data');
    } finally {
      isClearing.value = false;
    }
  }
  Future<void> _clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (key.startsWith('wished_') ||
          key.startsWith('date_pref_') ||
          key.startsWith('florist_')) {
        await prefs.remove(key);
      }
    }
  }
  Future<void> _refreshTabs() async {
    if (Get.isRegistered<DayButlerHomeLogic>()) {
      await Get.find<DayButlerHomeLogic>().loadData();
    }
    if (Get.isRegistered<DayButlerCalendarLogic>()) {
      await Get.find<DayButlerCalendarLogic>().loadMonthData();
    }
    if (Get.isRegistered<DayButlerGiftsLogic>()) {
      await Get.find<DayButlerGiftsLogic>().loadData();
    }
  }
  void onFlowersTap() => Get.toNamed('/flowers');
  void onWishesTap() => Get.toNamed('/wishes');
  void onYearReviewTap() => Get.toNamed('/year-review');
}
