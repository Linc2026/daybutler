import 'package:get/get.dart';
import 'day_butler_add_contact_logic.dart';
class DayButlerAddContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerAddContactLogic>(() => DayButlerAddContactLogic());
  }
}
