import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../db_day_butler/db_day_butler_entity.dart';
import '../../theme/app_theme.dart';
import '../../utils/day_butler_helpers.dart';
import 'day_butler_gifts_logic.dart';
Color giftsStatusColor(String status) {
  switch (status) {
    case 'Purchased':
      return const Color(0xFF5B9BD5);
    case 'Gifted':
      return AppColors.success;
    default:
      return const Color(0xFFF39C12);
  }
}
String giftsReactionEmoji(String? reaction) {
  switch (reaction) {
    case 'loved':
      return '😍';
    case 'liked':
      return '😊';
    case 'okay':
      return '😐';
    case 'miss':
      return '😕';
    default:
      return '';
  }
}
Widget giftsAvatar(
  String name,
  String letter,
  int fallbackColor,
  double size,
  String? avatarPath,
) {
  final color = Color(resolveAvatarColor(name, avatarPath));
  final hasPhoto =
      isAvatarPhotoPath(avatarPath) && File(avatarPath!).existsSync();
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: hasPhoto ? Color(fallbackColor) : color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: (hasPhoto ? Color(fallbackColor) : color)
              .withValues(alpha: 0.22),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      image: hasPhoto
          ? DecorationImage(
              image: FileImage(File(avatarPath)),
              fit: BoxFit.cover,
            )
          : null,
    ),
    child: hasPhoto
        ? null
        : Center(
            child: Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: (size * 0.44).sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
  );
}
class GiftsSegmentTab extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  const GiftsSegmentTab({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _seg('Planner', Icons.checklist_rounded, 0),
            _seg('Guide', Icons.lightbulb_outline_rounded, 1),
          ],
        ),
      ),
    );
  }
  Widget _seg(String label, IconData icon, int idx) {
    final active = currentIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: active ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: active ? AppColors.primary : AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.text : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class GiftsSoftChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool compact;
  const GiftsSoftChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(right: compact ? 6.w : 8.w),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10.w : 13.w,
          vertical: compact ? 5.h : 7.h,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11.sp : 12.sp,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}
class GiftsOccasionGapBanner extends StatelessWidget {
  final List<OccasionGapItem> gaps;
  final void Function(OccasionGapItem) onAdd;
  const GiftsOccasionGapBanner({
    super.key,
    required this.gaps,
    required this.onAdd,
  });
  @override
  Widget build(BuildContext context) {
    if (gaps.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0E4), Color(0xFFFFF7F0)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 15.sp,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Coming up — no gift yet',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...gaps.map((g) => _gapRow(g)),
        ],
      ),
    );
  }
  Widget _gapRow(OccasionGapItem gap) {
    final when = gap.daysUntil == 0
        ? 'Today'
        : gap.daysUntil == 1
            ? 'Tomorrow'
            : 'in ${gap.daysUntil}d';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          giftsAvatar(
            gap.personName,
            gap.avatarLetter,
            gap.avatarColor,
            30.w,
            gap.avatarPath,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gap.personName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  '${gap.occasionLabel} · $when',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => onAdd(gap),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Add Idea',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class GiftsBudgetHeader extends StatelessWidget {
  final GiftGroupItem group;
  final bool showName;
  final bool compactCard;
  const GiftsBudgetHeader({
    super.key,
    required this.group,
    this.showName = true,
    this.compactCard = false,
  });
  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showName) ...[
              giftsAvatar(
                group.personName,
                group.avatarLetter,
                group.avatarColor,
                32.w,
                group.avatarPath,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.personName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (group.daysUntilNext >= 0 && group.daysUntilNext <= 30)
                      Text(
                        group.daysUntilNext == 0
                            ? 'Event today'
                            : 'Next in ${group.daysUntilNext}d',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ] else
              const Spacer(),
            Flexible(child: _budgetText()),
          ],
        ),
        if (group.budget != null) ...[
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: LinearProgressIndicator(
              value: group.budgetProgress,
              minHeight: 5.h,
              backgroundColor: AppColors.border,
              color: group.isOverBudget
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF5B9BD5),
            ),
          ),
        ],
      ],
    );
    if (!compactCard) return body;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: body,
    );
  }
  Widget _budgetText() {
    TextStyle style(Color c) => TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: c,
        );
    if (group.budget != null) {
      if (group.isOverBudget) {
        return Text(
          '\$${group.budgetUsed.toStringAsFixed(0)} · Over!',
          style: style(const Color(0xFFE74C3C)),
          textAlign: TextAlign.right,
        );
      }
      return Text(
        '\$${group.budgetUsed.toStringAsFixed(0)} / \$${group.budget!.toStringAsFixed(0)}',
        style: style(const Color(0xFF5B9BD5)),
        textAlign: TextAlign.right,
      );
    }
    if (group.budgetUsed > 0) {
      return Text(
        '\$${group.budgetUsed.toStringAsFixed(0)} spent',
        style: style(AppColors.textTertiary),
        textAlign: TextAlign.right,
      );
    }
    return const SizedBox.shrink();
  }
}
class GiftsGiftRow extends StatelessWidget {
  final GiftRowItem item;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onOpenLink;
  final void Function(int id) onMarkPurchased;
  final void Function(int id) onMarkGifted;
  final void Function(int id, String name) onDelete;
  const GiftsGiftRow({
    super.key,
    required this.item,
    required this.isLast,
    required this.onTap,
    this.onOpenLink,
    required this.onMarkPurchased,
    required this.onMarkGifted,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final gift = item.gift;
    final statusColor = giftsStatusColor(gift.status);
    return Slidable(
      key: ValueKey(gift.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.55,
        children: _actions(gift),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.9),
                      ),
                    ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 3.h),
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (gift.price != null ||
                          (gift.link != null && gift.link!.isNotEmpty))
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Row(
                            children: [
                              if (gift.price != null)
                                Text(
                                  '\$${gift.price!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSub,
                                  ),
                                ),
                              if (gift.link != null &&
                                  gift.link!.isNotEmpty) ...[
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: onOpenLink,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5B9BD5)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 11.sp,
                                          color: const Color(0xFF5B9BD5),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Link',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF5B9BD5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (item.occasionLabel != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            item.occasionLabel!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      if (gift.notes != null && gift.notes!.trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            gift.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ),
                      if (item.duplicateHint != null)
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.duplicateHint!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        gift.status,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (gift.reaction != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          giftsReactionEmoji(gift.reaction),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  List<SlidableAction> _actions(Gift gift) {
    final actions = <SlidableAction>[];
    if (gift.status == 'Idea') {
      actions.add(
        SlidableAction(
          onPressed: (_) => onMarkPurchased(gift.id!),
          backgroundColor: const Color(0xFF5B9BD5),
          foregroundColor: Colors.white,
          label: 'Buy',
          icon: Icons.check_rounded,
        ),
      );
    } else if (gift.status == 'Purchased') {
      actions.add(
        SlidableAction(
          onPressed: (_) => onMarkGifted(gift.id!),
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          label: 'Gift',
          icon: Icons.card_giftcard_rounded,
        ),
      );
    }
    actions.add(
      SlidableAction(
        onPressed: (_) => onDelete(gift.id!, gift.name),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        label: 'Delete',
        icon: Icons.delete_outline_rounded,
      ),
    );
    return actions;
  }
}
class GiftsSmartGuideChip extends StatelessWidget {
  final SmartGuideHint hint;
  final VoidCallback onApply;
  final VoidCallback onDismiss;
  const GiftsSmartGuideChip({
    super.key,
    required this.hint,
    required this.onApply,
    required this.onDismiss,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 10.w, 11.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primarySurface,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 15.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: GestureDetector(
              onTap: onApply,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart suggestion',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    hint.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onApply,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Apply',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onDismiss,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class GiftsGuideCard extends StatelessWidget {
  final GuideItem item;
  final String? duplicateHint;
  final VoidCallback? onAdd;
  const GiftsGuideCard({
    super.key,
    required this.item,
    this.duplicateHint,
    this.onAdd,
  });
  @override
  Widget build(BuildContext context) {
    final tags = <String>[
      ...item.raw.forTagsList.take(1),
      ...item.raw.occasionTagsList.take(1),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE8EF), Color(0xFFFFF7F5)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.raw.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  '\$${item.raw.priceMin}–\$${item.raw.priceMax}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: tags
                          .map(
                            (t) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSub,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  SizedBox(height: 6.h),
                  Expanded(
                    child: Text(
                      item.raw.description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSub,
                        height: 1.35,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  if (duplicateHint != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        duplicateHint!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  GestureDetector(
                    onTap: onAdd,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      decoration: BoxDecoration(
                        color: item.added
                            ? AppColors.bg
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(10.r),
                        border: item.added
                            ? Border.all(color: AppColors.border)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          item.added ? 'Added ✓' : 'Add to My List',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: item.added
                                ? AppColors.textTertiary
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}
class GiftsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? actions;
  const GiftsEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE8EF), Color(0xFFFFF4EC)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text('🎁', style: TextStyle(fontSize: 36.sp)),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actions != null) ...[
              SizedBox(height: 20.h),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}
class GiftsPersonPickerDialog extends StatelessWidget {
  final List<Person> people;
  final String? giftName;
  const GiftsPersonPickerDialog({
    super.key,
    required this.people,
    this.giftName,
  });
  @override
  Widget build(BuildContext context) {
    final listMaxH = 220.h;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 320.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE8EF), Color(0xFFFFF7F5)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 15.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add to list for...',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  if (giftName != null && giftName!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      giftName!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxH),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 4.h),
                itemCount: people.length,
                separatorBuilder: (_, _) => SizedBox(height: 4.h),
                itemBuilder: (_, i) {
                  final p = people[i];
                  final letter =
                      p.name.isNotEmpty ? p.name[0].toUpperCase() : '?';
                  final color = resolveAvatarColor(p.name, p.avatarPath);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(p.id),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.9),
                          ),
                        ),
                        child: Row(
                          children: [
                            giftsAvatar(
                              p.name,
                              letter,
                              color,
                              32.w,
                              p.avatarPath,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (p.relationship.isNotEmpty)
                                    Text(
                                      p.relationship,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18.sp,
                              color: AppColors.textDisabled,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 8.h),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSub,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
