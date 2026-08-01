import 'package:get/get.dart';
import 'day_butler_add_flower_logic.dart';
class DayButlerAddFlowerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerAddFlowerLogic>(() => DayButlerAddFlowerLogic());
  }
}
