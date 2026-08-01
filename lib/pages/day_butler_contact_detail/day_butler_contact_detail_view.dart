import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/gradient_app_bar.dart';
import '../../main.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_contact_detail_logic.dart';
class DayButlerContactDetailView extends GetView<DayButlerContactDetailLogic> {
  const DayButlerContactDetailView({super.key});
  static const _cardShadow = [
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
  ];
  static const _softFill = Color(0xFFF5EBE6);
  static const _rowBorder = Color(0xFFF5EBE6);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: GradientAppBar(
        toolbarHeight: 44.h,
        leading: TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(left: 4.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left, size: 20.sp, color: primaryColor),
              Text(
                'People',
                style: TextStyle(fontSize: 14.sp, color: primaryColor),
              ),
            ],
          ),
        ),
        leadingWidth: 80.w,
        actions: [
          IconButton(
            onPressed: controller.onShareTap,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.share_outlined, size: 18.sp, color: primaryColor),
            tooltip: 'Share',
          ),
          TextButton(
            onPressed: controller.onEditTap,
            child: Text(
              'Edit',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildNextActionCard(),
                SizedBox(height: 12.h),
                _buildSpecialDatesSection(),
                SizedBox(height: 12.h),
                _buildGiftsSection(),
                SizedBox(height: 12.h),
                _buildPastGiftsSection(),
              ],
            ),
          ),
          Obx(() {
            if (controller.prepSheetItem.value == null) {
              return const SizedBox.shrink();
            }
            return _PrepSheet(controller: controller);
          }),
        ],
      ),
    );
  }
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
  Widget _buildProfileHeader() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          children: [
            Builder(
              builder: (_) {
                final path = controller.avatarPath.value;
                final color = Color(
                  resolveAvatarColor(controller.name.value, path),
                );
                final hasPhoto =
                    isAvatarPhotoPath(path) && File(path!).existsSync();
                return Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    image: hasPhoto
                        ? DecorationImage(
                            image: FileImage(File(path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: hasPhoto
                      ? null
                      : Center(
                          child: Text(
                            controller.avatarLetter.value,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                );
              },
            ),
            SizedBox(height: 10.h),
            Text(
              controller.name.value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8.h),
            _buildRelChip(controller.relationship.value),
            if (controller.notes.value.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                controller.notes.value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF999999),
                  height: 1.35,
                ),
              ),
            ],
            if (controller.showFunInfo.value) ...[
              SizedBox(height: 10.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                alignment: WrapAlignment.center,
                children: [
                  _buildSoftChip(controller.age.value),
                  _buildSoftChip(controller.zodiac.value),
                  _buildSoftChip(controller.chineseZodiac.value),
                ],
              ),
            ],
            Obx(() {
              final story = controller.anniversaryStory.value;
              if (story.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: GestureDetector(
                  onTap: controller.onCopyAnniversaryTap,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _softFill,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💑', style: TextStyle(fontSize: 13.sp)),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            story,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.copy_rounded,
                          size: 13.sp,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _buildNextActionCard() {
    return Obx(() {
      final action = controller.nextAction.value;
      if (action == null) return const SizedBox.shrink();
      return GestureDetector(
        onTap: controller.onNextActionTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: _cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(action.icon, size: 18.sp, color: primaryColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT ACTION',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF999999),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18.sp, color: const Color(0xFFBBBBBB)),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildSpecialDatesSection() {
    return Obx(
      () => _buildCard(
        child: Column(
          children: [
            _buildSectionHeader('Special Dates', controller.onAddDateTap),
            if (controller.specialDates.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Text(
                  'No dates yet. Tap + to add a birthday or anniversary.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF999999),
                    height: 1.4,
                  ),
                ),
              )
            else
              ...controller.specialDates.asMap().entries.map(
                    (e) => _buildDateRow(
                      e.value,
                      e.key == controller.specialDates.length - 1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
  Widget _buildDateRow(SpecialDateItem item, bool isLast) {
    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) =>
                controller.onDeleteDateTap(item.id, item.typeName),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => controller.onDateItemTap(item.id),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: _rowBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _softFill,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(item.icon, style: TextStyle(fontSize: 18.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.typeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${item.date} · ${item.countdown}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.openPrepSheet(item),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: 34.w,
                        height: 34.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 32.w,
                              height: 32.w,
                              child: CircularProgressIndicator(
                                value: item.prepTotal == 0
                                    ? 0
                                    : item.prepDone / item.prepTotal,
                                strokeWidth: 2.4,
                                backgroundColor: _softFill,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  item.prepDone == item.prepTotal
                                      ? const Color(0xFF2EAD6C)
                                      : primaryColor,
                                ),
                              ),
                            ),
                            Text(
                              '${item.prepDone}/${item.prepTotal}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: item.hasAlert
                                    ? primaryColor
                                    : const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.hasAlert)
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE74C3C),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildGiftsSection() {
    return Obx(
      () => _buildCard(
        child: Column(
          children: [
            _buildGiftsSectionHeader(),
            if (controller.budgetTotal.value != null) _buildBudgetBar(),
            if (controller.gifts.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Text(
                  'No gifts yet.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              )
            else
              ...controller.gifts.asMap().entries.map(
                    (e) => _buildGiftRow(
                      e.value,
                      e.key == controller.gifts.length - 1 &&
                          controller.totalGiftCount.value <= 3,
                    ),
                  ),
            if (controller.gifts.isNotEmpty) _buildViewAllLink(),
          ],
        ),
      ),
    );
  }
  Widget _buildGiftsSectionHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 8.h),
      child: Row(
        children: [
          Text(
            'Gifts',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Obx(() {
            final total = controller.budgetTotal.value;
            if (total == null) return const SizedBox.shrink();
            final over = controller.budgetUsed.value > total;
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                over
                    ? '\$${controller.budgetUsed.value.toStringAsFixed(0)} / \$${total.toStringAsFixed(0)} over'
                    : '\$${controller.budgetUsed.value.toStringAsFixed(0)} / \$${total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: controller.budgetLabelColor,
                ),
              ),
            );
          }),
          const Spacer(),
          _buildAddButton(controller.onAddGiftTap),
        ],
      ),
    );
  }
  Widget _buildBudgetBar() {
    return Obx(() {
      final total = controller.budgetTotal.value ?? 0.0;
      final pct = total > 0
          ? (controller.budgetUsed.value / total).clamp(0.0, 1.0)
          : 0.0;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4.h,
            backgroundColor: _softFill,
            valueColor:
                AlwaysStoppedAnimation<Color>(controller.budgetBarColor),
          ),
        ),
      );
    });
  }
  Widget _buildPastGiftsSection() {
    return Obx(() {
      final items = controller.pastGifts;
      return _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
              child: Text(
                'Past Gifts',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Text(
                  'No gifted history yet.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              )
            else
              ...items.asMap().entries.map((e) {
                final item = e.value;
                final isLast = e.key == items.length - 1;
                return GestureDetector(
                  onTap: () => controller.onPastGiftTap(item.id),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(color: _rowBorder),
                            ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            size: 16.sp,
                            color: const Color(0xFF2EAD6C),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${item.dateLabel} · ${item.priceDisplay}'
                                '${item.reaction != null && item.reaction!.isNotEmpty ? ' · ${item.reaction}' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: const Color(0xFFBBBBBB),
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
  Widget _buildGiftRow(GiftItem item, bool isLast) {
    return GestureDetector(
      onTap: () => controller.onGiftTap(item.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: _rowBorder)),
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: Color(item.dotColor),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.priceDisplay,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(item.status),
          ],
        ),
      ),
    );
  }
  Widget _buildViewAllLink() {
    return Obx(() {
      final extra = controller.totalGiftCount.value - controller.gifts.length;
      final label = extra > 0 ? 'View $extra more →' : 'View All Gifts →';
      return GestureDetector(
        onTap: controller.onViewAllGiftsTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _rowBorder)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 8.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _rowBorder)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          _buildAddButton(onAdd),
        ],
      ),
    );
  }
  Widget _buildAddButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.add_rounded, color: primaryColor, size: 16.sp),
      ),
    );
  }
  Widget _buildSoftChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _softFill,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF666666),
        ),
      ),
    );
  }
  Widget _buildRelChip(String rel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        rel,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
  Widget _buildStatusChip(String status) {
    final isIdea = status == 'Idea';
    final color = isIdea ? const Color(0xFFF39C12) : const Color(0xFF5B9BD5);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isIdea ? _softFill : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isIdea ? const Color(0xFF666666) : color,
        ),
      ),
    );
  }
}
class _PrepSheet extends StatelessWidget {
  final DayButlerContactDetailLogic controller;
  const _PrepSheet({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.prepSheetItem.value;
      if (item == null) return const SizedBox.shrink();
      final done = prepChecklistKeys
          .where((k) => controller.prepSheetMap[k] == true)
          .length;
      final total = prepChecklistKeys.length;
      return GestureDetector(
        onTap: controller.closePrepSheet,
        child: Container(
          color: Colors.black.withValues(alpha: 0.35),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0D6D2),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.typeName} · ${item.countdown}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.date,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: done == total
                              ? const Color(0xFFE8F8F0)
                              : const Color(0xFFF5EBE6),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          '$done / $total',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: done == total
                                ? const Color(0xFF2EAD6C)
                                : const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF5EBE6),
                      color: done == total
                          ? const Color(0xFF2EAD6C)
                          : primaryColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...prepChecklistKeys.map((key) {
                    final checked = controller.prepSheetMap[key] == true;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: GestureDetector(
                        onTap: () => controller.onTogglePrep(key, !checked),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EBE6),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 22.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  color: checked
                                      ? primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: checked
                                        ? primaryColor
                                        : const Color(0xFFE0D6D2),
                                    width: 1.5,
                                  ),
                                ),
                                child: checked
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 14.sp,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  prepChecklistLabels[key] ?? key,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    decoration: checked
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: const Color(0xFF999999),
                                    color: checked
                                        ? const Color(0xFF999999)
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    controller.onPrepActionTap(key),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: primaryColor,
                                ),
                                child: Text(
                                  'Go →',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
