import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();
  static const _enabledKey = 'notifications_enabled';
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }
  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
  Future<bool> requestPermission() async {
    final result = await Permission.notification.request();
    return result.isGranted;
  }
  Future<bool> isAppEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }
  Future<bool> isEnabled() async {
    if (!await isAppEnabled()) return false;
    return isPermissionGranted();
  }
  Future<void> setAppEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) await cancelAll();
  }
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await init();
    if (!await isEnabled()) return;
    if (scheduledDate.isBefore(DateTime.now())) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'birthday_butler_channel',
        'Birthday Butler Reminders',
        channelDescription: 'Reminders for birthdays and special dates',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _plugin.cancel(id);
  }
  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
  Future<void> cancelAllForDate(int dateId) async {
    for (int i = 0; i < 20; i++) {
      await cancel(dateId * 100 + i);
    }
  }
  Future<void> scheduleForSpecialDate({
    required int dateId,
    required String personName,
    required String eventName,
    required DateTime eventDate,
    required List<int> reminderDays,
    required String reminderTime,
    required bool cakeEnabled,
    required int cakeDaysBefore,
    required String cakeTime,
    required bool flowerEnabled,
    required int flowerDaysBefore,
    required String flowerTime,
  }) async {
    await cancelAllForDate(dateId);
    if (!await isEnabled()) return;
    int notifIndex = 0;
    for (final daysBefore in reminderDays) {
      final scheduled = _buildNotificationDateTime(eventDate, daysBefore, reminderTime);
      if (scheduled != null) {
        await schedule(
          id: dateId * 100 + notifIndex++,
          title: daysBefore == 0 ? '🎉 Today is $eventName!' : '📅 $eventName is coming up',
          body: daysBefore == 0
              ? "Don't forget to wish $personName!"
              : "$personName's $eventName is in $daysBefore day${daysBefore == 1 ? '' : 's'}!",
          scheduledDate: scheduled,
        );
      }
    }
    if (cakeEnabled) {
      final scheduled = _buildNotificationDateTime(eventDate, cakeDaysBefore, cakeTime);
      if (scheduled != null) {
        await schedule(
          id: dateId * 100 + notifIndex++,
          title: '🎂 Time to order a cake!',
          body: "$personName's $eventName is in $cakeDaysBefore day${cakeDaysBefore == 1 ? '' : 's'} — time to order the cake!",
          scheduledDate: scheduled,
        );
      }
    }
    if (flowerEnabled) {
      final scheduled = _buildNotificationDateTime(eventDate, flowerDaysBefore, flowerTime);
      if (scheduled != null) {
        await schedule(
          id: dateId * 100 + notifIndex++,
          title: '🌹 Order flowers in advance!',
          body: "$personName's $eventName is in $flowerDaysBefore day${flowerDaysBefore == 1 ? '' : 's'} — order flowers in advance!",
          scheduledDate: scheduled,
        );
      }
    }
  }
  DateTime? _buildNotificationDateTime(DateTime eventDate, int daysBefore, String timeStr) {
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      final minPart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      final int minute = int.parse(minPart.isNotEmpty ? minPart : '0');
      if (timeStr.toLowerCase().contains('pm') && hour < 12) hour += 12;
      if (timeStr.toLowerCase().contains('am') && hour == 12) hour = 0;
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      var nextEvent = DateTime(today.year, eventDate.month, eventDate.day);
      if (nextEvent.isBefore(todayDate)) {
        nextEvent = DateTime(today.year + 1, eventDate.month, eventDate.day);
      }
      final scheduled = DateTime(nextEvent.year, nextEvent.month, nextEvent.day)
          .subtract(Duration(days: daysBefore))
          .add(Duration(hours: hour, minutes: minute));
      return scheduled.isAfter(DateTime.now()) ? scheduled : null;
    } catch (_) {
      return null;
    }
  }
}
