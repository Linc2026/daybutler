import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../components/text_field.dart';
import '../../main.dart';
import 'day_butler_add_wish_logic.dart';
class DayButlerAddWishView extends GetView<DayButlerAddWishLogic> {
  const DayButlerAddWishView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: GradientAppBar(
        automaticallyImplyLeading: false,
        leading: TextButton(onPressed: controller.onCancelTap, child: Text('Cancel', style: TextStyle(fontSize: 15.sp, color: primaryColor))),
        leadingWidth: 80.w,
        title: Text(controller.pageTitle, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.canSave && !controller.isSaving.value ? controller.onSaveTap : null,
            child: Text('Save', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: controller.canSave ? primaryColor : const Color(0xFFCCCCCC))),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 1))]),
          child: Column(children: [
            _formRow(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('CATEGORY'),
              SizedBox(height: 8.h),
              Obx(() => Wrap(spacing: 8.w, runSpacing: 6.h, children: controller.categories.map((c) => GestureDetector(
                onTap: () => controller.onCategorySelect(c),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: controller.category.value == c ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(color: controller.category.value == c ? primaryColor : const Color(0xFFE8DDD9), width: 1.5),
                  ),
                  child: Text(c, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: controller.category.value == c ? Colors.white : const Color(0xFF666666))),
                ),
              )).toList())),
            ]), isLast: false),
            _formRow(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('CONTENT', required: true),
              SizedBox(height: 6.h),
              Obx(() => MyTextField(
                value: controller.content.value,
                onChange: controller.onContentChanged,
                hintText: 'Write your wish...',
                maxLength: 300,
                maxLines: 6,
                minLines: 4,
                textStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A), height: 1.5),
              )),
              Obx(() => Align(
                alignment: Alignment.centerRight,
                child: Text('${controller.content.value.length} / 300', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF999999))),
              )),
            ]), isLast: true),
          ]),
        ),
      ),
    );
  }
  Widget _formRow({required Widget child, required bool isLast}) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: const Color(0xFFF0E6E2)))),
    child: child,
  );
  Widget _label(String label, {bool required = false}) => Row(children: [
    Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF999999), letterSpacing: 0.4)),
    if (required) Text(' *', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFE74C3C))),
  ]);
}
