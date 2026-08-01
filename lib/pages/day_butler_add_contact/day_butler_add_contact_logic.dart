import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_day_butler/index.dart';
import '../../services/notification_service.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
class DayButlerAddContactLogic extends GetxController {
  final _db = db;
  final _picker = ImagePicker();
  final _notif = NotificationService();
  final name = ''.obs;
  final relationship = ''.obs;
  final budget = ''.obs;
  final notes = ''.obs;
  final avatarPath = Rx<String?>(null);
  final birthday = Rx<DateTime?>(null);
  final nameError = false.obs;
  final relationshipError = false.obs;
  final isSaving = false.obs;
  final budgetHint = ''.obs;
  int? _editPersonId;
  int? _birthdayId;
  String _origName = '';
  String _origRelationship = '';
  String _origBudget = '';
  String _origNotes = '';
  String? _origAvatarPath;
  DateTime? _origBirthday;
  bool _allowDuplicate = false;
  bool get isEditMode => _editPersonId != null;
  String get pageTitle => isEditMode ? 'Edit Contact' : 'New Contact';
  String get avatarLetter {
    final n = name.value.trim();
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }
  int get avatarColor =>
      resolveAvatarColor(name.value.trim(), avatarPath.value);
  bool get hasAvatarPhoto {
    final path = avatarPath.value;
    return isAvatarPhotoPath(path) && File(path!).existsSync();
  }
  String get birthdayLabel {
    final d = birthday.value;
    if (d == null) return 'Add birthday (optional)';
    return formatDateDisplay(getDateString(d));
  }
  final List<String> relationships = [
    'Family',
    'Friend',
    'Partner',
    'Colleague',
  ];
  final List<double> budgetPresets = [25, 50, 100, 200];
  final List<String> noteTemplates = [
    'Likes: ',
    'Allergy: ',
    'Sizes: ',
    'Avoid: ',
  ];
  static const _defaultBudgetByRel = {
    'Family': 100.0,
    'Friend': 50.0,
    'Partner': 150.0,
    'Colleague': 40.0,
  };
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['id'] != null) {
      _editPersonId = args['id'] as int;
      _loadExisting();
    }
  }
  Future<void> _loadExisting() async {
    try {
      final person = await _db.getPerson(_editPersonId!);
      if (person == null) return;
      name.value = person.name;
      relationship.value = person.relationship;
      budget.value = person.annualGiftBudget?.toStringAsFixed(2) ?? '';
      notes.value = person.notes ?? '';
      avatarPath.value = person.avatarPath;
      final bday = await _db.getBirthdayByPersonId(_editPersonId!);
      if (bday != null) {
        _birthdayId = bday.id;
        birthday.value = DateTime.parse(bday.date);
      }
      _origName = person.name;
      _origRelationship = person.relationship;
      _origBudget = budget.value;
      _origNotes = person.notes ?? '';
      _origAvatarPath = person.avatarPath;
      _origBirthday = birthday.value;
      await _refreshBudgetHint();
    } catch (_) {
      errorToast('Failed to load contact');
    }
  }
  void onNameChanged(String v) {
    name.value = v;
    if (nameError.value && v.trim().isNotEmpty) nameError.value = false;
    _allowDuplicate = false;
  }
  Future<void> onRelationshipSelect(String rel) async {
    relationship.value = rel;
    if (relationshipError.value) relationshipError.value = false;
    await _refreshBudgetHint();
  }
  void onBudgetChanged(String v) => budget.value = v;
  void onBudgetPresetTap(double amount) {
    budget.value = amount.toStringAsFixed(2);
  }
  void onNotesChanged(String v) => notes.value = v;
  void onNoteTemplateTap(String template) {
    final current = notes.value;
    if (current.contains(template.trim())) return;
    final next = current.isEmpty ? template : '$current\n$template';
    if (next.length > 200) {
      errorToast('Notes limit is 200 characters');
      return;
    }
    notes.value = next;
  }
  Future<void> onPickBirthday() async {
    final now = DateTime.now();
    final initial =
        birthday.value ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Birthday',
    );
    if (picked != null) birthday.value = picked;
  }
  void onClearBirthday() => birthday.value = null;
  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );
      if (picked == null) return;
      final persisted = await _persistAvatar(picked.path);
      final previous = avatarPath.value;
      avatarPath.value = persisted;
      await _cleanupReplacedAvatar(previous, persisted);
    } catch (_) {
      errorToast('Failed to pick image');
    }
  }
  Future<void> onStyleColorSelect(int color) async {
    final previous = avatarPath.value;
    avatarPath.value = encodeStyleAvatarPath(color);
    await _cleanupReplacedAvatar(previous, avatarPath.value);
  }
  Future<void> removeAvatar() async {
    final previous = avatarPath.value;
    avatarPath.value = null;
    await _cleanupReplacedAvatar(previous, null);
  }
  Future<void> _cleanupReplacedAvatar(String? previous, String? current) async {
    if (previous == null ||
        previous == current ||
        previous == _origAvatarPath) {
      return;
    }
    if (isAvatarPhotoPath(previous)) {
      await _deleteAvatarFile(previous);
    }
  }
  Future<String> _persistAvatar(String tempPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory(p.join(dir.path, 'avatars'));
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    final ext = p.extension(tempPath).isEmpty ? '.jpg' : p.extension(tempPath);
    final dest = p.join(
      avatarDir.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(tempPath).copy(dest);
    return dest;
  }
  Future<void> _deleteAvatarFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
  Future<void> _refreshBudgetHint() async {
    final rel = relationship.value;
    if (rel.isEmpty) {
      budgetHint.value = '';
      return;
    }
    try {
      final people = await _db.getPeople();
      final budgets =
          people
              .where(
                (p) =>
                    p.relationship == rel &&
                    p.annualGiftBudget != null &&
                    p.id != _editPersonId,
              )
              .map((p) => p.annualGiftBudget!)
              .toList()
            ..sort();
      if (budgets.isNotEmpty) {
        final mid = budgets[budgets.length ~/ 2];
        budgetHint.value =
            'Suggested for $rel: \$${mid.toStringAsFixed(0)} (based on your contacts)';
        return;
      }
    } catch (_) {}
    final fallback = _defaultBudgetByRel[rel];
    budgetHint.value = fallback == null
        ? ''
        : 'Suggested for $rel: \$${fallback.toStringAsFixed(0)}';
  }
  Future<Person?> _findDuplicate(String trimmedName) async {
    final people = await _db.getPeople();
    final lower = trimmedName.toLowerCase();
    for (final p in people) {
      if (p.id == _editPersonId) continue;
      if (p.name.trim().toLowerCase() == lower) return p;
    }
    return null;
  }
  Future<void> onSaveTap({bool addAnother = false}) async {
    nameError.value = name.value.trim().isEmpty;
    relationshipError.value = relationship.value.isEmpty;
    if (nameError.value || relationshipError.value) return;
    if (isSaving.value) return;
    final budgetText = budget.value.trim();
    double? budgetVal;
    if (budgetText.isNotEmpty) {
      budgetVal = double.tryParse(budgetText);
      if (budgetVal == null) {
        errorToast('Invalid budget amount');
        return;
      }
    }
    final trimmedName = name.value.trim();
    if (!_allowDuplicate) {
      try {
        final dup = await _findDuplicate(trimmedName);
        if (dup != null) {
          final action = await _showDuplicateDialog(dup);
          if (action == _DupAction.openExisting) {
            Get.offNamed('/person/detail', arguments: {'id': dup.id});
            return;
          }
          if (action != _DupAction.createAnyway) return;
          _allowDuplicate = true;
        }
      } catch (_) {
        errorToast('Failed to check duplicates');
        return;
      }
    }
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      final notesVal = notes.value.trim().isEmpty ? null : notes.value.trim();
      if (isEditMode) {
        final existing = await _db.getPerson(_editPersonId!);
        if (existing == null) throw Exception('Contact not found');
        final updated = Person(
          id: _editPersonId,
          name: trimmedName,
          relationship: relationship.value,
          avatarPath: avatarPath.value,
          notes: notesVal,
          isPinned: existing.isPinned,
          pinnedAt: existing.pinnedAt,
          annualGiftBudget: budgetVal,
          createdAt: existing.createdAt,
        );
        final result = await _db.updatePerson(updated);
        if (result == null) throw Exception('Update failed');
        await _syncBirthday(_editPersonId!, trimmedName);
        if (_origAvatarPath != null &&
            _origAvatarPath != avatarPath.value &&
            isAvatarPhotoPath(_origAvatarPath)) {
          await _deleteAvatarFile(_origAvatarPath!);
        }
        successToast('Contact updated');
        Get.back();
      } else {
        final person = Person(
          name: trimmedName,
          relationship: relationship.value,
          avatarPath: avatarPath.value,
          notes: notesVal,
          annualGiftBudget: budgetVal,
          createdAt: now,
        );
        final newId = await _db.insertPerson(person);
        if (newId == null) throw Exception('Insert failed');
        await _syncBirthday(newId, trimmedName);
        successToast('Contact added');
        if (addAnother) {
          _resetFormForAnother();
          return;
        }
        final needBirthday = birthday.value == null;
        final needBudget = budgetVal == null;
        if (needBirthday || needBudget) {
          await _showPostSaveChecklist(
            personId: newId,
            needBirthday: needBirthday,
            needBudget: needBudget,
          );
        } else {
          Get.offNamed('/person/detail', arguments: {'id': newId});
        }
      }
    } catch (_) {
      errorToast('Failed to save contact');
    } finally {
      isSaving.value = false;
    }
  }
  Future<_DupAction?> _showDuplicateDialog(Person dup) async {
    return Get.dialog<_DupAction>(
      AlertDialog(
        title: const Text('Possible duplicate'),
        content: Text(
          '"${dup.name}" already exists. Open the existing contact or create another anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: _DupAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: _DupAction.openExisting),
            child: const Text('Open Existing'),
          ),
          TextButton(
            onPressed: () => Get.back(result: _DupAction.createAnyway),
            child: const Text('Create Anyway'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  Future<void> _showPostSaveChecklist({
    required int personId,
    required bool needBirthday,
    required bool needBudget,
  }) async {
    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Contact saved!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Finish setup for better reminders and gift planning.',
                style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              if (needBirthday)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_outlined),
                  title: const Text('Add Birthday'),
                  subtitle: const Text('Never miss their special day'),
                  onTap: () {
                    Get.back();
                    Get.offNamed(
                      '/date/add',
                      arguments: {'personId': personId},
                    );
                  },
                ),
              if (needBudget)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.card_giftcard_outlined),
                  title: const Text('Set Gift Budget'),
                  subtitle: const Text('Plan annual gifting with a limit'),
                  onTap: () {
                    Get.back();
                    Get.offNamed(
                      '/person/edit',
                      arguments: {'id': personId},
                    );
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: const Text('View Contact'),
                onTap: () {
                  Get.back();
                  Get.offNamed(
                    '/person/detail',
                    arguments: {'id': personId},
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.offNamed(
                    '/person/detail',
                    arguments: {'id': personId},
                  );
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }
  Future<void> _syncBirthday(int personId, String personName) async {
    final selected = birthday.value;
    if (selected == null) {
      if (_birthdayId != null) {
        try {
          await _notif.cancelAllForDate(_birthdayId!);
        } catch (_) {}
        await _db.deleteSpecialDate(_birthdayId!);
        _birthdayId = null;
      }
      return;
    }
    final dateStr = getDateString(selected);
    final now = DateTime.now().toIso8601String();
    final defaultTime = await _loadDefaultReminderTime24h();
    if (_birthdayId != null) {
      final existing = await _db.getSpecialDate(_birthdayId!);
      if (existing == null) {
        _birthdayId = null;
      } else {
        final updated = SpecialDate(
          id: existing.id,
          personId: personId,
          type: 'Birthday',
          customName: existing.customName,
          date: dateStr,
          repeatYearly: true,
          reminderDays: existing.reminderDays,
          reminderTime: existing.reminderTime,
          cakeReminderEnabled: existing.cakeReminderEnabled,
          cakeReminderDaysBefore: existing.cakeReminderDaysBefore,
          cakeReminderTime: existing.cakeReminderTime,
          flowerReminderEnabled: existing.flowerReminderEnabled,
          flowerReminderDaysBefore: existing.flowerReminderDaysBefore,
          flowerReminderTime: existing.flowerReminderTime,
          prepChecklist: existing.prepChecklist,
          createdAt: existing.createdAt,
        );
        await _db.updateSpecialDate(updated);
        await _scheduleBirthdayReminder(
          dateId: existing.id!,
          personName: personName,
          eventDate: selected,
          reminderDays: existing.reminderDaysList,
          reminderTime: existing.reminderTime,
          cakeEnabled: existing.cakeReminderEnabled,
          cakeDaysBefore: existing.cakeReminderDaysBefore,
          cakeTime: existing.cakeReminderTime,
          flowerEnabled: existing.flowerReminderEnabled,
          flowerDaysBefore: existing.flowerReminderDaysBefore,
          flowerTime: existing.flowerReminderTime,
        );
        return;
      }
    }
    final sd = SpecialDate(
      personId: personId,
      type: 'Birthday',
      date: dateStr,
      repeatYearly: true,
      reminderDays: '[1]',
      reminderTime: defaultTime,
      cakeReminderTime: defaultTime,
      flowerReminderTime: defaultTime,
      createdAt: now,
    );
    final newId = await _db.insertSpecialDate(sd);
    if (newId == null) throw Exception('Birthday save failed');
    _birthdayId = newId;
    await _scheduleBirthdayReminder(
      dateId: newId,
      personName: personName,
      eventDate: selected,
      reminderDays: const [1],
      reminderTime: defaultTime,
      cakeEnabled: false,
      cakeDaysBefore: 3,
      cakeTime: defaultTime,
      flowerEnabled: false,
      flowerDaysBefore: 2,
      flowerTime: defaultTime,
    );
  }
  Future<void> _scheduleBirthdayReminder({
    required int dateId,
    required String personName,
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
    try {
      await _ensureNotificationPermission();
      await _notif.scheduleForSpecialDate(
        dateId: dateId,
        personName: personName,
        eventName: 'Birthday',
        eventDate: eventDate,
        reminderDays: reminderDays,
        reminderTime: reminderTime,
        cakeEnabled: cakeEnabled,
        cakeDaysBefore: cakeDaysBefore,
        cakeTime: cakeTime,
        flowerEnabled: flowerEnabled,
        flowerDaysBefore: flowerDaysBefore,
        flowerTime: flowerTime,
      );
    } catch (_) {
      errorToast('Birthday saved, but reminder could not be scheduled');
    }
  }
  Future<void> _ensureNotificationPermission() async {
    final granted = await _notif.isPermissionGranted();
    if (granted) return;
    final status = await ph.Permission.notification.status;
    if (status.isPermanentlyDenied) {
      errorToast('Please enable notifications in system Settings');
      await ph.openAppSettings();
      return;
    }
    final requested = await _notif.requestPermission();
    if (!requested) {
      errorToast('Reminders need notification permission');
    }
  }
  Future<String> _loadDefaultReminderTime24h() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final display = prefs.getString('default_reminder_time') ?? '9:00 AM';
      return _parseDisplayTimeTo24h(display);
    } catch (_) {
      return '09:00';
    }
  }
  String _parseDisplayTimeTo24h(String display) {
    try {
      final isPm = display.toUpperCase().contains('PM');
      final parts = display.replaceAll(RegExp(r'[APMapm\s]'), '').split(':');
      int h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (isPm && h != 12) h += 12;
      if (!isPm && h == 12) h = 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return '09:00';
    }
  }
  void _resetFormForAnother() {
    name.value = '';
    relationship.value = '';
    budget.value = '';
    notes.value = '';
    avatarPath.value = null;
    birthday.value = null;
    nameError.value = false;
    relationshipError.value = false;
    budgetHint.value = '';
    _birthdayId = null;
    _allowDuplicate = false;
    _origName = '';
    _origRelationship = '';
    _origBudget = '';
    _origNotes = '';
    _origAvatarPath = null;
    _origBirthday = null;
  }
  void onCancelTap() {
    if (_hasChanges()) {
      Get.dialog(
        AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Your changes will not be saved.'),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Keep Editing')),
            TextButton(
              onPressed: () async {
                await _cleanupUnsavedAvatar();
                Get.back();
                Get.back();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }
  Future<void> _cleanupUnsavedAvatar() async {
    final current = avatarPath.value;
    if (current != null &&
        current != _origAvatarPath &&
        isAvatarPhotoPath(current)) {
      await _deleteAvatarFile(current);
    }
  }
  bool _hasChanges() {
    final b = birthday.value;
    final o = _origBirthday;
    final bdayChanged =
        (b == null) != (o == null) ||
        (b != null &&
            o != null &&
            (b.year != o.year || b.month != o.month || b.day != o.day));
    return name.value.trim() != _origName ||
        relationship.value != _origRelationship ||
        budget.value.trim() != _origBudget ||
        notes.value.trim() != _origNotes ||
        avatarPath.value != _origAvatarPath ||
        bdayChanged;
  }
}
enum _DupAction { cancel, openExisting, createAnyway }
