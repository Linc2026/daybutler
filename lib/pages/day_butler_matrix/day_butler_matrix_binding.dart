import 'package:get/get.dart';

import 'day_butler_matrix_logic.dart';

class DayButlerMatrixBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      DayButlerMatrixLogic(),
      permanent: true,
    );
  }
}
