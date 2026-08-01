import 'package:get/get.dart';
import 'day_butler_contact_detail_logic.dart';
class DayButlerContactDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerContactDetailLogic>(() => DayButlerContactDetailLogic());
  }
}
