import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'db_day_butler/index.dart';
import 'services/notification_service.dart';
import '../pages/day_butler_tab/day_butler_tab_view.dart';
import '../pages/day_butler_tab/day_butler_tab_binding.dart';
import '../pages/day_butler_home/day_butler_home_binding.dart';
import '../pages/day_butler_calendar/day_butler_calendar_binding.dart';
import '../pages/day_butler_people/day_butler_people_view.dart';
import '../pages/day_butler_people/day_butler_people_binding.dart';
import '../pages/day_butler_add_contact/day_butler_add_contact_view.dart';
import '../pages/day_butler_add_contact/day_butler_add_contact_binding.dart';
import '../pages/day_butler_contact_detail/day_butler_contact_detail_view.dart';
import '../pages/day_butler_contact_detail/day_butler_contact_detail_binding.dart';
import '../pages/day_butler_add_date/day_butler_add_date_view.dart';
import '../pages/day_butler_add_date/day_butler_add_date_binding.dart';
import '../pages/day_butler_gifts/day_butler_gifts_view.dart';
import '../pages/day_butler_gifts/day_butler_gifts_binding.dart';
import '../pages/day_butler_add_gift/day_butler_add_gift_view.dart';
import '../pages/day_butler_add_gift/day_butler_add_gift_binding.dart';
import '../pages/day_butler_settings/day_butler_settings_view.dart';
import '../pages/day_butler_settings/day_butler_settings_binding.dart';
import '../pages/day_butler_flowers/day_butler_flowers_view.dart';
import '../pages/day_butler_flowers/day_butler_flowers_binding.dart';
import '../pages/day_butler_add_flower/day_butler_add_flower_view.dart';
import '../pages/day_butler_add_flower/day_butler_add_flower_binding.dart';
import '../pages/day_butler_wishes/day_butler_wishes_view.dart';
import '../pages/day_butler_wishes/day_butler_wishes_binding.dart';
import '../pages/day_butler_add_wish/day_butler_add_wish_view.dart';
import '../pages/day_butler_add_wish/day_butler_add_wish_binding.dart';
import '../pages/day_butler_year_review/day_butler_year_review_view.dart';
import '../pages/day_butler_year_review/day_butler_year_review_binding.dart';
import 'theme/app_theme.dart';
Color get primaryColor => AppColors.primary;
Color get bgColor => AppColors.bg;
const _t = Transition.cupertino;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configure();
  await _initServices();
  runApp(const DayButlerApp());
}
Future<void> _configure() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}
Future<void> _initServices() async {
  await initDatabase();
  await NotificationService().init();
}
class DayButlerApp extends StatelessWidget {
  const DayButlerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => GetMaterialApp(
        title: 'Birthday Butler',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        getPages: Butler,
        initialRoute: '/tab',
        builder: (context, child) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        ),
      ),
    );
  }
}
List<GetPage<dynamic>> Butler = [
  GetPage(
    name: '/tab',
    page: () => const DayButlerTabView(),
    binding: DayButlerTabBinding(),
    bindings: [DayButlerHomeBinding(), DayButlerCalendarBinding()],
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/people',
    page: () => const DayButlerPeopleView(),
    binding: DayButlerPeopleBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/person/add',
    page: () => const DayButlerAddContactView(),
    binding: DayButlerAddContactBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/person/edit',
    page: () => const DayButlerAddContactView(),
    binding: DayButlerAddContactBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/person/detail',
    page: () => const DayButlerContactDetailView(),
    binding: DayButlerContactDetailBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/date/add',
    page: () => const DayButlerAddDateView(),
    binding: DayButlerAddDateBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/date/edit',
    page: () => const DayButlerAddDateView(),
    binding: DayButlerAddDateBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/gifts',
    page: () => const DayButlerGiftsView(),
    binding: DayButlerGiftsBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/gift/add',
    page: () => const DayButlerAddGiftView(),
    binding: DayButlerAddGiftBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/gift/edit',
    page: () => const DayButlerAddGiftView(),
    binding: DayButlerAddGiftBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/settings',
    page: () => const DayButlerSettingsView(),
    binding: DayButlerSettingsBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flowers',
    page: () => const DayButlerFlowersView(),
    binding: DayButlerFlowersBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flower/add',
    page: () => const DayButlerAddFlowerView(),
    binding: DayButlerAddFlowerBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/flower/edit',
    page: () => const DayButlerAddFlowerView(),
    binding: DayButlerAddFlowerBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/wishes',
    page: () => const DayButlerWishesView(),
    binding: DayButlerWishesBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/wish/add',
    page: () => const DayButlerAddWishView(),
    binding: DayButlerAddWishBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/wish/edit',
    page: () => const DayButlerAddWishView(),
    binding: DayButlerAddWishBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
  GetPage(
    name: '/year-review',
    page: () => const DayButlerYearReviewView(),
    binding: DayButlerYearReviewBinding(),
    transition: _t,
    popGesture: true,
    preventDuplicates: false,
  ),
];
