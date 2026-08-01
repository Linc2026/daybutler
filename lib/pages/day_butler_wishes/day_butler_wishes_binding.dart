import 'package:get/get.dart';
import 'day_butler_wishes_logic.dart';
class DayButlerWishesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerWishesLogic>(() => DayButlerWishesLogic());
  }
}
