import 'package:get/get.dart';
import 'day_butler_people_logic.dart';
class DayButlerPeopleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerPeopleLogic>(() => DayButlerPeopleLogic());
  }
}
