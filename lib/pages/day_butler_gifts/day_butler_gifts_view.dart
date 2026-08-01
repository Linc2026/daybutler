import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../theme/app_theme.dart';
import 'day_butler_gifts_logic.dart';
import 'day_butler_gifts_widgets.dart';
class DayButlerGiftsView extends GetView<DayButlerGiftsLogic> {
  const DayButlerGiftsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: GradientAppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: Text(
          'Gifts',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.text,
          ),
        ),
        actions: [
          Obx(
            () => controller.currentTab.value == 0
                ? GestureDetector(
                    onTap: () => controller.onAddGiftTap(),
                    child: Container(
                      margin: EdgeInsets.only(right: 16.w),
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => GiftsSegmentTab(
              currentIndex: controller.currentTab.value,
              onChanged: controller.onTabSwitch,
            ),
          ),
          Expanded(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: controller.currentTab.value == 0
                    ? KeyedSubtree(
                        key: const ValueKey('planner'),
                        child: _buildPlanner(),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('guide'),
                        child: _buildGuide(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPlanner() {
    return Obx(() {
      final groups = controller.plannerGroups;
      final gaps = controller.occasionGaps;
      final personBudget = controller.filteredPersonBudget;
      return Column(
        children: [
          _buildPlannerFilterBar(),
          Expanded(
            child: groups.isEmpty && gaps.isEmpty
                ? (controller.hasAnyGifts
                      ? GiftsEmptyState(
                          title: 'Nothing here',
                          subtitle: 'No gifts match your filters.',
                        )
                      : _buildPlannerEmpty())
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 24.h),
                      children: [
                        GiftsOccasionGapBanner(
                          gaps: gaps,
                          onAdd: controller.onGapAddTap,
                        ),
                        if (controller.smartGuideHint.value != null)
                          GiftsSmartGuideChip(
                            hint: controller.smartGuideHint.value!,
                            onApply: controller.onApplySmartGuide,
                            onDismiss: controller.onDismissSmartGuide,
                          ),
                        if (!controller.showGroupHeaders &&
                            personBudget != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                            child: GiftsBudgetHeader(
                              group: personBudget,
                              showName: true,
                              compactCard: true,
                            ),
                          ),
                        if (groups.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.h),
                            child: controller.hasAnyGifts
                                ? GiftsEmptyState(
                                    title: 'Nothing here',
                                    subtitle: 'No gifts match your filters.',
                                  )
                                : const SizedBox.shrink(),
                          )
                        else
                          ...groups.map(_buildGiftGroup),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }
  Widget _buildPlannerFilterBar() {
    return Obx(
      () => Container(
        width: double.infinity,
        color: AppColors.surface,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.allPeople.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GiftsSoftChip(
                      label: 'All',
                      active: controller.filterPersonId.value == null,
                      onTap: () => controller.setFilterPerson(null),
                    ),
                    ...controller.allPeople.map(
                      (p) => GiftsSoftChip(
                        label: p.name,
                        active: controller.filterPersonId.value == p.id,
                        onTap: () => controller.onFilterPersonTap(p.id),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
            ],
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.statusOptions
                    .map(
                      (s) => GiftsSoftChip(
                        label: s,
                        active: controller.filterStatus.value == s,
                        onTap: () => controller.setFilterStatus(s),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGiftGroup(GiftGroupItem group) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.showGroupHeaders) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: GiftsBudgetHeader(group: group),
            ),
            SizedBox(height: 8.h),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.95),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: group.gifts
                  .asMap()
                  .entries
                  .map(
                    (e) => GiftsGiftRow(
                      item: e.value,
                      isLast: e.key == group.gifts.length - 1,
                      onTap: () => controller.onEditGiftTap(e.value.gift.id!),
                      onOpenLink: () =>
                          controller.onOpenLink(e.value.gift.link),
                      onMarkPurchased: controller.onMarkPurchased,
                      onMarkGifted: controller.onMarkGifted,
                      onDelete: controller.onDeleteGift,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPlannerEmpty() {
    return GiftsEmptyState(
      title: 'No gifts yet',
      subtitle: 'Add a gift or browse the Guide for some inspiration!',
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => controller.onAddGiftTap(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Add Gift',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 10.w),
          OutlinedButton(
            onPressed: controller.onBrowseGuideTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Browse Guide',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGuide() {
    return Obx(() {
      final items = controller.filteredGuide;
      final hint = controller.smartGuideHint.value;
      return Column(
        children: [
          if (hint != null)
            GiftsSmartGuideChip(
              hint: hint,
              onApply: controller.onApplySmartGuide,
              onDismiss: controller.onDismissSmartGuide,
            ),
          _buildGuideFilters(),
          Expanded(
            child: items.isEmpty
                ? GiftsEmptyState(
                    title: 'No matching ideas',
                    subtitle: 'Try adjusting your filters to see more ideas.',
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.loadData,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return GiftsGuideCard(
                          item: item,
                          duplicateHint: controller.guideDuplicateHint(item),
                          onAdd: item.added
                              ? null
                              : () => controller.onAddToList(item),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }
  Widget _buildGuideFilters() {
    return Obx(
      () => Container(
        color: AppColors.surface,
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
        child: Column(
          children: [
            _buildFilterRow(
              'For',
              controller.guideForOptions,
              controller.guideFilterFor.value,
              controller.setGuideFilterFor,
            ),
            SizedBox(height: 8.h),
            _buildFilterRow(
              'Occasion',
              controller.guideOccasionOptions,
              controller.guideFilterOccasion.value,
              controller.setGuideFilterOccasion,
            ),
            SizedBox(height: 8.h),
            _buildFilterRow(
              'Budget',
              controller.guideBudgetOptions,
              controller.guideFilterBudget.value,
              controller.setGuideFilterBudget,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFilterRow(
    String label,
    List<String> opts,
    String selected,
    Function(String) onTap,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 62.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: opts
                  .map(
                    (o) => GiftsSoftChip(
                      label: o,
                      active: selected == o,
                      onTap: () => onTap(o),
                      compact: true,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
