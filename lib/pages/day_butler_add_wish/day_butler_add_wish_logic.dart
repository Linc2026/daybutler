import 'package:get/get.dart';
import '../../db_day_butler/index.dart';
import '../../utils/index.dart';
class DayButlerAddWishLogic extends GetxController {
  final _db = db;
  final category = 'Birthday'.obs;
  final content = ''.obs;
  final isSaving = false.obs;
  int? _editId;
  String? _createdAt;
  bool _isBuiltIn = false;
  bool _isFavorite = false;
  bool get isEditMode => _editId != null;
  String get pageTitle => isEditMode ? 'Edit Wish' : 'New Wish';
  bool get canSave => content.value.trim().isNotEmpty && !_isBuiltIn;
  final categories = [
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
    if (args != null && args['id'] != null) {
      _editId = args['id'] as int;
      _loadExisting();
    }
  }
  Future<void> _loadExisting() async {
    try {
      final w = await _db.getWishTemplate(_editId!);
      if (w == null) {
        errorToast('Wish not found');
        Get.back();
        return;
      }
      if (w.isBuiltIn) {
        errorToast('Built-in wishes cannot be edited');
        Get.back();
        return;
      }
      _createdAt = w.createdAt;
      _isBuiltIn = w.isBuiltIn;
      _isFavorite = w.isFavorite;
      category.value = w.category;
      content.value = w.content;
    } catch (_) {
      errorToast('Failed to load wish');
    }
  }
  void onCategorySelect(String c) => category.value = c;
  void onContentChanged(String v) => content.value = v;
  Future<void> onSaveTap() async {
    if (!canSave || isSaving.value) return;
    if (_isBuiltIn) {
      errorToast('Built-in wishes cannot be edited');
      return;
    }
    isSaving.value = true;
    try {
      final now = DateTime.now().toIso8601String();
      final wish = WishTemplate(
        id: _editId,
        category: category.value,
        content: content.value.trim(),
        isBuiltIn: false,
        isFavorite: _isFavorite,
        createdAt: isEditMode ? (_createdAt ?? now) : now,
      );
      if (isEditMode) {
        final result = await _db.updateWishTemplate(wish);
        if (result == null) {
          errorToast('Failed to save wish');
          return;
        }
        successToast('Wish updated');
      } else {
        final result = await _db.insertWishTemplate(wish);
        if (result == null || result <= 0) {
          errorToast('Failed to save wish');
          return;
        }
        successToast('Wish added');
      }
      Get.back();
    } catch (e) {
      errorToast('Failed to save wish');
    } finally {
      isSaving.value = false;
    }
  }
  void onCancelTap() => Get.back();
}
