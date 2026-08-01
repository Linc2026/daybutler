import 'package:get/get.dart';
import '../day_butler_calendar/day_butler_calendar_logic.dart';
import '../day_butler_gifts/day_butler_gifts_logic.dart';
import '../day_butler_home/day_butler_home_logic.dart';
import '../day_butler_settings/day_butler_settings_logic.dart';
class DayButlerTabLogic extends GetxController {
  final currentIndex = 0.obs;
  void onTabTap(int index) {
    final previous = currentIndex.value;
    currentIndex.value = index;
    if (previous == index) return;
    _refreshTab(index);
  }
  void _refreshTab(int index) {
    switch (index) {
      case 0:
        if (Get.isRegistered<DayButlerHomeLogic>()) {
          Get.find<DayButlerHomeLogic>().onResumed();
        }
        break;
      case 1:
        if (Get.isRegistered<DayButlerCalendarLogic>()) {
          Get.find<DayButlerCalendarLogic>().onResumed();
        }
        break;
      case 2:
        if (Get.isRegistered<DayButlerGiftsLogic>()) {
          Get.find<DayButlerGiftsLogic>().onResumed();
        }
        break;
      case 3:
        if (Get.isRegistered<DayButlerSettingsLogic>()) {
          Get.find<DayButlerSettingsLogic>().onResumed();
        }
        break;
    }
  }
}
