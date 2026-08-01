import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../components/gradient_app_bar.dart';
import '../../main.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_people_logic.dart';
class DayButlerPeopleView extends GetView<DayButlerPeopleLogic> {
  const DayButlerPeopleView({super.key});
  static const _cardShadow = [
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
  ];
  static const _softFill = Color(0xFFF5EBE6);
  static const _divider = Color(0xFFF5EBE6);
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
              Text('Home', style: TextStyle(fontSize: 14.sp, color: primaryColor)),
            ],
          ),
        ),
        leadingWidth: 72.w,
        title: Obx(() => _buildTitle()),
        actions: [
          Obx(() => IconButton(
                onPressed: controller.onSortToggle,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  controller.sortByUrgency.value ? Icons.sort : Icons.account_tree_outlined,
                  color: primaryColor,
                  size: 20.sp,
                ),
              )),
          IconButton(
            onPressed: controller.onAddTap,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add_circle, color: primaryColor, size: 24.sp),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Obx(() {
        final pinned = controller.pinned;
        final byUrgency = controller.sortByUrgency.value;
        final urgencyList = controller.urgencyList;
        final family = controller.family;
        final friends = controller.friends;
        final partners = controller.partners;
        final colleagues = controller.colleagues;
        final radar = controller.careRadarPeople;
        final empty = controller.filteredPeople.isEmpty;
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              _buildSearchBar(),
              SizedBox(height: 8.h),
              _buildFilterChips(),
              if (radar.isNotEmpty &&
                  controller.filterMode.value == PeopleFilter.all &&
                  controller.searchQuery.value.isEmpty) ...[
                SizedBox(height: 8.h),
                _buildCareRadar(radar),
              ],
              if (empty)
                _buildEmptyState()
              else if (byUrgency) ...[
                if (pinned.isNotEmpty) ...[
                  _buildGroupLabel('⭐ Pinned'),
                  _buildGroupBlock(pinned),
                ],
                if (urgencyList.isNotEmpty) ...[
                  _buildGroupLabel('By Urgency'),
                  _buildGroupBlock(urgencyList),
                ],
              ] else ...[
                if (pinned.isNotEmpty) ...[
                  _buildGroupLabel('⭐ Pinned'),
                  _buildGroupBlock(pinned),
                ],
                if (family.isNotEmpty) ...[
                  _buildGroupLabel('Family'),
                  _buildGroupBlock(family),
                ],
                if (friends.isNotEmpty) ...[
                  _buildGroupLabel('Friend'),
                  _buildGroupBlock(friends),
                ],
                if (partners.isNotEmpty) ...[
                  _buildGroupLabel('Partner'),
                  _buildGroupBlock(partners),
                ],
                if (colleagues.isNotEmpty) ...[
                  _buildGroupLabel('Colleague'),
                  _buildGroupBlock(colleagues),
                ],
              ],
            ],
          ),
        );
      }),
    );
  }
  Widget _buildTitle() {
    final count = controller.weekFocusCount;
    final active = controller.filterMode.value == PeopleFilter.thisWeek;
    return GestureDetector(
      onTap: count > 0 ? controller.onWeekFocusTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('People', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          if (count > 0) ...[
            SizedBox(width: 6.w),
            Container(
              constraints: BoxConstraints(minWidth: 18.w),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: active ? primaryColor : primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildCard({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: _cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
  Widget _buildSearchBar() {
    final hasQuery = controller.searchQuery.value.isNotEmpty;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: hasQuery ? primaryColor.withOpacity(0.12) : _softFill,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.search_rounded,
              color: hasQuery ? primaryColor : const Color(0xFFB8A9A2),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              cursorColor: primaryColor,
              style: TextStyle(fontSize: 15.sp, color: const Color(0xFF1A1A1A), height: 1.2),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search by name...',
                hintStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFFB8A9A2), height: 1.2),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (hasQuery) ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: controller.onClearSearch,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: _softFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, color: const Color(0xFF999999), size: 14.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildFilterChips() {
    final items = <(PeopleFilter, String)>[
      (PeopleFilter.all, 'All'),
      (PeopleFilter.thisWeek, 'This week'),
      (PeopleFilter.noDates, 'No dates'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 4.h,
        children: items.map((e) {
          final selected = controller.filterMode.value == e.$1;
          return _buildChip(e.$2, selected, () => controller.onFilterChanged(e.$1));
        }).toList(),
      ),
    );
  }
  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? primaryColor : _softFill,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
  Widget _buildCareRadar(List<PersonItem> radar) {
    return _buildCard(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryColor, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'COMING UP',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${radar.length}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: primaryColor),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 88.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: radar.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (_, i) {
                  final p = radar[i];
                  final isToday = p.daysUntilNext == 0;
                  return GestureDetector(
                    onTap: () => controller.onPersonTap(p.id),
                    child: Container(
                      width: 72.w,
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                      decoration: BoxDecoration(
                        color: isToday ? primaryColor.withOpacity(0.08) : _softFill,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar(p.name, p.avatarLetter, p.avatarColor, 36.w, p.avatarPath),
                          SizedBox(height: 4.h),
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                              height: 1.2,
                            ),
                          ),
                          Text(
                            isToday ? 'Today' : '${p.daysUntilNext}d',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGroupLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 16.w, 6.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF999999),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  Widget _buildGroupBlock(List<PersonItem> people) {
    return _buildCard(
      child: Column(
        children: people.asMap().entries.map((e) => _buildPersonRow(e.value, e.key == people.length - 1)).toList(),
      ),
    );
  }
  Widget _buildPersonRow(PersonItem person, bool isLast) {
    return Slidable(
      key: ValueKey(person.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42,
        children: [
          SlidableAction(
            onPressed: (_) => controller.onPinToggle(person.id),
            backgroundColor: const Color(0xFFF39C12),
            foregroundColor: Colors.white,
            icon: person.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
            label: person.isPinned ? 'Unpin' : 'Pin',
            padding: EdgeInsets.zero,
          ),
          SlidableAction(
            onPressed: (_) => controller.onDeleteTap(person.id, person.name),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => controller.onPersonTap(person.id),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: isLast ? null : const Border(bottom: BorderSide(color: _divider)),
          ),
          child: Row(
            children: [
              if (person.isPinned) ...[
                Text('★', style: TextStyle(fontSize: 13.sp, color: const Color(0xFFF39C12))),
                SizedBox(width: 6.w),
              ],
              _buildAvatar(person.name, person.avatarLetter, person.avatarColor, 42.w, person.avatarPath),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildRelChip(person.id, person.relationship),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: person.hasDates
                              ? Text(
                                  person.upcoming,
                                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : GestureDetector(
                                  onTap: () => controller.onAddDateTap(person.id),
                                  child: Text(
                                    'Add date',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE8A06A),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: const Color(0xFFBBBBBB), size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildRelChip(int personId, String rel) {
    Color chipColor;
    switch (rel) {
      case 'Family':
        chipColor = const Color(0xFFF39C12);
        break;
      case 'Friend':
        chipColor = const Color(0xFF5B9BD5);
        break;
      case 'Partner':
        chipColor = primaryColor;
        break;
      default:
        chipColor = const Color(0xFF9B59B6);
    }
    return GestureDetector(
      onLongPress: () => controller.onRelabelTap(personId, rel),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: chipColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          rel,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: chipColor),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    final searching = controller.searchQuery.value.isNotEmpty;
    final filtering = controller.filterMode.value != PeopleFilter.all;
    if (searching || filtering) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
        child: Center(
          child: Text(
            searching
                ? 'No results for "${controller.searchQuery.value}"'
                : 'No people match this filter',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999), height: 1.5),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildCard(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: _softFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.people_alt_outlined, size: 24.sp, color: primaryColor),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No people yet',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Start with family birthdays',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF999999)),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: TextButton(
                      onPressed: controller.onAddTap,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text('Add someone', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: _cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: primaryColor, size: 16.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Pin VIPs, filter this week, and jump into dates in one tap.',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAvatar(
    String name,
    String letter,
    int fallbackColor,
    double size,
    String? avatarPath,
  ) {
    final color = Color(resolveAvatarColor(name, avatarPath));
    final hasPhoto = isAvatarPhotoPath(avatarPath) && File(avatarPath!).existsSync();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasPhoto ? Color(fallbackColor) : color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (hasPhoto ? Color(fallbackColor) : color).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        image: hasPhoto
            ? DecorationImage(image: FileImage(File(avatarPath)), fit: BoxFit.cover)
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (size * 0.4).sp,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
    );
  }
}
