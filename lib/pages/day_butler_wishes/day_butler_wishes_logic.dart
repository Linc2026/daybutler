import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_day_butler/index.dart';
import '../../utils/day_butler_helpers.dart';
import '../../utils/index.dart';
import 'day_butler_wishes_widgets.dart';
class DayButlerWishesLogic extends GetxController {
  final _db = db;
  final allWishes = <WishTemplate>[].obs;
  final allPeople = <Person>[].obs;
  final selectedCategory = 'All'.obs;
  final selectedPersonId = Rxn<int>();
  final selectedPersonAge = Rxn<int>();
  final categories = [
    'All',
    'Favorites',
    'Birthday',
    'Anniversary',
    "Valentine's",
    'Christmas',
    'General',
  ];
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['category'] is String) {
        final cat = args['category'] as String;
        if (categories.contains(cat)) selectedCategory.value = cat;
      }
      if (args['personId'] is int) {
        selectedPersonId.value = args['personId'] as int;
      }
    }
    loadData();
  }
  void onResumed() => loadData();
  Person? get selectedPerson {
    final id = selectedPersonId.value;
    if (id == null) return null;
    return allPeople.firstWhereOrNull((p) => p.id == id);
  }
  Future<void> loadData() async {
    try {
      allWishes.value = await _db.getWishTemplates();
      allPeople.value = await _db.getPeople();
      final pid = selectedPersonId.value;
      if (pid != null) {
        if (allPeople.every((p) => p.id != pid)) {
          selectedPersonId.value = null;
          selectedPersonAge.value = null;
        } else {
          await _loadPersonAge(pid);
        }
      }
    } catch (e) {
      errorToast('Failed to load wishes');
    }
  }
  Future<void> _loadPersonAge(int personId) async {
    try {
      final bday = await _db.getBirthdayByPersonId(personId);
      selectedPersonAge.value = bday == null ? null : calcAge(bday.date);
    } catch (_) {
      selectedPersonAge.value = null;
    }
  }
  List<WishTemplate> get filteredWishes {
    var list = allWishes.toList();
    final cat = selectedCategory.value;
    if (cat == 'Favorites') {
      list = list.where((w) => w.isFavorite).toList();
    } else if (cat != 'All') {
      list = list.where((w) => w.category == cat).toList();
    }
    final person = selectedPerson;
    if (person != null && cat == 'Birthday') {
      list = rankBirthdayWishes(
        list,
        relationship: person.relationship,
        age: selectedPersonAge.value,
      );
    }
    final favs = list.where((w) => w.isFavorite).toList();
    final rest = list.where((w) => !w.isFavorite).toList();
    return [...favs, ...rest];
  }
  List<WishTemplate> get bestForPerson {
    final person = selectedPerson;
    if (person == null) return [];
    final cat = selectedCategory.value;
    if (cat != 'All' && cat != 'Birthday' && cat != 'Favorites') return [];
    var birthday = allWishes.where((w) => w.category == 'Birthday').toList();
    if (cat == 'Favorites') {
      birthday = birthday.where((w) => w.isFavorite).toList();
    }
    if (birthday.isEmpty) return [];
    final ranked = rankBirthdayWishes(
      birthday,
      relationship: person.relationship,
      age: selectedPersonAge.value,
    );
    return ranked.take(3).toList();
  }
  void onCategoryTap(String cat) => selectedCategory.value = cat;
  Future<void> onPersonTap(int? id) async {
    if (selectedPersonId.value == id) {
      selectedPersonId.value = null;
      selectedPersonAge.value = null;
      return;
    }
    selectedPersonId.value = id;
    if (id != null) await _loadPersonAge(id);
  }
  Future<void> onFavoriteTap(WishTemplate wish) async {
    if (wish.id == null) return;
    final next = !wish.isFavorite;
    try {
      final result = await _db.setWishFavorite(wish.id!, next);
      if (result == null || result == 0) {
        errorToast('Failed to update favorite');
        return;
      }
      final idx = allWishes.indexWhere((w) => w.id == wish.id);
      if (idx >= 0) {
        allWishes[idx] = wish.copyWith(isFavorite: next);
        allWishes.refresh();
      }
    } catch (_) {
      errorToast('Failed to update favorite');
    }
  }
  Future<void> onCopyTap(WishTemplate wish) async {
    final person = selectedPerson;
    if (person != null) {
      await _copyForPerson(wish, person, markWished: true);
      return;
    }
    await Get.bottomSheet(
      WishCopySheet(
        people: allPeople.toList(),
        onCopyPlain: () {
          Get.back();
          copyToClipboard(wish.content);
        },
        onCopyForPerson: (p) async {
          Get.back();
          await _copyForPerson(wish, p, markWished: true);
        },
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
    );
  }
  Future<void> _copyForPerson(
    WishTemplate wish,
    Person person, {
    required bool markWished,
  }) async {
    final text = formatWishPreview(
      category: wish.category,
      personName: person.name,
      content: wish.content,
    );
    copyToClipboard(text);
    if (markWished && wish.category == 'Birthday' && person.id != null) {
      await _markWished(person.id!);
    }
  }
  Future<void> _markWished(int personId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(wishedTodayKey(personId), true);
    } catch (_) {}
  }
  Future<void> onAddTap() async {
    await Get.toNamed('/wish/add');
    await loadData();
  }
  Future<void> onEditTap(int id) async {
    await Get.toNamed('/wish/edit', arguments: {'id': id});
    await loadData();
  }
  void onDeleteTap(int id) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Wish'),
      content: const Text('Delete this wish?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Get.back();
            try {
              final result = await _db.deleteWishTemplate(id);
              if (result == null || result == 0) {
                errorToast('Failed to delete');
                return;
              }
              successToast('Wish deleted');
              await loadData();
            } catch (_) {
              errorToast('Failed to delete');
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}
