import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_day_butler/index.dart';
import '../../services/notification_service.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
enum PeopleFilter { all, thisWeek, noDates }
class PersonItem {
  final int id;
  final String name;
  final String avatarLetter;
  final int avatarColor;
  final String? avatarPath;
  final String relationship;
  final String upcoming;
  final bool isPinned;
  final String? pinnedAt;
  final int daysUntilNext;
  final bool hasDates;
  const PersonItem({
    required this.id,
    required this.name,
    required this.avatarLetter,
    required this.avatarColor,
    this.avatarPath,
    required this.relationship,
    required this.upcoming,
    this.isPinned = false,
    this.pinnedAt,
    this.daysUntilNext = 9999,
    this.hasDates = false,
  });
}
class DayButlerPeopleLogic extends GetxController {
  static const _sortPrefKey = 'people_sort_urgency';
  static const _relationships = ['Family', 'Friend', 'Partner', 'Colleague'];
  final _db = db;
  final _notif = NotificationService();
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final filterMode = PeopleFilter.all.obs;
  final sortByUrgency = false.obs;
  final _allPeople = <PersonItem>[].obs;
  @override
  void onInit() {
    super.onInit();
    _loadSortPref();
    loadData();
  }
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  void onResumed() => loadData();
  Future<void> _loadSortPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      sortByUrgency.value = prefs.getBool(_sortPrefKey) ?? false;
    } catch (_) {}
  }
  Future<void> loadData() async {
    try {
      final people = await _db.getPeople();
      final allDates = await _db.getSpecialDates();
      final items = people.map((p) {
        final dates = allDates.where((d) => d.personId == p.id).toList();
        int minDays = 9999;
        String upcomingStr = 'No dates';
        for (final d in dates) {
          final days = daysUntilSpecialDate(d);
          if (days >= 0 && days < minDays) {
            minDays = days;
            final typeName = eventDisplayName(d);
            upcomingStr = '$typeName · ${formatCountdown(days, d.type)}';
          }
        }
        return PersonItem(
          id: p.id!,
          name: p.name,
          avatarLetter: p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
          avatarColor: resolveAvatarColor(p.name, p.avatarPath),
          avatarPath: p.avatarPath,
          relationship: p.relationship,
          upcoming: upcomingStr,
          isPinned: p.isPinned,
          pinnedAt: p.pinnedAt,
          daysUntilNext: minDays,
          hasDates: dates.isNotEmpty,
        );
      }).toList();
      _allPeople.value = items;
    } catch (e) {
      errorToast('Failed to load contacts');
    }
  }
  int get weekFocusCount =>
      _allPeople.where((p) => p.daysUntilNext <= 7).length;
  List<PersonItem> get careRadarPeople {
    final list = _allPeople.where((p) => p.daysUntilNext <= 7).toList();
    list.sort((a, b) {
      if (a.daysUntilNext != b.daysUntilNext)
        return a.daysUntilNext.compareTo(b.daysUntilNext);
      return a.name.compareTo(b.name);
    });
    return list;
  }
  List<PersonItem> get filteredPeople {
    var list = _allPeople.toList();
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    switch (filterMode.value) {
      case PeopleFilter.thisWeek:
        list = list.where((p) => p.daysUntilNext <= 7).toList();
        break;
      case PeopleFilter.noDates:
        list = list.where((p) => !p.hasDates).toList();
        break;
      case PeopleFilter.all:
        break;
    }
    return list;
  }
  List<PersonItem> _groupSorted(List<PersonItem> people) {
    final copy = [...people];
    copy.sort((a, b) {
      if (a.daysUntilNext != b.daysUntilNext)
        return a.daysUntilNext.compareTo(b.daysUntilNext);
      return a.name.compareTo(b.name);
    });
    return copy;
  }
  List<PersonItem> get pinned {
    final list = filteredPeople.where((p) => p.isPinned).toList();
    if (sortByUrgency.value) {
      return _groupSorted(list);
    }
    list.sort((a, b) {
      final aAt = a.pinnedAt ?? '';
      final bAt = b.pinnedAt ?? '';
      if (aAt != bAt) return aAt.compareTo(bAt);
      return a.name.compareTo(b.name);
    });
    return list;
  }
  List<PersonItem> get family => _groupSorted(
    filteredPeople
        .where((p) => !p.isPinned && p.relationship == 'Family')
        .toList(),
  );
  List<PersonItem> get friends => _groupSorted(
    filteredPeople
        .where((p) => !p.isPinned && p.relationship == 'Friend')
        .toList(),
  );
  List<PersonItem> get partners => _groupSorted(
    filteredPeople
        .where((p) => !p.isPinned && p.relationship == 'Partner')
        .toList(),
  );
  List<PersonItem> get colleagues => _groupSorted(
    filteredPeople
        .where((p) => !p.isPinned && p.relationship == 'Colleague')
        .toList(),
  );
  List<PersonItem> get urgencyList =>
      _groupSorted(filteredPeople.where((p) => !p.isPinned).toList());
  void onSearchChanged(String v) => searchQuery.value = v;
  void onClearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
  void onFilterChanged(PeopleFilter mode) => filterMode.value = mode;
  void onWeekFocusTap() {
    filterMode.value = filterMode.value == PeopleFilter.thisWeek
        ? PeopleFilter.all
        : PeopleFilter.thisWeek;
  }
  Future<void> onSortToggle() async {
    sortByUrgency.value = !sortByUrgency.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sortPrefKey, sortByUrgency.value);
    } catch (_) {}
  }
  Future<void> onPersonTap(int id) async {
    await Get.toNamed('/person/detail', arguments: {'id': id});
    await loadData();
  }
  Future<void> onAddTap() async {
    await Get.toNamed('/person/add');
    await loadData();
  }
  Future<void> onAddDateTap(int personId) async {
    await Get.toNamed('/date/add', arguments: {'personId': personId});
    await loadData();
  }
  Future<void> onPinToggle(int id) async {
    try {
      final person = await _db.getPerson(id);
      if (person == null) return;
      final now = DateTime.now().toIso8601String();
      final updated = Person(
        id: person.id,
        name: person.name,
        relationship: person.relationship,
        avatarPath: person.avatarPath,
        notes: person.notes,
        isPinned: !person.isPinned,
        pinnedAt: !person.isPinned ? now : null,
        annualGiftBudget: person.annualGiftBudget,
        createdAt: person.createdAt,
      );
      await _db.updatePerson(updated);
      await loadData();
    } catch (e) {
      errorToast('Failed to update pin status');
    }
  }
  void onRelabelTap(int id, String current) {
    Get.bottomSheet(
      _buildRelabelSheet(id, current),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
  Widget _buildRelabelSheet(int id, String current) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D6D2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Change Relationship',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ..._relationships.map((rel) {
              final selected = rel == current;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  rel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? const Color(0xFFE4577C)
                        : const Color(0xFF1A1A1A),
                  ),
                ),
                trailing: selected
                    ? const Icon(
                        Icons.check,
                        color: Color(0xFFE4577C),
                        size: 20,
                      )
                    : null,
                onTap: () async {
                  Get.back();
                  if (rel != current) await _updateRelationship(id, rel);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  Future<void> _updateRelationship(int id, String relationship) async {
    try {
      final person = await _db.getPerson(id);
      if (person == null) return;
      final updated = Person(
        id: person.id,
        name: person.name,
        relationship: relationship,
        avatarPath: person.avatarPath,
        notes: person.notes,
        isPinned: person.isPinned,
        pinnedAt: person.pinnedAt,
        annualGiftBudget: person.annualGiftBudget,
        createdAt: person.createdAt,
      );
      await _db.updatePerson(updated);
      successToast('Relationship updated');
      await loadData();
    } catch (e) {
      errorToast('Failed to update relationship');
    }
  }
  void onDeleteTap(int id, String name) {
    Get.dialog(_buildDeleteDialog(id, name), barrierDismissible: true);
  }
  Widget _buildDeleteDialog(int id, String name) {
    return AlertDialog(
      title: const Text('Delete Contact'),
      content: Text(
        'Delete $name? All their dates, reminders, and gifts will also be deleted.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Get.back();
            await _confirmDelete(id);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
  Future<void> _confirmDelete(int id) async {
    try {
      final dates = await _db.getSpecialDatesByPersonId(id);
      for (final d in dates) {
        if (d.id != null) await _notif.cancelAllForDate(d.id!);
      }
      await _db.deletePerson(id);
      successToast('Contact deleted');
      await loadData();
    } catch (e) {
      errorToast('Failed to delete contact');
    }
  }
}
