import 'package:get/get.dart';
import 'day_butler_home_logic.dart';
class DayButlerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerHomeLogic>(() => DayButlerHomeLogic());
  }
}
