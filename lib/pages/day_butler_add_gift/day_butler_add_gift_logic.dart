import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
class DayButlerAddGiftLogic extends GetxController {
  final _db = db;
  final selectedPersonId = Rx<int?>(null);
  final giftName = ''.obs;
  final price = ''.obs;
  final status = 'Idea'.obs;
  final selectedOccasionId = Rx<int?>(null);
  final link = ''.obs;
  final notes = ''.obs;
  final reaction = Rx<String?>(null);
  final nameError = false.obs;
  final personError = false.obs;
  final linkError = false.obs;
  final isSaving = false.obs;
  final allPeople = <Person>[].obs;
  final occasions = <SpecialDate>[].obs;
  final historicalGifts = <Gift>[].obs;
  final personGifts = <Gift>[].obs;
  final showAllHistory = false.obs;
  final yearSpent = 0.0.obs;
  final annualBudget = Rx<double?>(null);
  final similarGift = Rx<Gift?>(null);
  final occasionSuggested = false.obs;
  int? _editGiftId;
  Gift? _existing;
  bool _occasionTouched = false;
  bool get isEditMode => _editGiftId != null;
  String get pageTitle => isEditMode ? 'Edit Gift' : 'New Gift';
  bool get showReaction => status.value == 'Gifted';
  int get moreHistoryCount => historicalGifts.length - 5;
  final statusOptions = ['Idea', 'Purchased', 'Gifted'];
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['id'] != null) {
        _editGiftId = args['id'] as int;
        _loadExisting();
      }
      if (args['personId'] != null) {
        selectedPersonId.value = args['personId'] as int;
      }
      if (args['occasionId'] != null) {
        selectedOccasionId.value = args['occasionId'] as int;
        _occasionTouched = true;
      }
      if (args['prefillName'] != null) giftName.value = args['prefillName'] as String;
      if (args['prefillPrice'] != null) {
        price.value = (args['prefillPrice'] as double).toStringAsFixed(0);
      }
      if (args['prefillNotes'] != null) notes.value = args['prefillNotes'] as String;
    }
    _loadPeople();
  }
  Future<void> _loadPeople() async {
    try {
      allPeople.value = await _db.getPeople();
      if (selectedPersonId.value != null) await _loadOccasionsAndHistory();
    } catch (_) {
      errorToast('Failed to load people');
    }
  }
  Future<void> _loadOccasionsAndHistory() async {
    final pid = selectedPersonId.value;
    if (pid == null) return;
    try {
      occasions.value = await _db.getSpecialDatesByPersonId(pid);
      final all = await _db.getGiftsByPersonId(pid);
      personGifts.value = all;
      historicalGifts.value = all
          .where((g) => g.status == 'Gifted' && g.id != _editGiftId)
          .toList()
        ..sort((a, b) {
          final da = a.giftedDate ?? a.createdAt;
          final db_ = b.giftedDate ?? b.createdAt;
          try {
            return DateTime.parse(db_).compareTo(DateTime.parse(da));
          } catch (_) {
            return 0;
          }
        });
      _calcYearSpent(all);
      _syncBudgetFromPerson();
      _updateSimilarGift();
      _suggestOccasion();
    } catch (_) {
      errorToast('Failed to load gift history');
    }
  }
  void _syncBudgetFromPerson() {
    final p = allPeople.firstWhereOrNull((e) => e.id == selectedPersonId.value);
    annualBudget.value = p?.annualGiftBudget;
  }
  void _calcYearSpent(List<Gift> gifts) {
    final year = DateTime.now().year;
    double spent = 0;
    for (final g in gifts) {
      if (g.id == _editGiftId) continue;
      if (g.price == null) continue;
      if (g.status != 'Purchased' && g.status != 'Gifted') continue;
      final ds = g.giftedDate ?? g.createdAt;
      try {
        if (DateTime.parse(ds).year == year) spent += g.price!;
      } catch (_) {}
    }
    yearSpent.value = spent;
  }
  void _suggestOccasion() {
    if (isEditMode || _occasionTouched || occasions.isEmpty) return;
    SpecialDate? best;
    var bestDays = 99999;
    for (final sd in occasions) {
      final days = daysUntilSpecialDate(sd);
      if (days < 0 || days >= bestDays) continue;
      bestDays = days;
      best = sd;
    }
    if (best?.id == null) {
      occasionSuggested.value = false;
      return;
    }
    selectedOccasionId.value = best!.id;
    occasionSuggested.value = true;
  }
  void _updateSimilarGift() {
    final q = giftName.value.trim().toLowerCase();
    if (q.length < 3) {
      similarGift.value = null;
      return;
    }
    similarGift.value = personGifts.firstWhereOrNull((g) {
      if (g.id == _editGiftId) return false;
      final n = g.name.toLowerCase();
      return n == q || n.contains(q) || q.contains(n);
    });
  }
  Future<void> _loadExisting() async {
    try {
      final g = await _db.getGift(_editGiftId!);
      if (g == null) {
        errorToast('Gift not found');
        return;
      }
      _existing = g;
      _occasionTouched = true;
      selectedPersonId.value = g.personId;
      giftName.value = g.name;
      price.value = g.price?.toStringAsFixed(2) ?? '';
      status.value = g.status;
      selectedOccasionId.value = g.occasionId;
      link.value = g.link ?? '';
      notes.value = g.notes ?? '';
      reaction.value = g.reaction;
      await _loadOccasionsAndHistory();
    } catch (_) {
      errorToast('Failed to load gift');
    }
  }
  void onPersonSelected(int? id) {
    selectedPersonId.value = id;
    selectedOccasionId.value = null;
    showAllHistory.value = false;
    _occasionTouched = false;
    occasionSuggested.value = false;
    similarGift.value = null;
    if (id != null) {
      personError.value = false;
      _loadOccasionsAndHistory();
    } else {
      occasions.clear();
      historicalGifts.clear();
      personGifts.clear();
      yearSpent.value = 0;
      annualBudget.value = null;
    }
  }
  void onNameChanged(String v) {
    giftName.value = v;
    if (nameError.value && v.trim().isNotEmpty) nameError.value = false;
    _updateSimilarGift();
  }
  void onPriceChanged(String v) => price.value = v;
  void onStatusSelected(String s) {
    status.value = s;
    if (s != 'Gifted') reaction.value = null;
  }
  void onOccasionSelected(int? id) {
    _occasionTouched = true;
    occasionSuggested.value = false;
    selectedOccasionId.value = id;
  }
  void onLinkChanged(String v) {
    link.value = v;
    if (linkError.value) linkError.value = false;
  }
  void onNotesChanged(String v) => notes.value = v;
  void onReactionSelected(String? r) => reaction.value = r;
  void onViewMoreHistoryTap() => showAllHistory.value = true;
  Future<void> onPasteLinkTap() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty) {
        errorToast('Clipboard is empty');
        return;
      }
      onLinkChanged(text);
      successToast('Link pasted');
    } catch (_) {
      errorToast('Failed to paste');
    }
  }
  Future<void> onOpenLinkTap() async {
    final url = link.value.trim();
    if (!_isValidUrl(url)) {
      errorToast('Please enter a valid URL');
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        errorToast('Cannot open link');
      }
    } catch (_) {
      errorToast('Cannot open link');
    }
  }
  bool _isValidUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');
  bool get canOpenLink => _isValidUrl(link.value.trim());
  double get _thisGiftContribution {
    if (status.value != 'Purchased' && status.value != 'Gifted') return 0;
    return double.tryParse(price.value.trim()) ?? 0;
  }
  double get projectedSpent => yearSpent.value + _thisGiftContribution;
  bool get showBudgetHint => selectedPersonId.value != null;
  bool get isOverBudget {
    final b = annualBudget.value;
    return b != null && projectedSpent > b;
  }
  String get budgetHintText {
    final spent = projectedSpent;
    final budget = annualBudget.value;
    final spentStr = spent.toStringAsFixed(spent == spent.roundToDouble() ? 0 : 2);
    if (budget == null) {
      return '\$$spentStr spent this year after this';
    }
    final budgetStr = budget.toStringAsFixed(budget == budget.roundToDouble() ? 0 : 2);
    if (isOverBudget) return 'After this: \$$spentStr / \$$budgetStr · Over budget!';
    return 'After this: \$$spentStr / \$$budgetStr';
  }
  String? get similarGiftHint {
    final g = similarGift.value;
    if (g == null) return null;
    return 'Similar to "${g.name}" (${g.status})';
  }
  String? get occasionSuggestHint {
    if (!occasionSuggested.value) return null;
    final id = selectedOccasionId.value;
    final sd = occasions.firstWhereOrNull((e) => e.id == id);
    if (sd == null) return null;
    return 'Suggested: ${occasionLabel(sd)}';
  }
  Map<String, int> get reactionCounts {
    final counts = <String, int>{};
    for (final g in historicalGifts) {
      final r = g.reaction;
      if (r == null || r.isEmpty) continue;
      counts[r] = (counts[r] ?? 0) + 1;
    }
    return counts;
  }
  bool get showTasteInsight => reactionCounts.isNotEmpty;
  String get tasteInsightText {
    const order = ['loved', 'liked', 'okay', 'miss'];
    const emoji = {
      'loved': '😍',
      'liked': '😊',
      'okay': '😐',
      'miss': '😕',
    };
    final parts = <String>[];
    for (final key in order) {
      final n = reactionCounts[key];
      if (n != null && n > 0) parts.add('${emoji[key]}×$n');
    }
    return parts.join('  ');
  }
  List<Gift> get displayedHistory =>
      showAllHistory.value ? historicalGifts : historicalGifts.take(5).toList();
  bool get hasMoreHistory => historicalGifts.length > 5 && !showAllHistory.value;
  String? get selectedPersonName =>
      allPeople.firstWhereOrNull((p) => p.id == selectedPersonId.value)?.name;
  String occasionLabel(SpecialDate sd) {
    final d = DateTime.tryParse(sd.date);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = d != null ? '${m[d.month - 1]} ${d.day}' : '';
    final name = sd.type == 'Custom' ? (sd.customName ?? 'Custom') : sd.type;
    return '$name · $dateStr';
  }
  Future<bool> _confirmDuplicateIfNeeded() async {
    final g = similarGift.value;
    if (g == null) return true;
    final ok = await Get.dialog<bool>(AlertDialog(
      title: const Text('Similar Gift Found'),
      content: Text('You already have "${g.name}" (${g.status}). Save anyway?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(onPressed: () => Get.back(result: true), child: const Text('Save anyway')),
      ],
    ));
    return ok == true;
  }
  Future<void> onSaveTap() async {
    nameError.value = giftName.value.trim().isEmpty;
    personError.value = selectedPersonId.value == null;
    final linkVal = link.value.trim();
    linkError.value = linkVal.isNotEmpty && !_isValidUrl(linkVal);
    if (nameError.value || personError.value || linkError.value) return;
    if (isSaving.value) return;
    if (!await _confirmDuplicateIfNeeded()) return;
    isSaving.value = true;
    try {
      final priceVal =
          price.value.trim().isEmpty ? null : double.tryParse(price.value.trim());
      final now = getDateString(DateTime.now());
      final wasGifted = _existing?.status == 'Gifted';
      String? giftedDate = _existing?.giftedDate;
      if (status.value == 'Gifted' && !wasGifted) {
        giftedDate = now;
      } else if (status.value != 'Gifted') {
        giftedDate = null;
      }
      final gift = Gift(
        id: _editGiftId,
        personId: selectedPersonId.value!,
        name: giftName.value.trim(),
        price: priceVal,
        status: status.value,
        occasionId: selectedOccasionId.value,
        link: linkVal.isEmpty ? null : linkVal,
        notes: notes.value.trim().isEmpty ? null : notes.value.trim(),
        giftedDate: giftedDate,
        reaction: status.value == 'Gifted' ? reaction.value : null,
        createdAt: _existing?.createdAt ?? now,
      );
      if (isEditMode) {
        final result = await _db.updateGift(gift);
        if (result == null) {
          errorToast('Failed to save gift');
          return;
        }
        successToast('Gift updated');
      } else {
        final result = await _db.insertGift(gift);
        if (result == null) {
          errorToast('Failed to save gift');
          return;
        }
        successToast('Gift added');
      }
      Get.back();
    } catch (e) {
      errorToast('Failed to save gift');
    } finally {
      isSaving.value = false;
    }
  }
  void onCancelTap() => Get.back();
}
