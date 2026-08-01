import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_day_butler/index.dart';
import '../../services/notification_service.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
import '../day_butler_gifts/day_butler_gifts_logic.dart';
enum NextActionKind { addDate, openPrep, addGift, editDate, viewGifts }
class NextAction {
  final String title;
  final String subtitle;
  final NextActionKind kind;
  final int? dateId;
  final IconData icon;
  const NextAction({
    required this.title,
    required this.subtitle,
    required this.kind,
    this.dateId,
    required this.icon,
  });
}
class SpecialDateItem {
  final int id;
  final String icon;
  final String typeName;
  final String date;
  final String countdown;
  final int daysUntil;
  final bool hasAlert;
  final int prepDone;
  final int prepTotal;
  final Map<String, bool> prepMap;
  final SpecialDate raw;
  const SpecialDateItem({
    required this.id,
    required this.icon,
    required this.typeName,
    required this.date,
    required this.countdown,
    required this.daysUntil,
    required this.hasAlert,
    required this.prepDone,
    required this.prepTotal,
    required this.prepMap,
    required this.raw,
  });
}
class GiftItem {
  final int id;
  final String name;
  final String priceDisplay;
  final String status;
  final int dotColor;
  const GiftItem({
    required this.id,
    required this.name,
    required this.priceDisplay,
    required this.status,
    required this.dotColor,
  });
}
class PastGiftItem {
  final int id;
  final String name;
  final String priceDisplay;
  final String dateLabel;
  final String? reaction;
  const PastGiftItem({
    required this.id,
    required this.name,
    required this.priceDisplay,
    required this.dateLabel,
    this.reaction,
  });
}
class DayButlerContactDetailLogic extends GetxController {
  final _db = db;
  final _notif = NotificationService();
  final personId = 0.obs;
  final name = ''.obs;
  final relationship = ''.obs;
  final notes = ''.obs;
  final avatarLetter = ''.obs;
  final avatarColor = 0.obs;
  final avatarPath = Rx<String?>(null);
  final age = ''.obs;
  final zodiac = ''.obs;
  final chineseZodiac = ''.obs;
  final showFunInfo = false.obs;
  final anniversaryStory = ''.obs;
  final budgetUsed = 0.0.obs;
  final budgetTotal = Rx<double?>(null);
  final specialDates = <SpecialDateItem>[].obs;
  final gifts = <GiftItem>[].obs;
  final pastGifts = <PastGiftItem>[].obs;
  final totalGiftCount = 0.obs;
  final nextAction = Rx<NextAction?>(null);
  final prepSheetItem = Rx<SpecialDateItem?>(null);
  final prepSheetMap = <String, bool>{}.obs;
  List<Gift> _giftListCache = [];
  Color get budgetBarColor {
    final total = budgetTotal.value;
    if (total == null || total <= 0) return const Color(0xFF5B9BD5);
    final used = budgetUsed.value;
    if (used > total) return const Color(0xFFE74C3C);
    final remaining = (total - used) / total;
    if (remaining >= 0.5) return const Color(0xFF2EAD6C);
    if (remaining < 0.3) return const Color(0xFFF39C12);
    return const Color(0xFF5B9BD5);
  }
  Color get budgetLabelColor => budgetBarColor;
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['id'] != null) {
      personId.value = args['id'] as int;
      loadData();
    }
  }
  void onResumed() => loadData();
  Future<void> loadData() async {
    try {
      final person = await _db.getPerson(personId.value);
      if (person == null) return;
      name.value = person.name;
      relationship.value = person.relationship;
      notes.value = person.notes ?? '';
      avatarLetter.value =
          person.name.isNotEmpty ? person.name[0].toUpperCase() : '?';
      avatarPath.value = person.avatarPath;
      avatarColor.value = resolveAvatarColor(person.name, person.avatarPath);
      budgetTotal.value = person.annualGiftBudget;
      var dates = await _db.getSpecialDatesByPersonId(personId.value);
      dates = await _resetPrepIfNeeded(dates);
      final giftList = await _db.getGiftsByPersonId(personId.value);
      _giftListCache = giftList;
      _loadFunInfo(dates);
      _loadAnniversaryStory(dates);
      _loadSpecialDates(dates, giftList);
      _loadGifts(giftList);
      _loadPastGifts(giftList);
      _calcBudget(giftList, person.annualGiftBudget);
      _computeNextAction();
      final openId = prepSheetItem.value?.id;
      if (openId != null) {
        final refreshed =
            specialDates.firstWhereOrNull((e) => e.id == openId);
        if (refreshed != null) prepSheetItem.value = refreshed;
      }
    } catch (e) {
      errorToast('Failed to load contact');
    }
  }
  void _loadFunInfo(List<SpecialDate> dates) {
    final birthday = dates.firstWhereOrNull((d) => d.type == 'Birthday');
    if (birthday == null) {
      showFunInfo.value = false;
      return;
    }
    try {
      final bDate = DateTime.parse(birthday.date);
      final today = DateTime.now();
      final birthDay = DateTime(bDate.year, bDate.month, bDate.day);
      final todayNorm = DateTime(today.year, today.month, today.day);
      if (birthDay.isAfter(todayNorm)) {
        showFunInfo.value = false;
        return;
      }
      final ageVal = calcAge(birthday.date);
      if (ageVal != null) {
        final birthdayPassed = today.month > bDate.month ||
            (today.month == bDate.month && today.day >= bDate.day);
        age.value = birthdayPassed
            ? '$ageVal years old'
            : 'Turns $ageVal this year';
        zodiac.value = calcZodiac(bDate.month, bDate.day);
        chineseZodiac.value = calcChineseZodiac(bDate.year);
        showFunInfo.value = true;
      } else {
        showFunInfo.value = false;
      }
    } catch (_) {
      showFunInfo.value = false;
    }
  }
  void _loadAnniversaryStory(List<SpecialDate> dates) {
    final ann = dates.firstWhereOrNull((d) => d.type == 'Anniversary');
    if (ann == null) {
      anniversaryStory.value = '';
      return;
    }
    try {
      final start = DateTime.parse(ann.date);
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final startDay = DateTime(start.year, start.month, start.day);
      if (startDay.isAfter(todayNorm)) {
        anniversaryStory.value = '';
        return;
      }
      var years = today.year - start.year;
      final thisYearMark =
          DateTime(today.year, start.month, start.day);
      if (thisYearMark.isAfter(todayNorm)) years -= 1;
      if (years < 0) years = 0;
      final days = daysUntilSpecialDate(ann);
      final when = days < 0
          ? 'Passed'
          : days == 0
              ? 'Today'
              : formatCountdown(days, ann.type);
      if (years <= 0) {
        anniversaryStory.value = 'First anniversary · $when';
      } else {
        anniversaryStory.value =
            'Together $years ${years == 1 ? 'year' : 'years'} · $when';
      }
    } catch (_) {
      anniversaryStory.value = '';
    }
  }
  void _loadSpecialDates(List<SpecialDate> dates, List<Gift> giftList) {
    final items = <SpecialDateItem>[];
    for (final d in dates) {
      final days = daysUntilSpecialDate(d);
      if (d.type == 'Custom' && !d.repeatYearly && days < 0) continue;
      final countdown = days < 0 ? 'Passed' : formatCountdown(days, d.type);
      final prepMap = _effectivePrepMap(d, giftList);
      final incomplete = prepIncompleteCount(prepMap);
      final done = prepChecklistKeys.length - incomplete;
      final hasAlert = days >= 0 && days <= 30 && incomplete > 0;
      items.add(SpecialDateItem(
        id: d.id!,
        icon: eventTypeIcon(d.type),
        typeName: eventDisplayName(d),
        date: formatMonthDay(d.date),
        countdown: countdown,
        daysUntil: days,
        hasAlert: hasAlert,
        prepDone: done,
        prepTotal: prepChecklistKeys.length,
        prepMap: prepMap,
        raw: d,
      ));
    }
    items.sort((a, b) {
      final da = a.daysUntil;
      final db2 = b.daysUntil;
      if (da < 0 && db2 >= 0) return 1;
      if (da >= 0 && db2 < 0) return -1;
      return da.compareTo(db2);
    });
    specialDates.value = items;
  }
  void _loadGifts(List<Gift> giftList) {
    final active = giftList
        .where((g) => g.status == 'Idea' || g.status == 'Purchased')
        .toList();
    active.sort((a, b) {
      const order = {'Idea': 0, 'Purchased': 1, 'Gifted': 2};
      return (order[a.status] ?? 3).compareTo(order[b.status] ?? 3);
    });
    gifts.value = active.take(3).map((g) {
      int dotColor;
      switch (g.status) {
        case 'Purchased':
          dotColor = 0xFF5B9BD5;
          break;
        case 'Gifted':
          dotColor = 0xFF2EAD6C;
          break;
        default:
          dotColor = 0xFFF39C12;
      }
      final priceStr =
          g.price != null ? '\$${g.price!.toStringAsFixed(2)}' : 'No price';
      return GiftItem(
        id: g.id!,
        name: g.name,
        priceDisplay: priceStr,
        status: g.status,
        dotColor: dotColor,
      );
    }).toList();
    totalGiftCount.value = active.length;
  }
  void _loadPastGifts(List<Gift> giftList) {
    final gifted = giftList.where((g) => g.status == 'Gifted').toList();
    gifted.sort((a, b) {
      final da = a.giftedDate ?? a.createdAt;
      final db = b.giftedDate ?? b.createdAt;
      return db.compareTo(da);
    });
    pastGifts.value = gifted.take(3).map((g) {
      final dateStr = g.giftedDate ?? g.createdAt;
      String label;
      try {
        label = formatDateDisplay(extractDateFromDateTime(dateStr));
      } catch (_) {
        label = dateStr;
      }
      final priceStr =
          g.price != null ? '\$${g.price!.toStringAsFixed(2)}' : 'No price';
      return PastGiftItem(
        id: g.id!,
        name: g.name,
        priceDisplay: priceStr,
        dateLabel: label,
        reaction: g.reaction,
      );
    }).toList();
  }
  void _calcBudget(List<Gift> giftList, double? budget) {
    if (budget == null) {
      budgetUsed.value = 0;
      return;
    }
    final year = DateTime.now().year;
    double spent = 0;
    for (final g in giftList) {
      if (g.price == null) continue;
      if (g.status != 'Purchased' && g.status != 'Gifted') continue;
      final dateStr = g.giftedDate ?? g.createdAt;
      try {
        final d = DateTime.parse(dateStr);
        if (d.year == year) spent += g.price!;
      } catch (_) {}
    }
    budgetUsed.value = spent;
  }
  void _computeNextAction() {
    if (specialDates.isEmpty) {
      nextAction.value = NextAction(
        title: 'Add a special date',
        subtitle: 'Set a birthday or anniversary to get reminders',
        kind: NextActionKind.addDate,
        icon: Icons.event_available_rounded,
      );
      return;
    }
    final upcoming = specialDates.where((d) => d.daysUntil >= 0).toList();
    if (upcoming.isEmpty) {
      nextAction.value = null;
      return;
    }
    final next = upcoming.first;
    final incomplete = prepIncompleteCount(next.prepMap);
    final hasActiveGift = _giftListCache.any(
      (g) => g.status == 'Idea' || g.status == 'Purchased',
    );
    if (next.daysUntil <= 30 && incomplete > 0) {
      nextAction.value = NextAction(
        title: 'Finish prep · ${next.typeName}',
        subtitle: '$incomplete left · ${next.countdown}',
        kind: NextActionKind.openPrep,
        dateId: next.id,
        icon: Icons.checklist_rounded,
      );
      return;
    }
    if (next.daysUntil <= 30 && !hasActiveGift) {
      nextAction.value = NextAction(
        title: 'Pick a gift',
        subtitle: '${next.typeName} · ${next.countdown}',
        kind: NextActionKind.addGift,
        dateId: next.id,
        icon: Icons.card_giftcard_rounded,
      );
      return;
    }
    if (next.daysUntil <= 30 &&
        _giftListCache.any((g) => g.status == 'Idea')) {
      nextAction.value = NextAction(
        title: 'Review gift ideas',
        subtitle: '${next.typeName} · ${next.countdown}',
        kind: NextActionKind.viewGifts,
        icon: Icons.shopping_bag_outlined,
      );
      return;
    }
    if (next.daysUntil <= 30) {
      nextAction.value = NextAction(
        title: 'Coming up · ${next.typeName}',
        subtitle: '${next.countdown} · All set for now',
        kind: NextActionKind.editDate,
        dateId: next.id,
        icon: Icons.celebration_outlined,
      );
      return;
    }
    nextAction.value = NextAction(
      title: 'Next · ${next.typeName}',
      subtitle: next.countdown,
      kind: NextActionKind.editDate,
      dateId: next.id,
      icon: Icons.schedule_rounded,
    );
  }
  Future<void> onNextActionTap() async {
    final action = nextAction.value;
    if (action == null) return;
    switch (action.kind) {
      case NextActionKind.addDate:
        await onAddDateTap();
        break;
      case NextActionKind.openPrep:
        final item =
            specialDates.firstWhereOrNull((e) => e.id == action.dateId);
        if (item != null) openPrepSheet(item);
        break;
      case NextActionKind.addGift:
        await onAddGiftTap();
        break;
      case NextActionKind.editDate:
        if (action.dateId != null) await onDateItemTap(action.dateId!);
        break;
      case NextActionKind.viewGifts:
        await onViewAllGiftsTap();
        break;
    }
  }
  Future<void> onAddGiftTap() async {
    final total = budgetTotal.value;
    if (total != null && budgetUsed.value > total) {
      errorToast('Over budget — consider a smaller gift');
    } else if (total != null && total > 0) {
      final remaining = (total - budgetUsed.value) / total;
      if (remaining < 0.3 && budgetUsed.value <= total) {
        errorToast('Budget almost used — \$${(total - budgetUsed.value).toStringAsFixed(0)} left');
      }
    }
    await Get.toNamed(
      '/gift/add',
      arguments: {'personId': personId.value},
    );
    await loadData();
  }
  void onShareTap() {
    final lines = <String>[
      name.value,
      if (relationship.value.isNotEmpty) 'Relationship: ${relationship.value}',
    ];
    final upcoming =
        specialDates.where((d) => d.daysUntil >= 0).toList();
    if (upcoming.isNotEmpty) {
      final n = upcoming.first;
      lines.add('Next: ${n.typeName} · ${n.countdown}');
      lines.add('Prep: ${n.prepDone}/${n.prepTotal}');
    } else {
      lines.add('Next: No upcoming dates');
    }
    if (anniversaryStory.value.isNotEmpty) {
      lines.add(anniversaryStory.value);
    }
    final total = budgetTotal.value;
    if (total != null) {
      lines.add(
        'Budget: \$${budgetUsed.value.toStringAsFixed(0)} / \$${total.toStringAsFixed(0)}',
      );
    }
    lines.add('');
    lines.add('Shared from Birthday Butler');
    copyToClipboard(lines.join('\n'));
  }
  void onCopyAnniversaryTap() {
    if (anniversaryStory.value.isEmpty) return;
    copyToClipboard('${name.value} · ${anniversaryStory.value}');
  }
  bool _shouldResetPrep(SpecialDate d) {
    if (d.type == 'Custom' && !d.repeatYearly) return false;
    try {
      final eventDate = DateTime.parse(d.date);
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final thisYearEvent =
          DateTime(today.year, eventDate.month, eventDate.day);
      return todayNorm.isAfter(thisYearEvent);
    } catch (_) {
      return false;
    }
  }
  bool _hasAnyPrepChecked(Map<String, bool> map) =>
      prepChecklistKeys.any((k) => map[k] == true);
  Future<List<SpecialDate>> _resetPrepIfNeeded(List<SpecialDate> dates) async {
    final result = <SpecialDate>[];
    for (var d in dates) {
      final map = d.prepChecklistMap;
      if (_shouldResetPrep(d) && _hasAnyPrepChecked(map)) {
        final empty = {for (final k in prepChecklistKeys) k: false};
        final updated = _copySpecialDate(d, prepChecklist: jsonEncode(empty));
        try {
          await _db.updateSpecialDate(updated);
          d = updated;
        } catch (_) {}
      }
      result.add(d);
    }
    return result;
  }
  Map<String, bool> _effectivePrepMap(SpecialDate d, List<Gift> giftList) {
    final map = Map<String, bool>.from(d.prepChecklistMap);
    for (final k in prepChecklistKeys) {
      map.putIfAbsent(k, () => false);
    }
    if (giftList.any((g) => g.status == 'Purchased' || g.status == 'Gifted')) {
      map['gift'] = true;
    }
    return map;
  }
  SpecialDate _copySpecialDate(SpecialDate sd, {required String prepChecklist}) {
    return SpecialDate(
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
      prepChecklist: prepChecklist,
      createdAt: sd.createdAt,
    );
  }
  void openPrepSheet(SpecialDateItem item) {
    prepSheetItem.value = item;
    prepSheetMap.assignAll(_effectivePrepMap(item.raw, _giftListCache));
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
      final sd = await _db.getSpecialDate(item.id);
      if (sd == null) return;
      final map = sd.prepChecklistMap;
      for (final k in prepChecklistKeys) {
        map.putIfAbsent(k, () => false);
      }
      map[key] = value;
      await _db.updateSpecialDate(
        _copySpecialDate(sd, prepChecklist: jsonEncode(map)),
      );
      final sheetSnapshot = Map<String, bool>.from(prepSheetMap);
      await loadData();
      prepSheetMap.assignAll(sheetSnapshot);
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
        await Get.toNamed(
          '/gift/add',
          arguments: {'personId': personId.value},
        );
        break;
      case 'cake':
        await Get.toNamed(
          '/date/edit',
          arguments: {'id': item.id, 'personId': personId.value},
        );
        break;
      case 'flower':
        await Get.toNamed(
          '/flower/add',
          arguments: {
            'personId': personId.value,
            'occasionId': item.id,
          },
        );
        break;
      case 'wish':
        await Get.toNamed('/wishes');
        break;
    }
    await loadData();
  }
  Future<void> onEditTap() async {
    await Get.toNamed('/person/edit', arguments: {'id': personId.value});
    await loadData();
  }
  Future<void> onAddDateTap() async {
    await Get.toNamed(
      '/date/add',
      arguments: {'personId': personId.value},
    );
    await loadData();
  }
  Future<void> onViewAllGiftsTap() async {
    if (Get.isRegistered<DayButlerGiftsLogic>()) {
      final giftsLogic = Get.find<DayButlerGiftsLogic>();
      giftsLogic.applyPersonFilter(personId.value);
      await giftsLogic.loadData();
    }
    await Get.toNamed(
      '/gifts',
      arguments: {'personId': personId.value},
    );
    await loadData();
  }
  Future<void> onDateItemTap(int dateId) async {
    await Get.toNamed(
      '/date/edit',
      arguments: {'id': dateId, 'personId': personId.value},
    );
    await loadData();
  }
  Future<void> onGiftTap(int giftId) async {
    await Get.toNamed('/gift/edit', arguments: {'id': giftId});
    await loadData();
  }
  Future<void> onPastGiftTap(int giftId) async {
    await onGiftTap(giftId);
  }
  void onDeleteDateTap(int dateId, String eventName) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Date'),
      content: Text('Delete "$eventName"? This will also cancel its reminders.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Get.back();
            await _confirmDeleteDate(dateId);
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Color(0xFFE74C3C)),
          ),
        ),
      ],
    ));
  }
  Future<void> _confirmDeleteDate(int dateId) async {
    try {
      await _notif.cancelAllForDate(dateId);
      await _db.deleteSpecialDate(dateId);
      successToast('Date deleted');
      await loadData();
    } catch (e) {
      errorToast('Failed to delete date');
    }
  }
}
