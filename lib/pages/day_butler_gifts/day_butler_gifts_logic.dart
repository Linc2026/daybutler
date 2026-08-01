import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
import 'day_butler_gifts_widgets.dart';
class GiftGroupItem {
  final int personId;
  final String personName;
  final String avatarLetter;
  final int avatarColor;
  final String? avatarPath;
  final double? budget;
  final double budgetUsed;
  final int daysUntilNext;
  final List<GiftRowItem> gifts;
  const GiftGroupItem({
    required this.personId,
    required this.personName,
    required this.avatarLetter,
    required this.avatarColor,
    this.avatarPath,
    this.budget,
    required this.budgetUsed,
    required this.daysUntilNext,
    required this.gifts,
  });
  bool get isOverBudget => budget != null && budgetUsed > budget!;
  double get budgetProgress {
    if (budget == null || budget! <= 0) return 0;
    return (budgetUsed / budget!).clamp(0.0, 1.0);
  }
}
class GiftRowItem {
  final Gift gift;
  final String? occasionLabel;
  final String? duplicateHint;
  const GiftRowItem({
    required this.gift,
    this.occasionLabel,
    this.duplicateHint,
  });
}
class OccasionGapItem {
  final int personId;
  final String personName;
  final String avatarLetter;
  final int avatarColor;
  final String? avatarPath;
  final int occasionId;
  final String occasionLabel;
  final int daysUntil;
  const OccasionGapItem({
    required this.personId,
    required this.personName,
    required this.avatarLetter,
    required this.avatarColor,
    this.avatarPath,
    required this.occasionId,
    required this.occasionLabel,
    required this.daysUntil,
  });
}
class SmartGuideHint {
  final String personName;
  final String? forTag;
  final String? occasionTag;
  const SmartGuideHint({
    required this.personName,
    this.forTag,
    this.occasionTag,
  });
  String get label {
    final parts = <String>['For $personName'];
    if (occasionTag != null) parts.add(occasionTag!);
    return parts.join(' · ');
  }
}
class DayButlerGiftsLogic extends GetxController {
  final _db = db;
  final currentTab = 0.obs;
  final allGifts = <Gift>[].obs;
  final allPeople = <Person>[].obs;
  final allDates = <SpecialDate>[].obs;
  final filterPersonId = Rx<int?>(null);
  final filterStatus = 'All'.obs;
  final statusOptions = ['All', 'Idea', 'Purchased', 'Gifted'];
  static const gapHorizonDays = 14;
  final guideItems = <GuideItem>[].obs;
  final guideFilterFor = 'All'.obs;
  final guideFilterOccasion = 'All'.obs;
  final guideFilterBudget = 'All'.obs;
  final smartGuideHint = Rxn<SmartGuideHint>();
  final smartGuideDismissed = false.obs;
  final guideForOptions = [
    'All',
    'Partner',
    'Mom',
    'Dad',
    'Best Friend',
    'Friend',
    'Colleague',
  ];
  final guideOccasionOptions = [
    'All',
    'Birthday',
    'Anniversary',
    "Valentine's Day",
    'Christmas',
    'General',
  ];
  final guideBudgetOptions = ['All', 'Under \$30', '\$30–\$100', 'Over \$100'];
  @override
  void onInit() {
    super.onInit();
    applyRouteArgs();
    loadData();
  }
  void onResumed() => loadData();
  void applyPersonFilter(int? personId) {
    filterPersonId.value = personId;
  }
  void applyRouteArgs([Map<String, dynamic>? args]) {
    final a = args ?? Get.arguments as Map<String, dynamic>?;
    if (a != null && a['personId'] != null) {
      filterPersonId.value = a['personId'] as int;
    }
  }
  Future<void> loadData() async {
    try {
      allPeople.value = await _db.getPeople();
      allGifts.value = await _db.getGifts();
      allDates.value = await _db.getSpecialDates();
      final rawGuide = await _db.getGiftGuideItems();
      guideItems.value = rawGuide
          .map((g) => GuideItem(raw: g, added: _isGuideAdded(g.name)))
          .toList();
      _refreshSmartGuideHint();
    } catch (e) {
      errorToast('Failed to load gifts');
    }
  }
  bool _isGuideAdded(String guideName) {
    final key = guideName.trim().toLowerCase();
    return allGifts.any((g) => g.name.trim().toLowerCase() == key);
  }
  bool get hasAnyGifts => allGifts.isNotEmpty;
  bool get showGroupHeaders => filterPersonId.value == null;
  GiftGroupItem? get filteredPersonBudget {
    final pid = filterPersonId.value;
    if (pid == null) return null;
    final person = allPeople.firstWhereOrNull((p) => p.id == pid);
    if (person == null) return null;
    return GiftGroupItem(
      personId: person.id!,
      personName: person.name,
      avatarLetter: person.name[0].toUpperCase(),
      avatarColor: resolveAvatarColor(person.name, person.avatarPath),
      avatarPath: person.avatarPath,
      budget: person.annualGiftBudget,
      budgetUsed: _yearSpentForPerson(person.id!),
      daysUntilNext: _nearestDaysForPerson(person.id!),
      gifts: const [],
    );
  }
  List<GiftGroupItem> get plannerGroups {
    final filtered = allGifts.where((g) {
      final personMatch =
          filterPersonId.value == null || g.personId == filterPersonId.value;
      final statusMatch =
          filterStatus.value == 'All' || g.status == filterStatus.value;
      return personMatch && statusMatch;
    }).toList();
    final Map<int, List<Gift>> byPerson = {};
    for (final g in filtered) {
      byPerson.putIfAbsent(g.personId, () => []).add(g);
    }
    final groups = <GiftGroupItem>[];
    for (final entry in byPerson.entries) {
      final person = allPeople.firstWhereOrNull((p) => p.id == entry.key);
      if (person == null) continue;
      groups.add(
        GiftGroupItem(
          personId: person.id!,
          personName: person.name,
          avatarLetter: person.name[0].toUpperCase(),
          avatarColor: resolveAvatarColor(person.name, person.avatarPath),
          avatarPath: person.avatarPath,
          budget: person.annualGiftBudget,
          budgetUsed: _yearSpentForPerson(person.id!),
          daysUntilNext: _nearestDaysForPerson(person.id!),
          gifts: _buildRows(entry.value),
        ),
      );
    }
    groups.sort((a, b) {
      final da = a.daysUntilNext < 0 ? 99999 : a.daysUntilNext;
      final db = b.daysUntilNext < 0 ? 99999 : b.daysUntilNext;
      return da.compareTo(db);
    });
    return groups;
  }
  double _yearSpentForPerson(int personId) {
    final year = DateTime.now().year;
    var spent = 0.0;
    for (final g in allGifts) {
      if (g.personId != personId) continue;
      if (g.price == null) continue;
      if (g.status != 'Purchased' && g.status != 'Gifted') continue;
      final ds = g.giftedDate ?? g.createdAt;
      try {
        if (DateTime.parse(ds).year == year) spent += g.price!;
      } catch (_) {}
    }
    return spent;
  }
  int _nearestDaysForPerson(int personId) {
    var best = 99999;
    for (final d in allDates) {
      if (d.personId != personId) continue;
      final days = daysUntilSpecialDate(d);
      if (days < 0) continue;
      if (days < best) best = days;
    }
    return best == 99999 ? -1 : best;
  }
  List<GiftRowItem> _buildRows(List<Gift> gifts) {
    return _sortGifts(gifts).map((g) {
      return GiftRowItem(
        gift: g,
        occasionLabel: _occasionLabel(g.occasionId),
        duplicateHint: _duplicateHint(g),
      );
    }).toList();
  }
  String? _occasionLabel(int? occasionId) {
    if (occasionId == null) return null;
    final sd = allDates.firstWhereOrNull((d) => d.id == occasionId);
    if (sd == null) return null;
    final name = eventDisplayName(sd);
    final md = formatMonthDay(sd.date);
    return 'For $name · $md';
  }
  String? _duplicateHint(Gift gift) {
    if (gift.status == 'Gifted') return null;
    final key = gift.name.trim().toLowerCase();
    final past = allGifts.where((g) {
      if (g.id == gift.id) return false;
      if (g.personId != gift.personId) return false;
      if (g.status != 'Gifted') return false;
      return g.name.trim().toLowerCase() == key;
    }).toList();
    if (past.isEmpty) return null;
    past.sort((a, b) {
      final da = a.giftedDate ?? a.createdAt;
      final db = b.giftedDate ?? b.createdAt;
      try {
        return DateTime.parse(db).compareTo(DateTime.parse(da));
      } catch (_) {
        return 0;
      }
    });
    final p = past.first;
    final when = formatMonthDay(p.giftedDate ?? p.createdAt);
    final year = () {
      try {
        return DateTime.parse(p.giftedDate ?? p.createdAt).year.toString();
      } catch (_) {
        return '';
      }
    }();
    final emoji = _reactionEmoji(p.reaction);
    final suffix = emoji.isEmpty ? '' : ' $emoji';
    return 'Previously gifted $when $year$suffix'.trim();
  }
  String _reactionEmoji(String? reaction) {
    switch (reaction) {
      case 'loved':
        return '😍';
      case 'liked':
        return '😊';
      case 'okay':
        return '😐';
      case 'miss':
        return '😕';
      default:
        return '';
    }
  }
  List<Gift> _sortGifts(List<Gift> gifts) {
    const order = {'Idea': 0, 'Purchased': 1, 'Gifted': 2};
    final copy = [...gifts];
    copy.sort((a, b) {
      final diff = (order[a.status] ?? 3) - (order[b.status] ?? 3);
      if (diff != 0) return diff;
      if (a.status == 'Gifted') {
        final da = a.giftedDate ?? a.createdAt;
        final db = b.giftedDate ?? b.createdAt;
        try {
          return DateTime.parse(db).compareTo(DateTime.parse(da));
        } catch (_) {
          return 0;
        }
      }
      try {
        return DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt));
      } catch (_) {
        return 0;
      }
    });
    return copy;
  }
  List<OccasionGapItem> get occasionGaps {
    final gaps = <OccasionGapItem>[];
    for (final person in allPeople) {
      if (person.id == null) continue;
      if (filterPersonId.value != null && filterPersonId.value != person.id) {
        continue;
      }
      final hasActive = allGifts.any(
        (g) =>
            g.personId == person.id &&
            (g.status == 'Idea' || g.status == 'Purchased'),
      );
      if (hasActive) continue;
      SpecialDate? nearest;
      var bestDays = gapHorizonDays + 1;
      for (final d in allDates) {
        if (d.personId != person.id) continue;
        final days = daysUntilSpecialDate(d);
        if (days < 0 || days > gapHorizonDays) continue;
        if (days < bestDays) {
          bestDays = days;
          nearest = d;
        }
      }
      if (nearest?.id == null) continue;
      gaps.add(
        OccasionGapItem(
          personId: person.id!,
          personName: person.name,
          avatarLetter: person.name[0].toUpperCase(),
          avatarColor: resolveAvatarColor(person.name, person.avatarPath),
          avatarPath: person.avatarPath,
          occasionId: nearest!.id!,
          occasionLabel: eventDisplayName(nearest),
          daysUntil: bestDays,
        ),
      );
    }
    gaps.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return gaps.take(3).toList();
  }
  void setFilterPerson(int? id) => filterPersonId.value = id;
  void onFilterPersonTap(int? id) {
    filterPersonId.value = filterPersonId.value == id ? null : id;
  }
  void setFilterStatus(String s) => filterStatus.value = s;
  Future<void> onOpenLink(String? link) async {
    if (link == null || link.isEmpty) return;
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        errorToast('Could not open link');
      }
    } catch (_) {
      errorToast('Could not open link');
    }
  }
  Future<void> onMarkPurchased(int giftId) async {
    try {
      final g = await _db.getGift(giftId);
      if (g == null) return;
      await _db.updateGift(
        Gift(
          id: g.id,
          personId: g.personId,
          name: g.name,
          price: g.price,
          status: 'Purchased',
          occasionId: g.occasionId,
          link: g.link,
          notes: g.notes,
          giftedDate: g.giftedDate,
          reaction: g.reaction,
          createdAt: g.createdAt,
        ),
      );
      successToast('Marked as Purchased');
      await loadData();
    } catch (_) {
      errorToast('Failed to update');
    }
  }
  Future<void> onMarkGifted(int giftId) async {
    final reaction = await _showReactionDialog();
    try {
      final g = await _db.getGift(giftId);
      if (g == null) return;
      final today = getDateString(DateTime.now());
      await _db.updateGift(
        Gift(
          id: g.id,
          personId: g.personId,
          name: g.name,
          price: g.price,
          status: 'Gifted',
          occasionId: g.occasionId,
          link: g.link,
          notes: g.notes,
          giftedDate: today,
          reaction: reaction,
          createdAt: g.createdAt,
        ),
      );
      successToast('Marked as Gifted 🎁');
      await loadData();
    } catch (_) {
      errorToast('Failed to update');
    }
  }
  Future<String?> _showReactionDialog() async {
    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('How did they like it?'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _reactionBtn('😍', 'loved'),
            _reactionBtn('😊', 'liked'),
            _reactionBtn('😐', 'okay'),
            _reactionBtn('😕', 'miss'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Skip')),
        ],
      ),
    );
  }
  Widget _reactionBtn(String emoji, String val) => GestureDetector(
        onTap: () => Get.back(result: val),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ],
        ),
      );
  Future<void> onDeleteGift(int giftId, String giftName) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Gift'),
        content: Text('Delete "$giftName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _db.deleteGift(giftId);
      successToast('Gift deleted');
      await loadData();
    } catch (_) {
      errorToast('Failed to delete');
    }
  }
  Future<void> onGapAddTap(OccasionGapItem gap) async {
    await Get.toNamed(
      '/gift/add',
      arguments: {
        'personId': gap.personId,
        'occasionId': gap.occasionId,
      },
    );
    await loadData();
  }
  void onBrowseGuideTap() => onTabSwitch(1);
  void _refreshSmartGuideHint() {
    if (smartGuideDismissed.value) return;
    SpecialDate? nearest;
    Person? person;
    var best = 99999;
    for (final d in allDates) {
      final days = daysUntilSpecialDate(d);
      if (days < 0 || days > 60) continue;
      if (days >= best) continue;
      final p = allPeople.firstWhereOrNull((e) => e.id == d.personId);
      if (p == null) continue;
      best = days;
      nearest = d;
      person = p;
    }
    if (nearest == null || person == null) {
      smartGuideHint.value = null;
      return;
    }
    smartGuideHint.value = SmartGuideHint(
      personName: person.name,
      forTag: _relationshipToForTag(person.relationship),
      occasionTag: _dateToOccasionTag(nearest),
    );
  }
  String? _relationshipToForTag(String relationship) {
    switch (relationship) {
      case 'Partner':
        return 'Partner';
      case 'Friend':
        return 'Friend';
      case 'Colleague':
        return 'Colleague';
      case 'Family':
        return 'Mom';
      default:
        return null;
    }
  }
  String? _dateToOccasionTag(SpecialDate sd) {
    if (sd.type == 'Birthday' || sd.type == 'Anniversary') return sd.type;
    final name = (sd.customName ?? '').toLowerCase();
    if (name.contains('valentine')) return "Valentine's Day";
    if (name.contains('christmas') || name.contains('xmas')) return 'Christmas';
    return 'General';
  }
  void onApplySmartGuide() {
    final hint = smartGuideHint.value;
    if (hint == null) return;
    if (hint.forTag != null) guideFilterFor.value = hint.forTag!;
    if (hint.occasionTag != null) guideFilterOccasion.value = hint.occasionTag!;
    currentTab.value = 1;
  }
  void onDismissSmartGuide() {
    smartGuideDismissed.value = true;
    smartGuideHint.value = null;
  }
  List<GuideItem> get filteredGuide {
    final items = guideItems.where((item) {
      final forMatch = guideFilterFor.value == 'All' ||
          item.raw.forTagsList.contains(guideFilterFor.value);
      final occMatch = guideFilterOccasion.value == 'All' ||
          item.raw.occasionTagsList.contains(guideFilterOccasion.value);
      bool budgetMatch = true;
      if (guideFilterBudget.value == 'Under \$30') {
        budgetMatch = item.raw.priceMin < 30;
      } else if (guideFilterBudget.value == '\$30–\$100') {
        budgetMatch = item.raw.priceMin >= 30 && item.raw.priceMax <= 100;
      } else if (guideFilterBudget.value == 'Over \$100') {
        budgetMatch = item.raw.priceMin > 100;
      }
      return forMatch && occMatch && budgetMatch;
    }).toList();
    items.sort((a, b) {
      if (a.added == b.added) return 0;
      return a.added ? 1 : -1;
    });
    return items;
  }
  String? guideDuplicateHint(GuideItem item) {
    final key = item.raw.name.trim().toLowerCase();
    final past = allGifts.where(
      (g) => g.status == 'Gifted' && g.name.trim().toLowerCase() == key,
    );
    if (past.isEmpty) return null;
    final g = past.first;
    final person =
        allPeople.firstWhereOrNull((p) => p.id == g.personId)?.name ?? 'them';
    return 'Gifted to $person before';
  }
  void setGuideFilterFor(String v) =>
      guideFilterFor.value = guideFilterFor.value == v ? 'All' : v;
  void setGuideFilterOccasion(String v) =>
      guideFilterOccasion.value = guideFilterOccasion.value == v ? 'All' : v;
  void setGuideFilterBudget(String v) =>
      guideFilterBudget.value = guideFilterBudget.value == v ? 'All' : v;
  Future<void> onAddToList(GuideItem item) async {
    if (allPeople.isEmpty) {
      errorToast('Add a contact first');
      return;
    }
    final personId = await Get.dialog<int>(
      GiftsPersonPickerDialog(
        people: allPeople.toList(),
        giftName: item.raw.name,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
    if (personId == null) return;
    await Get.toNamed(
      '/gift/add',
      arguments: {
        'personId': personId,
        'prefillName': item.raw.name,
        'prefillPrice': item.raw.priceMin.toDouble(),
        'prefillNotes': item.raw.description,
      },
    );
    await loadData();
  }
  Future<void> onAddGiftTap({int? personId, int? occasionId}) async {
    await Get.toNamed(
      '/gift/add',
      arguments: {
        'personId': ?personId,
        'occasionId': ?occasionId,
      },
    );
    await loadData();
  }
  Future<void> onEditGiftTap(int id) async {
    await Get.toNamed('/gift/edit', arguments: {'id': id});
    await loadData();
  }
  void onTabSwitch(int index) => currentTab.value = index;
}
class GuideItem {
  final GiftGuideItem raw;
  bool added;
  GuideItem({required this.raw, this.added = false});
}
