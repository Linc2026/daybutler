import 'package:get/get.dart';
import 'day_butler_add_date_logic.dart';
class DayButlerAddDateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerAddDateLogic>(() => DayButlerAddDateLogic());
  }
}
