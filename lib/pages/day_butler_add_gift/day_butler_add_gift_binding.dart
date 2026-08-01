import 'package:get/get.dart';
import 'day_butler_add_gift_logic.dart';
class DayButlerAddGiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerAddGiftLogic>(() => DayButlerAddGiftLogic());
  }
}
