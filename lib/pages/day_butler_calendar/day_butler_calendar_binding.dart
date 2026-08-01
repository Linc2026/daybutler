import 'package:get/get.dart';
import 'day_butler_calendar_logic.dart';
class DayButlerCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerCalendarLogic>(() => DayButlerCalendarLogic());
  }
}
