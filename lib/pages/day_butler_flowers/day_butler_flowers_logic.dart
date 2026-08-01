import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
class FloristNote {
  final String shopName;
  final String? phone;
  final String? address;
  final String? notes;
  const FloristNote({
    required this.shopName,
    this.phone,
    this.address,
    this.notes,
  });
}
class UpcomingFlowerItem {
  final int personId;
  final String personName;
  final int occasionId;
  final String occasionLabel;
  final int daysUntil;
  final bool flowerReminderOn;
  const UpcomingFlowerItem({
    required this.personId,
    required this.personName,
    required this.occasionId,
    required this.occasionLabel,
    required this.daysUntil,
    required this.flowerReminderOn,
  });
}
class FlowerRhythmSummary {
  final int yearCount;
  final int monthCount;
  final String? lastDate;
  final int? daysSinceLast;
  final String? topFlower;
  final String? personName;
  final bool dueSoon;
  const FlowerRhythmSummary({
    required this.yearCount,
    required this.monthCount,
    this.lastDate,
    this.daysSinceLast,
    this.topFlower,
    this.personName,
    this.dueSoon = false,
  });
}
class DayButlerFlowersLogic extends GetxController {
  final _db = db;
  final currentTab = 0.obs;
  static const upcomingHorizonDays = 14;
  static const dueSoonDays = 90;
  final allFlowers = <FlowerLanguageItem>[].obs;
  final flowerFilter = 'All'.obs;
  final expandedFlowerId = RxnInt();
  final occasionOptions = [
    'All',
    'Anniversary',
    "Valentine's Day",
    'Apology',
    'Birthday',
    'Just Because',
  ];
  final allRecords = <FlowerRecord>[].obs;
  final allPeople = <Person>[].obs;
  final allDates = <SpecialDate>[].obs;
  final filterPersonId = RxnInt();
  final florist = Rxn<FloristNote>();
  final floristEditing = false.obs;
  final floristShopName = ''.obs;
  final floristPhone = ''.obs;
  final floristAddress = ''.obs;
  final floristNotes = ''.obs;
  final floristShopNameError = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  void onResumed() => loadData();
  Future<void> loadData() async {
    try {
      allFlowers.value = await _db.getFlowerLanguageItems();
      allPeople.value = await _db.getPeople();
      allRecords.value = await _db.getFlowerRecords();
      allDates.value = await _db.getSpecialDates();
      final pid = filterPersonId.value;
      if (pid != null && allPeople.every((p) => p.id != pid)) {
        filterPersonId.value = null;
      }
      await _loadFlorist();
    } catch (_) {
      errorToast('Failed to load data');
    }
  }
  List<FlowerLanguageItem> get filteredFlowers => flowerFilter.value == 'All'
      ? allFlowers.toList()
      : allFlowers
          .where((f) => f.occasionsList.contains(flowerFilter.value))
          .toList();
  void onFlowerFilterTap(String filter) =>
      flowerFilter.value = flowerFilter.value == filter ? 'All' : filter;
  void onFlowerCardTap(int id) =>
      expandedFlowerId.value = expandedFlowerId.value == id ? null : id;
  Future<void> onLogFromLanguageTap(FlowerLanguageItem item) async {
    await Get.toNamed(
      '/flower/add',
      arguments: {'prefillFlowers': item.name},
    );
    await loadData();
  }
  List<UpcomingFlowerItem> get upcomingFlowers {
    final items = <UpcomingFlowerItem>[];
    for (final d in allDates) {
      if (d.id == null) continue;
      final days = daysUntilSpecialDate(d);
      if (days < 0 || days > upcomingHorizonDays) continue;
      final person = allPeople.firstWhereOrNull((p) => p.id == d.personId);
      if (person?.id == null) continue;
      final alreadyLogged = allRecords.any((r) {
        if (r.occasionId == d.id) {
          final rd = DateTime.tryParse(r.date);
          if (rd == null) return false;
          final now = DateTime.now();
          return rd.year == now.year;
        }
        return false;
      });
      if (alreadyLogged) continue;
      items.add(
        UpcomingFlowerItem(
          personId: person!.id!,
          personName: person.name,
          occasionId: d.id!,
          occasionLabel: eventDisplayName(d),
          daysUntil: days,
          flowerReminderOn: d.flowerReminderEnabled,
        ),
      );
    }
    items.sort((a, b) {
      if (a.flowerReminderOn != b.flowerReminderOn) {
        return a.flowerReminderOn ? -1 : 1;
      }
      return a.daysUntil.compareTo(b.daysUntil);
    });
    return items.take(3).toList();
  }
  Future<void> onUpcomingLogTap(UpcomingFlowerItem item) async {
    await Get.toNamed(
      '/flower/add',
      arguments: {
        'personId': item.personId,
        'occasionId': item.occasionId,
      },
    );
    await loadData();
  }
  List<FlowerRecord> get filteredRecords {
    final list = filterPersonId.value == null
        ? allRecords.toList()
        : allRecords
            .where((r) => r.personId == filterPersonId.value)
            .toList();
    return list;
  }
  void onFilterPersonTap(int? id) =>
      filterPersonId.value = filterPersonId.value == id ? null : id;
  String personName(int personId) =>
      allPeople.firstWhereOrNull((p) => p.id == personId)?.name ?? 'Unknown';
  String flowerEmoji(String flowers) {
    final key = flowers.trim().toLowerCase();
    final match = allFlowers.firstWhereOrNull(
      (f) => key.contains(f.name.toLowerCase()),
    );
    return match?.emoji ?? '🌹';
  }
  String? duplicateHint(FlowerRecord record) {
    final key = record.flowers.trim().toLowerCase();
    if (key.isEmpty) return null;
    FlowerRecord? prev;
    for (final r in allRecords) {
      if (r.id == record.id) continue;
      if (r.personId != record.personId) continue;
      if (r.flowers.trim().toLowerCase() != key) continue;
      final rd = DateTime.tryParse(r.date);
      final cd = DateTime.tryParse(record.date);
      if (rd == null) continue;
      if (cd != null && !rd.isBefore(cd)) continue;
      if (prev == null ||
          (DateTime.tryParse(prev.date)?.isBefore(rd) ?? true)) {
        prev = r;
      }
    }
    if (prev == null) return null;
    final days = _daysBetween(prev.date, record.date);
    if (days == null) {
      return 'Same bouquet before · ${formatMonthDay(prev.date)}';
    }
    if (days < 60) return 'Same bouquet ${days}d ago';
    if (days < 370) return 'Same bouquet ${(days / 30).round()}mo ago';
    return 'Same bouquet before · ${formatMonthDay(prev.date)}';
  }
  FlowerRhythmSummary get rhythmSummary {
    final now = DateTime.now();
    final scope = filteredRecords;
    final yearCount = scope.where((r) {
      final d = DateTime.tryParse(r.date);
      return d != null && d.year == now.year;
    }).length;
    final monthCount = scope.where((r) {
      final d = DateTime.tryParse(r.date);
      return d != null && d.year == now.year && d.month == now.month;
    }).length;
    String? lastDate;
    int? daysSince;
    if (scope.isNotEmpty) {
      lastDate = scope.first.date;
      final last = DateTime.tryParse(scope.first.date);
      if (last != null) {
        final today = DateTime(now.year, now.month, now.day);
        final ld = DateTime(last.year, last.month, last.day);
        daysSince = today.difference(ld).inDays;
      }
    }
    final freq = <String, int>{};
    for (final r in scope) {
      final k = r.flowers.trim();
      if (k.isEmpty) continue;
      freq[k] = (freq[k] ?? 0) + 1;
    }
    String? top;
    var topN = 0;
    freq.forEach((k, v) {
      if (v > topN) {
        topN = v;
        top = k;
      }
    });
    final pid = filterPersonId.value;
    final pName = pid == null ? null : personName(pid);
    return FlowerRhythmSummary(
      yearCount: yearCount,
      monthCount: monthCount,
      lastDate: lastDate,
      daysSinceLast: daysSince,
      topFlower: top,
      personName: pName,
      dueSoon: daysSince != null && daysSince >= dueSoonDays,
    );
  }
  UpcomingFlowerItem? get nextFloristAction {
    final list = upcomingFlowers;
    if (list.isEmpty) return null;
    return list.first;
  }
  Future<void> onAddRecordTap() async {
    await Get.toNamed('/flower/add');
    await loadData();
  }
  Future<void> onEditRecordTap(int id) async {
    await Get.toNamed('/flower/edit', arguments: {'id': id});
    await loadData();
  }
  Future<void> onReorderTap(FlowerRecord record) async {
    await Get.toNamed(
      '/flower/add',
      arguments: {
        'personId': record.personId,
        'prefillFlowers': record.flowers,
        'occasionId': record.occasionId,
        'occasionNote': record.occasionNote,
        'notes': record.notes,
        'useToday': true,
      },
    );
    await loadData();
  }
  void onDeleteRecord(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Delete this flower record?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _db.deleteFlowerRecord(id);
                successToast('Record deleted');
                await loadData();
              } catch (_) {
                errorToast('Failed to delete');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> _loadFlorist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('florist_name');
      if (name != null && name.isNotEmpty) {
        florist.value = FloristNote(
          shopName: name,
          phone: prefs.getString('florist_phone'),
          address: prefs.getString('florist_address'),
          notes: prefs.getString('florist_notes'),
        );
      } else {
        florist.value = null;
      }
    } catch (_) {
      errorToast('Failed to load florist');
    }
  }
  void onAddFloristTap() {
    floristShopName.value = '';
    floristPhone.value = '';
    floristAddress.value = '';
    floristNotes.value = '';
    floristShopNameError.value = false;
    floristEditing.value = true;
  }
  void onEditFloristTap() {
    floristShopName.value = florist.value?.shopName ?? '';
    floristPhone.value = florist.value?.phone ?? '';
    floristAddress.value = florist.value?.address ?? '';
    floristNotes.value = florist.value?.notes ?? '';
    floristShopNameError.value = false;
    floristEditing.value = true;
  }
  void onCancelFloristEdit() => floristEditing.value = false;
  Future<void> onSaveFlorist() async {
    if (floristShopName.value.trim().isEmpty) {
      floristShopNameError.value = true;
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('florist_name', floristShopName.value.trim());
      await prefs.setString('florist_phone', floristPhone.value.trim());
      await prefs.setString('florist_address', floristAddress.value.trim());
      await prefs.setString('florist_notes', floristNotes.value.trim());
      floristEditing.value = false;
      await _loadFlorist();
      successToast('Florist saved');
    } catch (_) {
      errorToast('Failed to save florist');
    }
  }
  void onDeleteFlorist() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Florist'),
        content: const Text('Remove this florist from your saved details?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('florist_name');
                await prefs.remove('florist_phone');
                await prefs.remove('florist_address');
                await prefs.remove('florist_notes');
                florist.value = null;
                floristEditing.value = false;
                successToast('Florist deleted');
              } catch (_) {
                errorToast('Failed to delete florist');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> onCallTap() async {
    final phone = florist.value?.phone;
    if (phone == null || phone.isEmpty) return;
    try {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        errorToast('Unable to make call');
      }
    } catch (_) {
      errorToast('Unable to make call');
    }
  }
  Future<void> onAddressTap() async {
    final address = florist.value?.address;
    if (address == null || address.isEmpty) return;
    try {
      final uri = Uri.parse(
        'https://maps.apple.com/?q=${Uri.encodeComponent(address)}',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        errorToast('Could not open maps');
      }
    } catch (_) {
      errorToast('Could not open maps');
    }
  }
  Future<void> onFloristLogTap() async {
    final next = nextFloristAction;
    await Get.toNamed(
      '/flower/add',
      arguments: {
        if (next != null) 'personId': next.personId,
        if (next != null) 'occasionId': next.occasionId,
      },
    );
    await loadData();
  }
  void onTabSwitch(int index) => currentTab.value = index;
  int? _daysBetween(String from, String to) {
    try {
      final a = DateTime.parse(from);
      final b = DateTime.parse(to);
      final an = DateTime(a.year, a.month, a.day);
      final bn = DateTime(b.year, b.month, b.day);
      return bn.difference(an).inDays;
    } catch (_) {
      return null;
    }
  }
}
