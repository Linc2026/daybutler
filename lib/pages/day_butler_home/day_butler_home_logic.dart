import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
enum HomeHorizon { all, d7, d30, d90 }
class TodayBirthdayItem {
  final int id;
  final int dateId;
  final String name;
  final String relationship;
  final String avatarLetter;
  final int avatarColor;
  final String? avatarPath;
  final int? age;
  final bool wishedToday;
  const TodayBirthdayItem({
    required this.id,
    required this.dateId,
    required this.name,
    required this.relationship,
    required this.avatarLetter,
    required this.avatarColor,
    this.avatarPath,
    this.age,
    this.wishedToday = false,
  });
}
class UpcomingItem {
  final int personId;
  final int dateId;
  final String personName;
  final String relationship;
  final String name;
  final String type;
  final String typeName;
  final String date;
  final String countdown;
  final String avatarLetter;
  final int avatarColor;
  final String? avatarPath;
  final bool isToday;
  final bool isBirthday;
  final int daysUntil;
  final Map<String, bool> prepMap;
  final int incompletePrepCount;
  const UpcomingItem({
    required this.personId,
    required this.dateId,
    required this.personName,
    required this.relationship,
    required this.name,
    required this.type,
    required this.typeName,
    required this.date,
    required this.countdown,
    required this.avatarLetter,
    required this.avatarColor,
    this.avatarPath,
    this.isToday = false,
    this.isBirthday = false,
    required this.daysUntil,
    required this.prepMap,
    required this.incompletePrepCount,
  });
  bool get showPrep => daysUntil <= 30;
  bool get prepAlert => showPrep && incompletePrepCount > 0;
}
class CareRadarItem {
  final int personId;
  final int dateId;
  final String personName;
  final String typeName;
  final int daysUntil;
  final int incompleteCount;
  const CareRadarItem({
    required this.personId,
    required this.dateId,
    required this.personName,
    required this.typeName,
    required this.daysUntil,
    required this.incompleteCount,
  });
  String get chipLabel {
    final when = daysUntil == 0
        ? 'Today'
        : daysUntil == 1
            ? 'Tomorrow'
            : 'in ${daysUntil}d';
    return '$personName · $when · $incompleteCount left';
  }
}
class DayButlerHomeLogic extends GetxController {
  final _db = db;
  final _random = Random();
  static const _horizonPrefKey = 'home_horizon_filter';
  final todayBirthdays = <TodayBirthdayItem>[].obs;
  final upcomingItems = <UpcomingItem>[].obs;
  final peopleCount = 0.obs;
  final isLoading = false.obs;
  final horizon = HomeHorizon.all.obs;
  final wishCardVisible = false.obs;
  final wishCardPerson = Rx<TodayBirthdayItem?>(null);
  final wishCardWishes = <WishTemplate>[].obs;
  final wishCardIndex = 0.obs;
  final prepSheetItem = Rx<UpcomingItem?>(null);
  final prepSheetMap = <String, bool>{}.obs;
  String get todayBannerSubtitle {
    final list = todayBirthdays;
    if (list.isEmpty) return '';
    if (list.length == 1) {
      final p = list.first;
      if (p.age != null) return '${p.name} turns ${p.age} today!';
      return '${p.name} is celebrating today!';
    }
    return '${list.length} birthdays today!';
  }
  bool get showTodayActionStrip => todayBirthdays.length == 1;
  TodayBirthdayItem? get soloTodayBirthday =>
      todayBirthdays.length == 1 ? todayBirthdays.first : null;
  UpcomingItem? get quietDayNext {
    if (todayBirthdays.isNotEmpty || upcomingItems.isEmpty) return null;
    return upcomingItems.first;
  }
  List<CareRadarItem> get careRadarItems {
    return upcomingItems
        .where((i) => i.daysUntil <= 7 && i.incompletePrepCount > 0)
        .take(3)
        .map((i) => CareRadarItem(
              personId: i.personId,
              dateId: i.dateId,
              personName: i.personName,
              typeName: i.typeName,
              daysUntil: i.daysUntil,
              incompleteCount: i.incompletePrepCount,
            ))
        .toList();
  }
  List<UpcomingItem> get filteredUpcoming {
    final maxDays = switch (horizon.value) {
      HomeHorizon.all => 365,
      HomeHorizon.d7 => 7,
      HomeHorizon.d30 => 30,
      HomeHorizon.d90 => 90,
    };
    return upcomingItems.where((i) => i.daysUntil <= maxDays).toList();
  }
  String get currentWishContent {
    if (wishCardWishes.isEmpty) return '';
    return wishCardWishes[wishCardIndex.value].content;
  }
  String get currentWishPreview {
    final person = wishCardPerson.value;
    if (person == null || wishCardWishes.isEmpty) return '';
    return '🎂 Happy Birthday, ${person.name}! $currentWishContent';
  }
  String get wishCounterLabel {
    if (wishCardWishes.isEmpty) return '0 / 0';
    return '${wishCardIndex.value + 1} / ${wishCardWishes.length}';
  }
  @override
  void onInit() {
    super.onInit();
    _loadHorizonPref();
    loadData();
  }
  void onResumed() => loadData();
  Future<void> _loadHorizonPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_horizonPrefKey);
      horizon.value = switch (raw) {
        '7' => HomeHorizon.d7,
        '30' => HomeHorizon.d30,
        '90' => HomeHorizon.d90,
        _ => HomeHorizon.all,
      };
    } catch (_) {}
  }
  Future<void> onHorizonTap(HomeHorizon value) async {
    horizon.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = switch (value) {
        HomeHorizon.all => 'all',
        HomeHorizon.d7 => '7',
        HomeHorizon.d30 => '30',
        HomeHorizon.d90 => '90',
      };
      await prefs.setString(_horizonPrefKey, key);
    } catch (_) {}
  }
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final people = await _db.getPeople();
      final allDates = await _db.getSpecialDates();
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final todayBday = <TodayBirthdayItem>[];
      final todayIds = <int>{};
      final items = <UpcomingItem>[];
      for (final d in allDates) {
        final date = DateTime.parse(d.date);
        final person = people.firstWhereOrNull((p) => p.id == d.personId);
        if (person == null) continue;
        final isOneOffCustom = d.type == 'Custom' && !d.repeatYearly;
        int days;
        if (isOneOffCustom) {
          final target = DateTime(date.year, date.month, date.day);
          days = target.difference(todayNorm).inDays;
          if (days < 0 || days > 365) continue;
        } else {
          days = daysUntilNext(date.month, date.day);
          if (days > 365) continue;
        }
        final color = resolveAvatarColor(person.name, person.avatarPath);
        final letter = person.name.isNotEmpty ? person.name[0].toUpperCase() : '?';
        final prepMap = d.prepChecklistMap;
        final incomplete = prepIncompleteCount(prepMap);
        final typeName = eventDisplayName(d);
        final displayDate = isOneOffCustom
            ? formatDateDisplay(d.date)
            : formatDateDisplay(getDateString(todayNorm.add(Duration(days: days))));
        if (d.type == 'Birthday' && days == 0 && !todayIds.contains(person.id)) {
          todayIds.add(person.id!);
          final wishedFlag = prefs.getBool(wishedTodayKey(person.id!)) ?? false;
          todayBday.add(TodayBirthdayItem(
            id: person.id!,
            dateId: d.id!,
            name: person.name,
            relationship: person.relationship,
            avatarLetter: letter,
            avatarColor: color,
            avatarPath: person.avatarPath,
            age: calcAge(d.date),
            wishedToday: wishedFlag,
          ));
        }
        items.add(UpcomingItem(
          personId: person.id!,
          dateId: d.id!,
          personName: person.name,
          relationship: person.relationship,
          name: '${person.name} · $typeName',
          type: d.type,
          typeName: typeName,
          date: displayDate,
          countdown: formatCountdown(days, d.type),
          avatarLetter: letter,
          avatarColor: color,
          avatarPath: person.avatarPath,
          isToday: days == 0,
          isBirthday: d.type == 'Birthday',
          daysUntil: days,
          prepMap: prepMap,
          incompletePrepCount: incomplete,
        ));
      }
      items.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
      todayBirthdays.value = todayBday;
      upcomingItems.value = items;
      peopleCount.value = people.length;
    } catch (_) {
      errorToast('Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> onBirthdayAvatarTap(TodayBirthdayItem person) async {
    wishCardPerson.value = person;
    try {
      final raw = await _db.getWishTemplatesByCategory('Birthday');
      final ranked = rankBirthdayWishes(
        raw,
        relationship: person.relationship,
        age: person.age,
      );
      wishCardWishes.value = ranked;
      if (ranked.isEmpty) {
        errorToast('No wishes available');
        await Get.toNamed('/person/detail', arguments: {'id': person.id});
        await loadData();
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
        (wishCardIndex.value - 1 + wishCardWishes.length) % wishCardWishes.length;
  }
  Future<void> onWishCopy() async {
    if (wishCardWishes.isEmpty || wishCardPerson.value == null) return;
    copyToClipboard(currentWishPreview);
    await _markWished(wishCardPerson.value!.id);
  }
  Future<void> _markWished(int personId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(wishedTodayKey(personId), true);
      todayBirthdays.value = todayBirthdays
          .map((p) => p.id == personId
              ? TodayBirthdayItem(
                  id: p.id,
                  dateId: p.dateId,
                  name: p.name,
                  relationship: p.relationship,
                  avatarLetter: p.avatarLetter,
                  avatarColor: p.avatarColor,
                  avatarPath: p.avatarPath,
                  age: p.age,
                  wishedToday: true,
                )
              : p)
          .toList();
      if (wishCardPerson.value?.id == personId) {
        final p = wishCardPerson.value!;
        wishCardPerson.value = TodayBirthdayItem(
          id: p.id,
          dateId: p.dateId,
          name: p.name,
          relationship: p.relationship,
          avatarLetter: p.avatarLetter,
          avatarColor: p.avatarColor,
          avatarPath: p.avatarPath,
          age: p.age,
          wishedToday: true,
        );
      }
    } catch (_) {}
  }
  Future<void> onViewProfileTap() async {
    final person = wishCardPerson.value;
    wishCardVisible.value = false;
    if (person == null) return;
    await Get.toNamed('/person/detail', arguments: {'id': person.id});
    await loadData();
  }
  Future<void> onTodayWishTap() async {
    final p = soloTodayBirthday;
    if (p == null) return;
    await onBirthdayAvatarTap(p);
  }
  Future<void> onTodayGiftTap() async {
    final p = soloTodayBirthday;
    if (p == null) return;
    await Get.toNamed('/gift/add', arguments: {'personId': p.id});
    await loadData();
  }
  Future<void> onTodayCakeTap() async {
    final p = soloTodayBirthday;
    if (p == null) return;
    await Get.toNamed('/date/edit', arguments: {'id': p.dateId});
    await loadData();
  }
  Future<void> onWishCardGiftTap() async {
    final p = wishCardPerson.value;
    if (p == null) return;
    wishCardVisible.value = false;
    await Get.toNamed('/gift/add', arguments: {'personId': p.id});
    await loadData();
  }
  Future<void> onWishCardCakeTap() async {
    final p = wishCardPerson.value;
    if (p == null) return;
    wishCardVisible.value = false;
    await Get.toNamed('/date/edit', arguments: {'id': p.dateId});
    await loadData();
  }
  Future<void> onCareRadarTap(CareRadarItem item) async {
    final upcoming = upcomingItems.firstWhereOrNull((e) => e.dateId == item.dateId);
    if (upcoming != null) {
      openPrepSheet(upcoming);
    } else {
      await Get.toNamed('/person/detail', arguments: {'id': item.personId});
      await loadData();
    }
  }
  Future<void> onQuietDayTap() async {
    final next = quietDayNext;
    if (next == null) return;
    await Get.toNamed('/person/detail', arguments: {'id': next.personId});
    await loadData();
  }
  void openPrepSheet(UpcomingItem item) {
    prepSheetItem.value = item;
    prepSheetMap.assignAll(Map<String, bool>.from(item.prepMap));
    for (final k in prepChecklistKeys) {
      prepSheetMap.putIfAbsent(k, () => false);
    }
  }
  void closePrepSheet() {
    prepSheetItem.value = null;
    prepSheetMap.clear();
  }
  Future<void> onTogglePrep(String key, bool value) async {
    final item = prepSheetItem.value;
    if (item == null) return;
    prepSheetMap[key] = value;
    try {
      final sd = await _db.getSpecialDate(item.dateId);
      if (sd == null) return;
      final map = sd.prepChecklistMap;
      map[key] = value;
      final updated = SpecialDate(
        id: sd.id,
        personId: sd.personId,
        type: sd.type,
        customName: sd.customName,
        date: sd.date,
        repeatYearly: sd.repeatYearly,
        reminderDays: sd.reminderDays,
        reminderTime: sd.reminderTime,
        cakeReminderEnabled: sd.cakeReminderEnabled,
        cakeReminderDaysBefore: sd.cakeReminderDaysBefore,
        cakeReminderTime: sd.cakeReminderTime,
        flowerReminderEnabled: sd.flowerReminderEnabled,
        flowerReminderDaysBefore: sd.flowerReminderDaysBefore,
        flowerReminderTime: sd.flowerReminderTime,
        prepChecklist: jsonEncode(map),
        createdAt: sd.createdAt,
      );
      await _db.updateSpecialDate(updated);
      await loadData();
      final refreshed = upcomingItems.firstWhereOrNull((e) => e.dateId == item.dateId);
      if (refreshed != null) {
        prepSheetItem.value = refreshed;
        prepSheetMap.assignAll(Map<String, bool>.from(refreshed.prepMap));
      }
    } catch (_) {
      errorToast('Failed to update checklist');
      prepSheetMap[key] = !value;
    }
  }
  Future<void> onPrepActionTap(String key) async {
    final item = prepSheetItem.value;
    if (item == null) return;
    closePrepSheet();
    switch (key) {
      case 'gift':
        await Get.toNamed('/gift/add', arguments: {'personId': item.personId});
        break;
      case 'cake':
        await Get.toNamed('/date/edit', arguments: {'id': item.dateId});
        break;
      case 'flower':
        await Get.toNamed('/flower/add', arguments: {'personId': item.personId});
        break;
      case 'wish':
        await Get.toNamed('/wishes');
        break;
    }
    await loadData();
  }
  Future<void> onAddPersonTap() async {
    await Get.toNamed('/person/add');
    await loadData();
  }
  Future<void> onPeopleTap() async {
    await Get.toNamed('/people');
    await loadData();
  }
  Future<void> onUpcomingItemTap(int personId) async {
    await Get.toNamed('/person/detail', arguments: {'id': personId});
    await loadData();
  }
}
