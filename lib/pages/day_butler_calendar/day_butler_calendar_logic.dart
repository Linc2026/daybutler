import 'dart:math';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/calendar.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
enum CalendarTypeFilter { all, birthday, anniversary, custom }
enum MonthBusyLevel { quiet, steady, busy }
class CalendarEventItem {
  final int day;
  final int personId;
  final int dateId;
  final String personName;
  final String relationship;
  final String avatarLetter;
  final int avatarColor;
  final String? avatarPath;
  final String eventType;
  final String eventMeta;
  final EventType type;
  final bool isPast;
  final int? age;
  final bool wishedToday;
  final int prepIncomplete;
  final SpecialDate raw;
  const CalendarEventItem({
    required this.day,
    required this.personId,
    required this.dateId,
    required this.personName,
    required this.relationship,
    required this.avatarLetter,
    required this.avatarColor,
    this.avatarPath,
    required this.eventType,
    required this.eventMeta,
    required this.type,
    required this.isPast,
    this.age,
    this.wishedToday = false,
    this.prepIncomplete = 0,
    required this.raw,
  });
  int get prepDone => prepChecklistKeys.length - prepIncomplete;
  bool get prepReady => prepIncomplete == 0;
  String get prepProgressLabel =>
      prepReady ? 'Ready' : '$prepDone/${prepChecklistKeys.length} ready';
  CalendarEventItem copyWith({bool? wishedToday}) {
    return CalendarEventItem(
      day: day,
      personId: personId,
      dateId: dateId,
      personName: personName,
      relationship: relationship,
      avatarLetter: avatarLetter,
      avatarColor: avatarColor,
      avatarPath: avatarPath,
      eventType: eventType,
      eventMeta: eventMeta,
      type: type,
      isPast: isPast,
      age: age,
      wishedToday: wishedToday ?? this.wishedToday,
      prepIncomplete: prepIncomplete,
      raw: raw,
    );
  }
}
class DayButlerCalendarLogic extends GetxController {
  final _db = db;
  final _random = Random();
  final now = DateTime.now();
  final displayYear = 0.obs;
  final displayMonth = 0.obs;
  final selectedDay = Rx<int?>(null);
  final monthEventsObs = <CalendarEventItem>[].obs;
  final typeFilter = CalendarTypeFilter.all.obs;
  final daySheetVisible = false.obs;
  final daySheetDay = Rx<int?>(null);
  final wishCardVisible = false.obs;
  final wishCardEvent = Rx<CalendarEventItem?>(null);
  final wishCardWishes = <WishTemplate>[].obs;
  final wishCardIndex = 0.obs;
  final wishCardCategory = 'Birthday'.obs;
  @override
  void onInit() {
    super.onInit();
    displayYear.value = now.year;
    displayMonth.value = now.month;
    selectedDay.value = now.day;
    loadMonthData();
  }
  void onResumed() => loadMonthData();
  String get monthTitle =>
      '${fullMonthName(displayMonth.value)} ${displayYear.value}';
  int get daysInMonth =>
      DateTime(displayYear.value, displayMonth.value + 1, 0).day;
  int get firstWeekdayOfMonth =>
      DateTime(displayYear.value, displayMonth.value, 1).weekday % 7;
  bool get isCurrentMonth =>
      displayYear.value == now.year && displayMonth.value == now.month;
  bool get showTodayBtn => !isCurrentMonth;
  bool isToday(int day) => isCurrentMonth && day == now.day;
  List<CalendarEventItem> get monthEvents => monthEventsObs;
  List<CalendarEventItem> get filteredEvents {
    final f = typeFilter.value;
    if (f == CalendarTypeFilter.all) return monthEvents;
    return monthEvents.where((e) => e.type == _filterToEventType(f)).toList();
  }
  Map<int, List<EventType>> get markedDates {
    final Map<int, List<EventType>> marks = {};
    for (final e in filteredEvents) {
      marks.putIfAbsent(e.day, () => []);
      if (!marks[e.day]!.contains(e.type)) marks[e.day]!.add(e.type);
    }
    return marks;
  }
  Map<int, int> get prepBadges {
    final Map<int, int> map = {};
    for (final e in filteredEvents) {
      if (e.isPast || e.prepIncomplete <= 0) continue;
      map[e.day] = (map[e.day] ?? 0) + e.prepIncomplete;
    }
    return map;
  }
  Set<int> get conflictDays {
    final counts = <int, int>{};
    for (final e in filteredEvents) {
      counts[e.day] = (counts[e.day] ?? 0) + 1;
    }
    return counts.entries.where((e) => e.value >= 2).map((e) => e.key).toSet();
  }
  Map<int, List<CalendarEventItem>> get groupedEvents {
    final Map<int, List<CalendarEventItem>> map = {};
    for (final e in filteredEvents) {
      map.putIfAbsent(e.day, () => []).add(e);
    }
    return map;
  }
  List<int> get sortedEventDays => groupedEvents.keys.toList()..sort();
  Map<int, List<CalendarEventItem>> get listGroupedEvents {
    final day = selectedDay.value;
    if (day == null) return groupedEvents;
    final events = filteredEvents.where((e) => e.day == day).toList();
    if (events.isEmpty) return {};
    return {day: events};
  }
  List<int> get listSortedDays => listGroupedEvents.keys.toList()..sort();
  bool get isDayListFiltered => selectedDay.value != null;
  String get selectedDayLabel {
    final day = selectedDay.value;
    if (day == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[displayMonth.value - 1]} $day';
  }
  List<CalendarEventItem> get daySheetEvents {
    final day = daySheetDay.value;
    if (day == null) return const [];
    return filteredEvents.where((e) => e.day == day).toList();
  }
  bool get daySheetIsTight => daySheetEvents.length >= 2;
  String get daySheetTitle {
    final day = daySheetDay.value;
    if (day == null) return '';
    return '${fullMonthName(displayMonth.value)} $day, ${displayYear.value}';
  }
  String get daySheetSubtitle {
    final day = daySheetDay.value;
    if (day == null) return '';
    final date = DateTime(displayYear.value, displayMonth.value, day);
    final weekday = _weekdayName(date);
    final count = daySheetEvents.length;
    final label = count == 1 ? '1 event' : '$count events';
    return '$weekday · $label';
  }
  String get daySheetTightHint {
    final n = daySheetEvents.length;
    return 'Tight day — $n people same day. Stagger gifts if needed.';
  }
  int get birthdayCount =>
      monthEvents.where((e) => e.type == EventType.birthday).length;
  int get anniversaryCount =>
      monthEvents.where((e) => e.type == EventType.anniversary).length;
  int get customCount =>
      monthEvents.where((e) => e.type == EventType.custom).length;
  int get totalEventCount => monthEvents.length;
  MonthBusyLevel get busyLevel {
    if (totalEventCount == 0 ||
        (totalEventCount <= 2 && birthdayCount <= 2)) {
      return MonthBusyLevel.quiet;
    }
    if (totalEventCount >= 8 || birthdayCount >= 5) {
      return MonthBusyLevel.busy;
    }
    return MonthBusyLevel.steady;
  }
  String get busyLevelLabel {
    switch (busyLevel) {
      case MonthBusyLevel.quiet:
        return 'Quiet';
      case MonthBusyLevel.steady:
        return 'Steady';
      case MonthBusyLevel.busy:
        return 'Busy';
    }
  }
  String get busyScoreText {
    final parts = <String>[];
    if (birthdayCount > 0) {
      parts.add(
        '$birthdayCount birthday${birthdayCount == 1 ? '' : 's'}',
      );
    }
    if (anniversaryCount > 0) {
      parts.add(
        anniversaryCount == 1
            ? '1 anniversary'
            : '$anniversaryCount anniversaries',
      );
    }
    if (customCount > 0) {
      parts.add('$customCount custom');
    }
    if (parts.isEmpty) return 'No events this month';
    return parts.join(' · ');
  }
  bool get showFocusStrip {
    if (isDayListFiltered) return false;
    return focusEvents.isNotEmpty;
  }
  List<CalendarEventItem> get focusEvents {
    final selected = selectedDay.value;
    final upcoming = filteredEvents.where((e) {
      if (e.isPast) return false;
      if (selected != null && e.day == selected) return false;
      return true;
    }).toList();
    upcoming.sort((a, b) {
      final ap = a.prepIncomplete > 0 ? 0 : 1;
      final bp = b.prepIncomplete > 0 ? 0 : 1;
      if (ap != bp) return ap.compareTo(bp);
      return a.day.compareTo(b.day);
    });
    return upcoming.take(2).toList();
  }
  String focusCountdown(CalendarEventItem e) {
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(displayYear.value, displayMonth.value, e.day);
    final days = target.difference(today).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days > 1) return 'in ${days}d';
    return '';
  }
  String get currentWishContent {
    if (wishCardWishes.isEmpty) return '';
    return wishCardWishes[wishCardIndex.value].content;
  }
  String get currentWishPreview {
    final event = wishCardEvent.value;
    if (event == null || wishCardWishes.isEmpty) return '';
    final cat = wishCardCategory.value;
    if (cat == 'Birthday') {
      return '🎂 Happy Birthday, ${event.personName}! $currentWishContent';
    }
    if (cat == 'Anniversary') {
      return '🎉 Happy Anniversary, ${event.personName}! $currentWishContent';
    }
    return '🎉 ${event.personName}! $currentWishContent';
  }
  String get wishCounterLabel {
    if (wishCardWishes.isEmpty) return '0 / 0';
    return '${wishCardIndex.value + 1} / ${wishCardWishes.length}';
  }
  String get wishCardSubtitle {
    final event = wishCardEvent.value;
    if (event == null) return '';
    final icon = eventTypeIcon(event.raw.type);
    if (event.eventMeta.isEmpty) return '$icon ${event.eventType}';
    return '$icon ${event.eventType} · ${event.eventMeta}';
  }
  Future<void> loadMonthData() async {
    try {
      final people = await _db.getPeople();
      final allDates = await _db.getSpecialDates();
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final List<CalendarEventItem> events = [];
      for (final d in allDates) {
        final date = DateTime.parse(d.date);
        int? targetDay;
        if (d.type == 'Custom' && !d.repeatYearly) {
          if (date.year == displayYear.value &&
              date.month == displayMonth.value) {
            targetDay = date.day;
          }
        } else {
          if (date.month == displayMonth.value) targetDay = date.day;
        }
        if (targetDay == null || targetDay < 1 || targetDay > daysInMonth) {
          continue;
        }
        final person = people.firstWhereOrNull((p) => p.id == d.personId);
        if (person == null) continue;
        final targetDate =
            DateTime(displayYear.value, displayMonth.value, targetDay);
        final isPast = targetDate.isBefore(todayNorm);
        final age = _calcAge(d, displayYear.value);
        final eventMeta = _calcEventMeta(d, displayYear.value, age);
        final prepMap = d.prepChecklistMap;
        final incomplete = prepIncompleteCount(prepMap);
        events.add(CalendarEventItem(
          day: targetDay,
          personId: person.id!,
          dateId: d.id!,
          personName: person.name,
          relationship: person.relationship,
          avatarLetter: person.name[0].toUpperCase(),
          avatarColor: resolveAvatarColor(person.name, person.avatarPath),
          avatarPath: person.avatarPath,
          eventType: eventDisplayName(d),
          eventMeta: eventMeta,
          type: _toEventType(d.type),
          isPast: isPast,
          age: age,
          wishedToday: prefs.getBool(wishedTodayKey(person.id!)) ?? false,
          prepIncomplete: incomplete,
          raw: d,
        ));
      }
      events.sort((a, b) => a.day.compareTo(b.day));
      monthEventsObs.value = events;
      final wish = wishCardEvent.value;
      if (wish != null) {
        wishCardEvent.value = events.firstWhereOrNull(
              (e) => e.dateId == wish.dateId && e.personId == wish.personId,
            ) ??
            wish;
      }
    } catch (e) {
      errorToast('Failed to load calendar data');
    }
  }
  int? _calcAge(SpecialDate sd, int year) {
    if (sd.type != 'Birthday') return null;
    try {
      final date = DateTime.parse(sd.date);
      if (date.year < 1900) return null;
      return year - date.year;
    } catch (_) {
      return null;
    }
  }
  String _calcEventMeta(SpecialDate sd, int displayYear, int? age) {
    try {
      if (sd.type == 'Birthday') {
        return age != null ? 'Turns $age' : '';
      } else if (sd.type == 'Anniversary') {
        final date = DateTime.parse(sd.date);
        final years = displayYear - date.year;
        return years > 0 ? '${ordinal(years)} Anniversary' : '';
      }
    } catch (_) {}
    return '';
  }
  EventType _toEventType(String type) {
    switch (type) {
      case 'Birthday':
        return EventType.birthday;
      case 'Anniversary':
        return EventType.anniversary;
      default:
        return EventType.custom;
    }
  }
  EventType _filterToEventType(CalendarTypeFilter f) {
    switch (f) {
      case CalendarTypeFilter.birthday:
        return EventType.birthday;
      case CalendarTypeFilter.anniversary:
        return EventType.anniversary;
      case CalendarTypeFilter.custom:
        return EventType.custom;
      case CalendarTypeFilter.all:
        return EventType.birthday;
    }
  }
  String _weekdayName(DateTime date) {
    const weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return weekdays[date.weekday % 7];
  }
  void onTypeFilterTap(CalendarTypeFilter filter) {
    typeFilter.value = filter;
    final day = daySheetDay.value;
    if (day != null && daySheetEvents.isEmpty) onCloseDaySheet();
  }
  void onPreviousMonth() {
    if (displayMonth.value == 1) {
      displayMonth.value = 12;
      displayYear.value--;
    } else {
      displayMonth.value--;
    }
    selectedDay.value = null;
    onCloseDaySheet();
    loadMonthData();
  }
  void onNextMonth() {
    if (displayMonth.value == 12) {
      displayMonth.value = 1;
      displayYear.value++;
    } else {
      displayMonth.value++;
    }
    selectedDay.value = null;
    onCloseDaySheet();
    loadMonthData();
  }
  void onTodayTap() {
    displayYear.value = now.year;
    displayMonth.value = now.month;
    selectedDay.value = now.day;
    onCloseDaySheet();
    loadMonthData();
  }
  void onDaySelected(int day) {
    selectedDay.value = day;
    final events = filteredEvents.where((e) => e.day == day).toList();
    if (events.isEmpty) {
      onCloseDaySheet();
      return;
    }
    daySheetDay.value = day;
    daySheetVisible.value = true;
  }
  void onFocusChipTap(CalendarEventItem event) {
    selectedDay.value = event.day;
    daySheetDay.value = event.day;
    daySheetVisible.value = true;
  }
  void onShowAllMonthTap() {
    selectedDay.value = null;
    onCloseDaySheet();
  }
  void onCloseDaySheet() {
    daySheetVisible.value = false;
    daySheetDay.value = null;
  }
  Future<void> onAddDateNudgeTap() async {
    try {
      final people = await _db.getPeople();
      if (people.isEmpty) {
        await Get.toNamed('/person/add');
      } else if (people.length == 1) {
        await Get.toNamed(
          '/date/add',
          arguments: {'personId': people.first.id},
        );
      } else {
        await Get.toNamed('/people');
      }
      await loadMonthData();
    } catch (_) {
      errorToast('Failed to open add date');
    }
  }
  Future<void> onPersonTap(int personId) async {
    onCloseDaySheet();
    onWishCardClose();
    await Get.toNamed('/person/detail', arguments: {'id': personId});
    await loadMonthData();
  }
  Future<void> onSendWishTap(CalendarEventItem event) async {
    wishCardEvent.value = event;
    wishCardIndex.value = 0;
    wishCardCategory.value = event.raw.type == 'Birthday'
        ? 'Birthday'
        : event.raw.type == 'Anniversary'
            ? 'Anniversary'
            : 'General';
    try {
      final raw = await _db.getWishTemplatesByCategory(wishCardCategory.value);
      final ranked = wishCardCategory.value == 'Birthday'
          ? rankBirthdayWishes(
              raw,
              relationship: event.relationship,
              age: event.age,
            )
          : raw;
      wishCardWishes.value = ranked;
      if (ranked.isEmpty) {
        errorToast('No wishes available');
        await Get.toNamed(
          '/person/detail',
          arguments: {'id': event.personId},
        );
        await loadMonthData();
        return;
      }
      final topN = ranked.length >= 3 ? 3 : ranked.length;
      wishCardIndex.value = _random.nextInt(topN);
      wishCardVisible.value = true;
    } catch (_) {
      errorToast('Failed to load wishes');
    }
  }
  void onWishCardClose() => wishCardVisible.value = false;
  void onWishNext() {
    if (wishCardWishes.isEmpty) return;
    wishCardIndex.value = (wishCardIndex.value + 1) % wishCardWishes.length;
  }
  void onWishPrev() {
    if (wishCardWishes.isEmpty) return;
    wishCardIndex.value =
        (wishCardIndex.value - 1 + wishCardWishes.length) %
            wishCardWishes.length;
  }
  Future<void> onWishCopy() async {
    final event = wishCardEvent.value;
    if (wishCardWishes.isEmpty || event == null) return;
    copyToClipboard(currentWishPreview);
    await _markWished(event.personId);
  }
  Future<void> _markWished(int personId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(wishedTodayKey(personId), true);
      monthEventsObs.value = monthEvents
          .map((e) => e.personId == personId ? e.copyWith(wishedToday: true) : e)
          .toList();
      final current = wishCardEvent.value;
      if (current?.personId == personId) {
        wishCardEvent.value = current!.copyWith(wishedToday: true);
      }
    } catch (_) {}
  }
  Future<void> onViewProfileTap() async {
    final event = wishCardEvent.value;
    wishCardVisible.value = false;
    if (event == null) return;
    await Get.toNamed('/person/detail', arguments: {'id': event.personId});
    await loadMonthData();
  }
  Future<void> onWishCardGiftTap() async {
    final event = wishCardEvent.value;
    if (event == null) return;
    wishCardVisible.value = false;
    await Get.toNamed('/gift/add', arguments: {'personId': event.personId});
    await loadMonthData();
  }
  Future<void> onWishCardCakeTap() async {
    final event = wishCardEvent.value;
    if (event == null) return;
    wishCardVisible.value = false;
    await Get.toNamed('/date/edit', arguments: {'id': event.dateId});
    await loadMonthData();
  }
}
