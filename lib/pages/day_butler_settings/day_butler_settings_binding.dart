import 'package:get/get.dart';
import 'day_butler_settings_logic.dart';
class DayButlerSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerSettingsLogic>(() => DayButlerSettingsLogic());
  }
}
