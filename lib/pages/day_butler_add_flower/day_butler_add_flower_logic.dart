import 'package:get/get.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
class DayButlerAddFlowerLogic extends GetxController {
  final _db = db;
  final selectedPersonId = RxnInt();
  final flowers = ''.obs;
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedOccasionId = RxnInt();
  final occasionNote = ''.obs;
  final notes = ''.obs;
  final duplicateWarning = ''.obs;
  final personError = false.obs;
  final flowersError = false.obs;
  final isSaving = false.obs;
  final allPeople = <Person>[].obs;
  final occasions = <SpecialDate>[].obs;
  final useOccasionDropdown = true.obs;
  int? _editId;
  List<FlowerRecord> _allRecords = [];
  bool get isEditMode => _editId != null;
  String get pageTitle => isEditMode ? 'Edit Record' : 'New Flower Record';
  final quickFlowers = [
    'Red Roses',
    'Mixed Bouquet',
    'Tulips',
    'Sunflowers',
    'Lilies',
    'Custom...',
  ];
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['id'] != null) {
        _editId = args['id'] as int;
        _loadExisting();
      }
      if (args['personId'] != null) {
        selectedPersonId.value = args['personId'] as int;
      }
      if (args['occasionId'] != null) {
        selectedOccasionId.value = args['occasionId'] as int;
        useOccasionDropdown.value = true;
      }
      if (args['prefillFlowers'] != null) {
        flowers.value = args['prefillFlowers'] as String;
      }
      if (args['occasionNote'] != null) {
        occasionNote.value = args['occasionNote'] as String;
      }
      if (args['notes'] != null) {
        notes.value = args['notes'] as String;
      }
      if (args['useToday'] == true) {
        selectedDate.value = DateTime.now();
      }
    }
    _loadPeople();
  }
  Future<void> _loadPeople() async {
    try {
      allPeople.value = await _db.getPeople();
      _allRecords = await _db.getFlowerRecords();
      if (selectedPersonId.value != null) await _loadOccasions();
      _refreshDuplicateWarning();
    } catch (_) {}
  }
  Future<void> _loadOccasions() async {
    final pid = selectedPersonId.value;
    if (pid == null) return;
    try {
      occasions.value = await _db.getSpecialDatesByPersonId(pid);
    } catch (_) {}
  }
  Future<void> _loadExisting() async {
    try {
      final r = await _db.getFlowerRecord(_editId!);
      if (r == null) return;
      selectedPersonId.value = r.personId;
      flowers.value = r.flowers;
      selectedDate.value = DateTime.parse(r.date);
      selectedOccasionId.value = r.occasionId;
      occasionNote.value = r.occasionNote ?? '';
      notes.value = r.notes ?? '';
      useOccasionDropdown.value = r.occasionId != null;
      await _loadOccasions();
      _refreshDuplicateWarning();
    } catch (_) {
      errorToast('Failed to load record');
    }
  }
  void onPersonSelected(int? id) {
    selectedPersonId.value = id;
    selectedOccasionId.value = null;
    if (personError.value && id != null) personError.value = false;
    if (id != null) _loadOccasions();
    _refreshDuplicateWarning();
  }
  void onFlowersChanged(String v) {
    flowers.value = v;
    if (flowersError.value && v.trim().isNotEmpty) flowersError.value = false;
    _refreshDuplicateWarning();
  }
  void onQuickFlowerTap(String quick) {
    if (quick == 'Custom...') return;
    flowers.value = quick;
    _refreshDuplicateWarning();
  }
  void onDateSelected(DateTime d) {
    selectedDate.value = d;
    _refreshDuplicateWarning();
  }
  void onOccasionSelected(int? id) => selectedOccasionId.value = id;
  void onOccasionNoteChanged(String v) => occasionNote.value = v;
  void onNotesChanged(String v) => notes.value = v;
  String occasionLabel(SpecialDate sd) {
    final d = DateTime.tryParse(sd.date);
    final dateStr = d != null ? formatMonthDay(sd.date) : '';
    final name = eventDisplayName(sd);
    return '$name · $dateStr';
  }
  void _refreshDuplicateWarning() {
    final pid = selectedPersonId.value;
    final key = flowers.value.trim().toLowerCase();
    if (pid == null || key.isEmpty) {
      duplicateWarning.value = '';
      return;
    }
    FlowerRecord? prev;
    for (final r in _allRecords) {
      if (r.id == _editId) continue;
      if (r.personId != pid) continue;
      if (r.flowers.trim().toLowerCase() != key) continue;
      final rd = DateTime.tryParse(r.date);
      if (rd == null) continue;
      if (prev == null ||
          (DateTime.tryParse(prev.date)?.isBefore(rd) ?? true)) {
        prev = r;
      }
    }
    if (prev == null) {
      duplicateWarning.value = '';
      return;
    }
    final prevDate = DateTime.tryParse(prev.date);
    if (prevDate == null) {
      duplicateWarning.value = '';
      return;
    }
    final days = selectedDate.value
        .difference(DateTime(prevDate.year, prevDate.month, prevDate.day))
        .inDays;
    if (days < 0) {
      duplicateWarning.value =
          'Same bouquet on file · ${formatDateDisplay(prev.date)}';
      return;
    }
    if (days < 60) {
      duplicateWarning.value = 'Same bouquet sent ${days}d ago — consider a change?';
    } else if (days < 370) {
      duplicateWarning.value =
          'Same bouquet ~${(days / 30).round()}mo ago · ${formatMonthDay(prev.date)}';
    } else {
      duplicateWarning.value =
          'Same bouquet before · ${formatDateDisplay(prev.date)}';
    }
  }
  Future<void> onSaveTap() async {
    personError.value = selectedPersonId.value == null;
    flowersError.value = flowers.value.trim().isEmpty;
    if (personError.value || flowersError.value) return;
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      final record = FlowerRecord(
        id: _editId,
        personId: selectedPersonId.value!,
        flowers: flowers.value.trim(),
        date: getDateString(selectedDate.value),
        occasionId: selectedOccasionId.value,
        occasionNote: occasionNote.value.trim().isEmpty
            ? null
            : occasionNote.value.trim(),
        notes: notes.value.trim().isEmpty ? null : notes.value.trim(),
        createdAt: now,
      );
      if (isEditMode) {
        await _db.updateFlowerRecord(record);
        successToast('Record updated');
      } else {
        await _db.insertFlowerRecord(record);
        successToast('Record added');
      }
      Get.back();
    } catch (e) {
      errorToast('Failed to save record');
    } finally {
      isSaving.value = false;
    }
  }
  void onCancelTap() => Get.back();
}
