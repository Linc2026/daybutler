import 'package:get/get.dart';
import 'data.dart';
Future<void> initDatabase() async {
  await Get.putAsync<DayButlerDatabase>(() async {
    final db = DayButlerDatabase();
    await db.database;
    return db;
  });
}
DayButlerDatabase get db => Get.find<DayButlerDatabase>();
