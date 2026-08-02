import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'day_butler_matrix_logic.dart';

class DayButlerMatrixView extends GetView<DayButlerMatrixLogic> {
  const DayButlerMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.upich.value
              ? const CircularProgressIndicator(color: Colors.pinkAccent)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.gtenv();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
