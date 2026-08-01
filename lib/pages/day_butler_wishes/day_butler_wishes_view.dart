import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../db_day_butler/db_day_butler_entity.dart';
import '../../theme/app_theme.dart';
import 'day_butler_wishes_logic.dart';
import 'day_butler_wishes_widgets.dart';
class DayButlerWishesView extends GetView<DayButlerWishesLogic> {
  const DayButlerWishesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: GradientAppBar(
        title: Text(
          'Wishes',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: AppColors.text,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: controller.onAddTap,
            child: Container(
              margin: EdgeInsets.only(right: 14.w),
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(child: _buildWishList()),
        ],
      ),
    );
  }
  Widget _buildFilterHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => WishPersonFilterBar(
              people: controller.allPeople.toList(),
              selectedPersonId: controller.selectedPersonId.value,
              onPersonTap: controller.onPersonTap,
            ),
          ),
          _buildCategoryFilter(),
        ],
      ),
    );
  }
  Widget _buildCategoryFilter() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.categories.map((c) {
              final selected = controller.selectedCategory.value == c;
              final emoji = c == 'All' ? null : wishCategoryEmoji(c);
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => controller.onCategoryTap(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.bg,
                      borderRadius: BorderRadius.circular(100.r),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (emoji != null) ...[
                          Text(emoji, style: TextStyle(fontSize: 11.sp)),
                          SizedBox(width: 4.w),
                        ],
                        Text(
                          c,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  Widget _buildWishList() {
    return Obx(() {
      final wishes = controller.filteredWishes;
      final person = controller.selectedPerson;
      final best = controller.bestForPerson;
      final showBest = person != null && best.isNotEmpty;
      if (wishes.isEmpty && !showBest) {
        final isFav = controller.selectedCategory.value == 'Favorites';
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              WishEmptyState(
                title: isFav
                    ? 'No favorites yet'
                    : controller.allWishes.isEmpty
                        ? 'No wishes yet'
                        : 'Nothing here',
                subtitle: isFav
                    ? 'Tap the star on any wish to save it here.'
                    : controller.allWishes.isEmpty
                        ? 'Tap + to write your first custom wish.'
                        : 'Try another category or person filter.',
              ),
            ],
          ),
        );
      }
      final bestIds = best.map((w) => w.id).toSet();
      final listWishes = showBest
          ? wishes.where((w) => !bestIds.contains(w.id)).toList()
          : wishes;
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, 12.h, 0, 28.h),
          children: [
            if (showBest)
              WishBestForBanner(
                personName: person.name,
                wishes: best,
                buildCard: (w, {highlight = false}) =>
                    _buildWishCard(w, highlight: highlight),
              ),
            if (listWishes.isNotEmpty && showBest)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                child: Text(
                  'MORE WISHES',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ...listWishes.map(
              (w) => Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
                child: _buildWishCard(w),
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildWishCard(WishTemplate wish, {bool highlight = false}) {
    final isCustom = !wish.isBuiltIn;
    final catColor = wishCategoryColor(wish.category);
    final person = controller.selectedPerson;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: highlight ? 0.06 : 0.03),
            blurRadius: highlight ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.w, color: catColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _categoryBadge(wish.category, catColor),
                        if (isCustom) ...[
                          SizedBox(width: 6.w),
                          _softBadge('Custom', AppColors.primary),
                        ],
                        if (highlight) ...[
                          SizedBox(width: 6.w),
                          _softBadge('Top pick', AppColors.primaryDark),
                        ],
                        const Spacer(),
                        _iconBtn(
                          icon: wish.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: wish.isFavorite
                              ? const Color(0xFFF5A623)
                              : AppColors.textDisabled,
                          onTap: () => controller.onFavoriteTap(wish),
                        ),
                        if (isCustom) ...[
                          _iconBtn(
                            icon: Icons.edit_rounded,
                            color: AppColors.textDisabled,
                            onTap: () => controller.onEditTap(wish.id!),
                          ),
                          _iconBtn(
                            icon: Icons.delete_outline_rounded,
                            color: AppColors.textDisabled,
                            onTap: () => controller.onDeleteTap(wish.id!),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '"${wish.content}"',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.text,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 34.h,
                      child: TextButton.icon(
                        onPressed: () => controller.onCopyTap(wish),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 15.sp,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          person != null
                              ? 'Copy for ${person.name}'
                              : 'Copy wish',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
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
    );
  }
  Widget _categoryBadge(String cat, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(wishCategoryEmoji(cat), style: TextStyle(fontSize: 10.sp)),
          SizedBox(width: 3.w),
          Text(
            cat,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  Widget _softBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(left: 6.w),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }
}
