import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_day_butler/index.dart';
import '../../services/notification_service.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
class ReminderTimelineItem {
  final DateTime when;
  final String kind;
  const ReminderTimelineItem({required this.when, required this.kind});
}
class DayButlerAddDateLogic extends GetxController {
  final _db = db;
  final _notifService = NotificationService();
  final selectedType = 'Birthday'.obs;
  final customName = ''.obs;
  final selectedDate = DateTime.now().obs;
  final repeatYearly = false.obs;
  final customNameError = false.obs;
  final selectedReminderDays = <String>{}.obs;
  final reminderTime = '9:00 AM'.obs;
  final cakeReminderEnabled = false.obs;
  final cakeReminderDays = '3 days'.obs;
  final cakeReminderTime = '9:00 AM'.obs;
  final flowerReminderEnabled = false.obs;
  final flowerReminderDays = '2 days'.obs;
  final flowerReminderTime = '9:00 AM'.obs;
  final showNotificationWarning = false.obs;
  final isSaving = false.obs;
  final selectedPreset = ''.obs;
  final appliedFromLast = false.obs;
  final relationshipHint = ''.obs;
  final personName = 'Someone'.obs;
  final personRelationship = ''.obs;
  int? _personId;
  int? _editDateId;
  String? _existingCreatedAt;
  String? _existingPrepChecklist;
  bool get isEditMode => _editDateId != null;
  String get pageTitle => isEditMode ? 'Edit Date' : 'New Date';
  bool get showCustomName => selectedType.value == 'Custom';
  bool get showRepeatYearly => selectedType.value == 'Custom';
  bool get showFlowerReminder =>
      selectedType.value == 'Anniversary' || selectedType.value == 'Custom';
  final List<String> types = ['Birthday', 'Anniversary', 'Custom'];
  final List<String> eventReminderOptions = [
    'None',
    '1 day',
    '3 days',
    '7 days',
    '30 days',
  ];
  final List<String> cakeReminderOptions = [
    '1 day',
    '2 days',
    '3 days',
    '5 days',
    '7 days',
  ];
  final List<String> flowerReminderOptions = [
    '1 day',
    '2 days',
    '3 days',
    '5 days',
    '7 days',
  ];
  final List<String> presetOptions = ['Minimal', 'Standard', 'Full Prep'];
  final List<String> customNameTags = [
    'Graduation',
    'First Meet',
    'Promotion',
    'Pet Birthday',
    'Wedding Day',
    'Housewarming',
  ];
  @override
  void onInit() {
    super.onInit();
    selectedReminderDays.add('1 day');
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['personId'] != null) _personId = args['personId'] as int;
      if (args['id'] != null) {
        _editDateId = args['id'] as int;
        if (args['personId'] != null) _personId = args['personId'] as int;
        _loadExisting();
      }
    }
    _bootstrapNewDateDefaults();
    _checkNotificationPermission();
  }
  Future<void> _bootstrapNewDateDefaults() async {
    if (isEditMode) {
      await _loadPerson();
      return;
    }
    await _loadDefaultReminderTime();
    await _loadPerson();
    final restored = await _tryRestoreLastPrefs();
    if (!restored) _applyRelationshipEventDefaults();
  }
  Future<void> _loadDefaultReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final time = prefs.getString('default_reminder_time') ?? '9:00 AM';
      reminderTime.value = time;
      cakeReminderTime.value = time;
      flowerReminderTime.value = time;
    } catch (_) {}
  }
  Future<void> _loadPerson() async {
    if (_personId == null) return;
    try {
      final person = await _db.getPerson(_personId!);
      if (person == null) return;
      personName.value = person.name;
      personRelationship.value = person.relationship;
    } catch (_) {}
  }
  Future<bool> _tryRestoreLastPrefs() async {
    if (_personId == null) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('date_pref_$_personId');
      if (raw == null || raw.isEmpty) return false;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _applyPrefsMap(map);
      appliedFromLast.value = true;
      relationshipHint.value = '';
      selectedPreset.value = '';
      return true;
    } catch (_) {
      return false;
    }
  }
  void _applyPrefsMap(Map<String, dynamic> map) {
    final days =
        (map['reminderDays'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        <int>[];
    selectedReminderDays.clear();
    for (final d in days) {
      selectedReminderDays.add('$d day${d == 1 ? '' : 's'}');
    }
    final rt = map['reminderTime'] as String?;
    if (rt != null && rt.isNotEmpty) {
      reminderTime.value = rt.contains(' ') ? rt : _formatTime(rt);
    }
    cakeReminderEnabled.value = map['cakeEnabled'] == true;
    final cd = map['cakeDays'] as int?;
    if (cd != null) cakeReminderDays.value = '$cd day${cd == 1 ? '' : 's'}';
    final ct = map['cakeTime'] as String?;
    if (ct != null && ct.isNotEmpty) {
      cakeReminderTime.value = ct.contains(' ') ? ct : _formatTime(ct);
    }
    flowerReminderEnabled.value =
        showFlowerReminder && map['flowerEnabled'] == true;
    final fd = map['flowerDays'] as int?;
    if (fd != null) flowerReminderDays.value = '$fd day${fd == 1 ? '' : 's'}';
    final ft = map['flowerTime'] as String?;
    if (ft != null && ft.isNotEmpty) {
      flowerReminderTime.value = ft.contains(' ') ? ft : _formatTime(ft);
    }
  }
  void _applyRelationshipEventDefaults() {
    final rel = personRelationship.value;
    if (rel.isEmpty) return;
    selectedReminderDays.clear();
    if (rel == 'Partner') {
      selectedReminderDays.addAll(['1 day', '7 days']);
    } else {
      selectedReminderDays.add('1 day');
    }
    relationshipHint.value = 'Suggested for $rel';
    selectedPreset.value = '';
  }
  void onApplyRelationshipSuggestion() {
    final rel = personRelationship.value;
    if (rel.isEmpty) return;
    appliedFromLast.value = false;
    selectedReminderDays.clear();
    if (rel == 'Partner') {
      selectedReminderDays.addAll(['1 day', '7 days']);
      cakeReminderEnabled.value = selectedType.value == 'Birthday';
      if (showFlowerReminder) flowerReminderEnabled.value = true;
    } else if (rel == 'Colleague') {
      selectedReminderDays.add('1 day');
      cakeReminderEnabled.value = false;
      flowerReminderEnabled.value = false;
    } else {
      selectedReminderDays.addAll(['1 day', '7 days']);
      cakeReminderEnabled.value = selectedType.value == 'Birthday';
      if (showFlowerReminder) flowerReminderEnabled.value = false;
    }
    selectedPreset.value = '';
    relationshipHint.value = 'Applied for $rel';
  }
  void onUndoLastPrefs() {
    appliedFromLast.value = false;
    selectedReminderDays.clear();
    selectedReminderDays.add('1 day');
    cakeReminderEnabled.value = false;
    flowerReminderEnabled.value = false;
    selectedPreset.value = 'Minimal';
    _applyRelationshipEventDefaults();
  }
  Future<void> _saveLastPrefs() async {
    if (_personId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'date_pref_$_personId',
        jsonEncode({
          'reminderDays': _reminderDaysList,
          'reminderTime': reminderTime.value,
          'cakeEnabled': cakeReminderEnabled.value,
          'cakeDays': _daysFromStr(cakeReminderDays.value),
          'cakeTime': cakeReminderTime.value,
          'flowerEnabled': flowerReminderEnabled.value,
          'flowerDays': _daysFromStr(flowerReminderDays.value),
          'flowerTime': flowerReminderTime.value,
        }),
      );
    } catch (_) {}
  }
  Future<void> _loadExisting() async {
    try {
      final sd = await _db.getSpecialDate(_editDateId!);
      if (sd == null) return;
      _personId ??= sd.personId;
      _existingCreatedAt = sd.createdAt;
      _existingPrepChecklist = sd.prepChecklist;
      selectedType.value = sd.type;
      customName.value = sd.customName ?? '';
      selectedDate.value = DateTime.parse(sd.date);
      repeatYearly.value = sd.repeatYearly;
      final days = sd.reminderDaysList;
      selectedReminderDays.clear();
      for (final d in days) {
        selectedReminderDays.add('$d day${d == 1 ? '' : 's'}');
      }
      reminderTime.value = sd.reminderTime.contains(':')
          ? _formatTime(sd.reminderTime)
          : sd.reminderTime;
      cakeReminderEnabled.value = sd.cakeReminderEnabled;
      cakeReminderDays.value =
          '${sd.cakeReminderDaysBefore} day${sd.cakeReminderDaysBefore == 1 ? '' : 's'}';
      cakeReminderTime.value = _formatTime(sd.cakeReminderTime);
      flowerReminderEnabled.value = sd.flowerReminderEnabled;
      flowerReminderDays.value =
          '${sd.flowerReminderDaysBefore} day${sd.flowerReminderDaysBefore == 1 ? '' : 's'}';
      flowerReminderTime.value = _formatTime(sd.flowerReminderTime);
      await _loadPerson();
    } catch (_) {
      errorToast('Failed to load date');
    }
  }
  Future<void> _checkNotificationPermission() async {
    final granted = await _notifService.isPermissionGranted();
    showNotificationWarning.value = !granted;
  }
  String _formatTime(String t) {
    try {
      final parts = t.split(':');
      int h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return t;
    }
  }
  String _parseTime(String display) {
    try {
      final ispm = display.toUpperCase().contains('PM');
      final parts = display.replaceAll(RegExp(r'[APMapm\s]'), '').split(':');
      int h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (ispm && h != 12) h += 12;
      if (!ispm && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return '09:00';
    }
  }
  void onTypeSelect(String type) {
    selectedType.value = type;
    if (type == 'Birthday') flowerReminderEnabled.value = false;
    if (type != 'Custom') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (selectedDate.value.isAfter(today)) selectedDate.value = today;
    }
    if (selectedPreset.value.isNotEmpty) onPresetSelect(selectedPreset.value);
  }
  void onCustomNameChanged(String v) {
    customName.value = v;
    if (customNameError.value && v.trim().isNotEmpty) {
      customNameError.value = false;
    }
  }
  void onCustomNameTagTap(String tag) {
    customName.value = tag;
    customNameError.value = false;
  }
  void onDateSelected(DateTime d) => selectedDate.value = d;
  void onPresetSelect(String preset) {
    selectedPreset.value = preset;
    appliedFromLast.value = false;
    selectedReminderDays.clear();
    switch (preset) {
      case 'Minimal':
        selectedReminderDays.add('1 day');
        cakeReminderEnabled.value = false;
        flowerReminderEnabled.value = false;
        break;
      case 'Standard':
        selectedReminderDays.addAll(['1 day', '7 days']);
        cakeReminderEnabled.value = selectedType.value == 'Birthday';
        cakeReminderDays.value = '3 days';
        flowerReminderEnabled.value =
            showFlowerReminder && selectedType.value == 'Anniversary';
        flowerReminderDays.value = '2 days';
        break;
      case 'Full Prep':
        selectedReminderDays.addAll(['1 day', '3 days', '7 days']);
        cakeReminderEnabled.value = true;
        cakeReminderDays.value = '3 days';
        if (showFlowerReminder) {
          flowerReminderEnabled.value = true;
          flowerReminderDays.value = '2 days';
        }
        break;
    }
  }
  Future<void> onReminderTimeTap(
    BuildContext context,
    String current,
    Function(String) onSet,
  ) async {
    final parsed = _parseTime(current);
    final parts = parsed.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = int.tryParse(parts[1]) ?? 0;
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
    );
    if (result != null) {
      final period = result.hour >= 12 ? 'PM' : 'AM';
      final hr = result.hour > 12
          ? result.hour - 12
          : (result.hour == 0 ? 12 : result.hour);
      onSet('$hr:${result.minute.toString().padLeft(2, '0')} $period');
      selectedPreset.value = '';
    }
  }
  void onReminderMainTimeTap(BuildContext context) => onReminderTimeTap(
    context,
    reminderTime.value,
    (t) => reminderTime.value = t,
  );
  void onCakeTimeTap(BuildContext context) => onReminderTimeTap(
    context,
    cakeReminderTime.value,
    (t) => cakeReminderTime.value = t,
  );
  void onFlowerTimeTap(BuildContext context) => onReminderTimeTap(
    context,
    flowerReminderTime.value,
    (t) => flowerReminderTime.value = t,
  );
  void toggleEventReminder(String option) {
    selectedPreset.value = '';
    if (option == 'None') {
      selectedReminderDays.clear();
    } else {
      selectedReminderDays.remove('None');
      if (selectedReminderDays.contains(option)) {
        selectedReminderDays.remove(option);
      } else {
        selectedReminderDays.add(option);
      }
    }
  }
  bool isEventReminderSelected(String option) {
    if (option == 'None') return selectedReminderDays.isEmpty;
    return selectedReminderDays.contains(option);
  }
  void onCakeReminderToggle(bool v) {
    cakeReminderEnabled.value = v;
    selectedPreset.value = '';
  }
  void onCakeDaysSelect(String v) {
    cakeReminderDays.value = v;
    selectedPreset.value = '';
  }
  void onFlowerReminderToggle(bool v) {
    flowerReminderEnabled.value = v;
    selectedPreset.value = '';
  }
  void onFlowerDaysSelect(String v) {
    flowerReminderDays.value = v;
    selectedPreset.value = '';
  }
  void onRepeatYearlyToggle(bool v) => repeatYearly.value = v;
  void onBrowseGiftsTap() {
    if (_personId == null) return;
    Get.toNamed('/gift/add', arguments: {'personId': _personId});
  }
  void onOrderFlowersTap() {
    if (_personId == null) return;
    Get.toNamed('/flower/add', arguments: {'personId': _personId});
  }
  String get formattedDate {
    const m = [
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
    return '${m[selectedDate.value.month - 1]} ${selectedDate.value.day}, ${selectedDate.value.year}';
  }
  DateTime get maxDate =>
      selectedType.value == 'Custom' ? DateTime(2100) : DateTime.now();
  bool get _isYearlyEvent =>
      selectedType.value != 'Custom' || repeatYearly.value;
  String get countdownLabel {
    final d = selectedDate.value;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    if (!_isYearlyEvent) {
      final target = DateTime(d.year, d.month, d.day);
      final days = target.difference(todayNorm).inDays;
      if (days < 0) return 'One-time · past';
      if (days == 0) return 'Today';
      if (days == 1) return 'Tomorrow · ${formatMonthDay(getDateString(d))}';
      return 'In $days days · ${formatMonthDay(getDateString(d))}';
    }
    final days = daysUntilNext(d.month, d.day);
    var next = DateTime(today.year, d.month, d.day);
    if (next.isBefore(todayNorm))
      next = DateTime(today.year + 1, d.month, d.day);
    final nextLabel =
        '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][next.month - 1]} ${next.day}, ${next.year}';
    if (days == 0) {
      return selectedType.value == 'Birthday'
          ? 'Today 🎂 · $nextLabel'
          : 'Today 🎉 · $nextLabel';
    }
    if (days == 1) return 'Tomorrow · $nextLabel';
    return 'In $days days · next on $nextLabel';
  }
  String? get milestoneLabel {
    final d = selectedDate.value;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    var nextYear = today.year;
    if (DateTime(today.year, d.month, d.day).isBefore(todayNorm)) {
      nextYear++;
    }
    if (selectedType.value == 'Birthday') {
      final turning = nextYear - d.year;
      if (turning <= 0 || turning > 150) return null;
      return 'Turning $turning this year';
    }
    if (selectedType.value == 'Anniversary') {
      final years = nextYear - d.year;
      if (years <= 0) return 'Starting this year';
      return '${_ordinal(years)} anniversary coming up';
    }
    return null;
  }
  String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
  String get eventNameLabel {
    if (showCustomName) {
      final name = customName.value.trim();
      return name.isEmpty ? 'Custom' : name;
    }
    return selectedType.value;
  }
  String? get eventNotifPreview {
    if (selectedReminderDays.isEmpty) return null;
    final days = List<int>.from(_reminderDaysList)..sort();
    final d = days.first;
    final name = personName.value;
    final event = eventNameLabel;
    if (d == 0) return "Don't forget to wish $name!";
    return "$name's $event is in $d day${d == 1 ? '' : 's'}!";
  }
  String? get cakeNotifPreview {
    if (!cakeReminderEnabled.value) return null;
    final d = _daysFromStr(cakeReminderDays.value);
    return "${personName.value}'s $eventNameLabel is in $d day${d == 1 ? '' : 's'} — time to order the cake!";
  }
  String? get flowerNotifPreview {
    if (!showFlowerReminder || !flowerReminderEnabled.value) return null;
    final d = _daysFromStr(flowerReminderDays.value);
    return "${personName.value}'s $eventNameLabel is in $d day${d == 1 ? '' : 's'} — order flowers in advance!";
  }
  List<ReminderTimelineItem> get timelineItems {
    final items = <ReminderTimelineItem>[];
    for (final days in _reminderDaysList) {
      final when = _nextFire(selectedDate.value, days, reminderTime.value);
      if (when != null)
        items.add(ReminderTimelineItem(when: when, kind: 'Event'));
    }
    if (cakeReminderEnabled.value) {
      final when = _nextFire(
        selectedDate.value,
        _daysFromStr(cakeReminderDays.value),
        cakeReminderTime.value,
      );
      if (when != null)
        items.add(ReminderTimelineItem(when: when, kind: 'Cake'));
    }
    if (showFlowerReminder && flowerReminderEnabled.value) {
      final when = _nextFire(
        selectedDate.value,
        _daysFromStr(flowerReminderDays.value),
        flowerReminderTime.value,
      );
      if (when != null) {
        items.add(ReminderTimelineItem(when: when, kind: 'Flower'));
      }
    }
    items.sort((a, b) => a.when.compareTo(b.when));
    return items.take(5).toList();
  }
  String formatTimelineItem(ReminderTimelineItem item) {
    const m = [
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
    final t = _formatTime(
      '${item.when.hour.toString().padLeft(2, '0')}:${item.when.minute.toString().padLeft(2, '0')}',
    );
    return '${m[item.when.month - 1]} ${item.when.day} · $t · ${item.kind}';
  }
  DateTime? _nextFire(DateTime eventDate, int daysBefore, String timeDisplay) {
    try {
      final timeStr = _parseTime(timeDisplay);
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      DateTime nextEvent;
      if (_isYearlyEvent) {
        nextEvent = DateTime(today.year, eventDate.month, eventDate.day);
        if (nextEvent.isBefore(todayDate)) {
          nextEvent = DateTime(today.year + 1, eventDate.month, eventDate.day);
        }
      } else {
        nextEvent = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (nextEvent.isBefore(todayDate)) return null;
      }
      final scheduled = DateTime(nextEvent.year, nextEvent.month, nextEvent.day)
          .subtract(Duration(days: daysBefore))
          .add(Duration(hours: hour, minutes: minute));
      return scheduled.isAfter(DateTime.now()) ? scheduled : null;
    } catch (_) {
      return null;
    }
  }
  List<int> get _reminderDaysList => selectedReminderDays
      .map((s) => int.tryParse(s.split(' ')[0]) ?? 1)
      .toList();
  int _daysFromStr(String s) => int.tryParse(s.split(' ')[0]) ?? 1;
  Future<void> onSaveTap() async {
    if (_personId == null || _personId == 0) {
      errorToast('Contact not found');
      return;
    }
    if (showCustomName && customName.value.trim().isEmpty) {
      customNameError.value = true;
      return;
    }
    if (isSaving.value) return;
    final hasReminders =
        selectedReminderDays.isNotEmpty ||
        cakeReminderEnabled.value ||
        (showFlowerReminder && flowerReminderEnabled.value);
    if (hasReminders) {
      await _ensureNotificationPermissionForSave();
    }
    isSaving.value = true;
    try {
      final dateStr = getDateString(selectedDate.value);
      final now = DateTime.now().toIso8601String();
      final reminderDaysJson = jsonEncode(_reminderDaysList);
      if (selectedType.value == 'Birthday') {
        final existing = await _db.getBirthdayByPersonId(_personId!);
        if (existing != null && existing.id != _editDateId) {
          final confirmed = await _showBirthdayReplaceDialog();
          if (!confirmed) {
            isSaving.value = false;
            return;
          }
          try {
            await _notifService.cancelAllForDate(existing.id!);
          } catch (_) {}
          await _db.deleteSpecialDate(existing.id!);
        }
      }
      final flowerOn = showFlowerReminder && flowerReminderEnabled.value;
      final sd = SpecialDate(
        id: _editDateId,
        personId: _personId!,
        type: selectedType.value,
        customName: showCustomName ? customName.value.trim() : null,
        date: dateStr,
        repeatYearly: showRepeatYearly ? repeatYearly.value : true,
        reminderDays: reminderDaysJson,
        reminderTime: _parseTime(reminderTime.value),
        cakeReminderEnabled: cakeReminderEnabled.value,
        cakeReminderDaysBefore: _daysFromStr(cakeReminderDays.value),
        cakeReminderTime: _parseTime(cakeReminderTime.value),
        flowerReminderEnabled: flowerOn,
        flowerReminderDaysBefore: _daysFromStr(flowerReminderDays.value),
        flowerReminderTime: _parseTime(flowerReminderTime.value),
        prepChecklist:
            _existingPrepChecklist ??
            '{"gift":false,"cake":false,"flower":false,"wish":false}',
        createdAt: _existingCreatedAt ?? now,
      );
      int? savedId;
      if (isEditMode) {
        await _db.updateSpecialDate(sd);
        savedId = _editDateId;
      } else {
        savedId = await _db.insertSpecialDate(sd);
      }
      var reminderOk = true;
      if (savedId != null) {
        try {
          if (hasReminders) {
            await _notifService.scheduleForSpecialDate(
              dateId: savedId,
              personName: personName.value,
              eventName: eventNameLabel,
              eventDate: selectedDate.value,
              reminderDays: _reminderDaysList,
              reminderTime: _parseTime(reminderTime.value),
              cakeEnabled: cakeReminderEnabled.value,
              cakeDaysBefore: _daysFromStr(cakeReminderDays.value),
              cakeTime: _parseTime(cakeReminderTime.value),
              flowerEnabled: flowerOn,
              flowerDaysBefore: _daysFromStr(flowerReminderDays.value),
              flowerTime: _parseTime(flowerReminderTime.value),
            );
          } else {
            await _notifService.cancelAllForDate(savedId);
          }
        } catch (_) {
          reminderOk = false;
        }
      }
      await _saveLastPrefs();
      if (!reminderOk) {
        errorToast('Date saved, but reminders could not be scheduled');
      } else {
        successToast(isEditMode ? 'Date updated' : 'Date added');
      }
      Get.back();
    } catch (e) {
      errorToast('Failed to save date');
    } finally {
      isSaving.value = false;
    }
  }
  Future<void> _ensureNotificationPermissionForSave() async {
    try {
      final granted = await _notifService.isPermissionGranted();
      if (granted) {
        showNotificationWarning.value = false;
        return;
      }
      final status = await ph.Permission.notification.status;
      if (status.isPermanentlyDenied) {
        showNotificationWarning.value = true;
        errorToast('Please enable notifications in system Settings');
        return;
      }
      final requested = await _notifService.requestPermission();
      showNotificationWarning.value = !requested;
      if (!requested) {
        errorToast('Reminders need notification permission');
      }
    } catch (_) {
      showNotificationWarning.value = true;
    }
  }
  Future<bool> _showBirthdayReplaceDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Replace Birthday'),
        content: const Text('This person already has a birthday. Replace it?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  void onOpenSettings() => ph.openAppSettings();
  void onCancelTap() => Get.back();
}
