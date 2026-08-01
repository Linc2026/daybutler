import 'package:get/get.dart';
import 'day_butler_flowers_logic.dart';
class DayButlerFlowersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerFlowersLogic>(() => DayButlerFlowersLogic());
  }
}
