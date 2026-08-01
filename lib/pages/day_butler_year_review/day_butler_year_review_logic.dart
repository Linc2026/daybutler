import 'package:get/get.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
class DayButlerYearReviewLogic extends GetxController {
  final _db = db;
  final isLoading = true.obs;
  final birthdaysRemembered = 0.obs;
  final giftsGiven = 0.obs;
  final totalSpent = 0.0.obs;
  final flowersSent = 0.obs;
  final mostRememberedName = '—'.obs;
  final mostRememberedRelationship = ''.obs;
  final nextBigDayText = ''.obs;
  final encouragementText = ''.obs;
  final currentYear = DateTime.now().year;
  @override
  void onInit() {
    super.onInit();
    loadData();
  }
  void onResumed() => loadData();
  Future<void> onRefresh() => loadData();
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final now = DateTime.now();
      final todayNorm = DateTime(now.year, now.month, now.day);
      final yearStart = DateTime(now.year, 1, 1);
      final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
      final people = await _db.getPeople();
      final allDates = await _db.getSpecialDates();
      final gifts = await _db.getGifts();
      final flowerRecords = await _db.getFlowerRecords();
      birthdaysRemembered.value =
          _countBirthdaysRemembered(allDates, now, todayNorm);
      final giftedThisYear = _giftsGiftedInYear(gifts, yearStart, yearEnd);
      giftsGiven.value = giftedThisYear.length;
      totalSpent.value = _sumSpentInYear(gifts, yearStart, yearEnd);
      final flowersThisYear = <FlowerRecord>[];
      for (final r in flowerRecords) {
        if (_isInYear(r.date, yearStart, yearEnd)) flowersThisYear.add(r);
      }
      flowersSent.value = flowersThisYear.length;
      _computeMostRemembered(people, giftedThisYear, flowersThisYear);
      nextBigDayText.value =
          _computeNextBigDay(people, allDates, now, todayNorm);
      _computeEncouragement();
    } catch (_) {
      errorToast('Failed to load year review');
    } finally {
      isLoading.value = false;
    }
  }
  int _countBirthdaysRemembered(
    List<SpecialDate> allDates,
    DateTime now,
    DateTime todayNorm,
  ) {
    var count = 0;
    for (final d in allDates) {
      if (d.type != 'Birthday') continue;
      try {
        final date = DateTime.parse(d.date);
        final thisYearBday = DateTime(now.year, date.month, date.day);
        if (!thisYearBday.isAfter(todayNorm)) count++;
      } catch (_) {}
    }
    return count;
  }
  List<Gift> _giftsGiftedInYear(
    List<Gift> gifts,
    DateTime yearStart,
    DateTime yearEnd,
  ) {
    return gifts.where((g) {
      if (g.status != 'Gifted') return false;
      final ds = g.giftedDate;
      if (ds == null || ds.isEmpty) return false;
      return _isInYear(ds, yearStart, yearEnd);
    }).toList();
  }
  double _sumSpentInYear(
    List<Gift> gifts,
    DateTime yearStart,
    DateTime yearEnd,
  ) {
    var spent = 0.0;
    for (final g in gifts) {
      if (g.price == null) continue;
      if (g.status != 'Gifted') continue;
      final ds = g.giftedDate;
      if (ds == null || ds.isEmpty) continue;
      if (_isInYear(ds, yearStart, yearEnd)) spent += g.price!;
    }
    return spent;
  }
  void _computeMostRemembered(
    List<Person> people,
    List<Gift> giftedThisYear,
    List<FlowerRecord> flowersThisYear,
  ) {
    final giftCount = <int, int>{};
    final flowerCount = <int, int>{};
    for (final g in giftedThisYear) {
      giftCount[g.personId] = (giftCount[g.personId] ?? 0) + 1;
    }
    for (final r in flowersThisYear) {
      flowerCount[r.personId] = (flowerCount[r.personId] ?? 0) + 1;
    }
    final personIds = {...giftCount.keys, ...flowerCount.keys};
    if (personIds.isEmpty) {
      mostRememberedName.value = '—';
      mostRememberedRelationship.value = '';
      return;
    }
    int? topId;
    var topTotal = -1;
    var topGifts = -1;
    for (final id in personIds) {
      final gifts = giftCount[id] ?? 0;
      final flowers = flowerCount[id] ?? 0;
      final total = gifts + flowers;
      if (total > topTotal || (total == topTotal && gifts > topGifts)) {
        topTotal = total;
        topGifts = gifts;
        topId = id;
      }
    }
    final topPerson = people.firstWhereOrNull((p) => p.id == topId);
    mostRememberedName.value = topPerson?.name ?? '—';
    mostRememberedRelationship.value = topPerson?.relationship ?? '';
  }
  String _computeNextBigDay(
    List<Person> people,
    List<SpecialDate> allDates,
    DateTime now,
    DateTime todayNorm,
  ) {
    SpecialDate? pickClosest(Iterable<SpecialDate> candidates) {
      SpecialDate? best;
      var bestDays = 1 << 30;
      for (final d in candidates) {
        final days = daysUntilSpecialDate(d);
        if (days < 0) continue;
        final person = people.firstWhereOrNull((p) => p.id == d.personId);
        if (person == null) continue;
        if (days < bestDays) {
          bestDays = days;
          best = d;
        }
      }
      return best;
    }
    final anniversaries = allDates.where((d) => d.type == 'Anniversary');
    final selected =
        pickClosest(anniversaries) ?? pickClosest(allDates);
    if (selected == null) return 'No upcoming dates';
    final person =
        people.firstWhereOrNull((p) => p.id == selected.personId);
    if (person == null) return 'No upcoming dates';
    final days = daysUntilSpecialDate(selected);
    final daysPart = _formatDaysPart(days);
    final eventPart = _formatEventPart(selected, now, todayNorm);
    return '${person.name}\'s $eventPart · $daysPart';
  }
  String _formatEventPart(
    SpecialDate d,
    DateTime now,
    DateTime todayNorm,
  ) {
    if (d.type == 'Birthday') return 'Birthday';
    if (d.type == 'Custom') {
      return d.customName?.trim().isNotEmpty == true
          ? d.customName!.trim()
          : 'Event';
    }
    if (d.type == 'Anniversary') {
      try {
        final date = DateTime.parse(d.date);
        var nextYear = now.year;
        if (DateTime(now.year, date.month, date.day).isBefore(todayNorm)) {
          nextYear = now.year + 1;
        }
        final years = nextYear - date.year;
        if (years > 0) return '${ordinal(years)} Anniversary';
      } catch (_) {}
      return 'Anniversary';
    }
    return d.type;
  }
  String _formatDaysPart(int days) {
    if (days == 0) return 'today';
    if (days == 1) return 'in 1 day';
    return 'in $days days';
  }
  void _computeEncouragement() {
    final totalGifts = giftsGiven.value;
    if (totalGifts == 0 && flowersSent.value == 0) {
      encouragementText.value =
          'You\'re just getting started! 🌱 Add people and start recording your caring moments.';
    } else if (totalGifts <= 5) {
      encouragementText.value =
          'A thoughtful start! Keep spreading the love. 💕';
    } else if (totalGifts <= 15) {
      final name = mostRememberedName.value;
      if (name.isNotEmpty && name != '—') {
        encouragementText.value =
            'Wow, you really care! $name is lucky to have you. 🌟';
      } else {
        encouragementText.value =
            'Wow, you really care! Keep spreading the love. 🌟';
      }
    } else {
      encouragementText.value =
          'An incredible year of generosity! You\'re truly one of a kind. 🏆';
    }
  }
  bool _isInYear(String dateStr, DateTime yearStart, DateTime yearEnd) {
    try {
      final d = DateTime.parse(dateStr);
      return !d.isBefore(yearStart) && !d.isAfter(yearEnd);
    } catch (_) {
      return false;
    }
  }
  String get totalSpentFormatted {
    final s = totalSpent.value;
    final raw = s == s.truncate()
        ? s.toStringAsFixed(0)
        : s.toStringAsFixed(2);
    final withCommas = raw.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$withCommas';
  }
}
