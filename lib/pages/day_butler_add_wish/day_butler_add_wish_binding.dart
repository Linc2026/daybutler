import 'package:get/get.dart';
import 'day_butler_add_wish_logic.dart';
class DayButlerAddWishBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerAddWishLogic>(() => DayButlerAddWishLogic());
  }
}
