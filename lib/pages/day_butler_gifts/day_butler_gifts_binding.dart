import 'package:get/get.dart';
import 'day_butler_gifts_logic.dart';
class DayButlerGiftsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerGiftsLogic>(() => DayButlerGiftsLogic());
  }
}
