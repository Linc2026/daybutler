import 'package:get/get.dart';
import 'day_butler_tab_logic.dart';
class DayButlerTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerTabLogic>(() => DayButlerTabLogic());
  }
}
