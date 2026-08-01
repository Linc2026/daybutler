import 'package:get/get.dart';
import 'day_butler_year_review_logic.dart';
class DayButlerYearReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DayButlerYearReviewLogic>(() => DayButlerYearReviewLogic());
  }
}
