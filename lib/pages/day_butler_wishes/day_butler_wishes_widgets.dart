import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../db_day_butler/db_day_butler_entity.dart';
import '../../theme/app_theme.dart';
import '../../utils/day_butler_helpers.dart';
Color wishCategoryColor(String cat) {
  switch (cat) {
    case 'Birthday':
      return const Color(0xFFE4577C);
    case 'Anniversary':
      return const Color(0xFF9B59B6);
    case "Valentine's":
      return const Color(0xFFE74C3C);
    case 'Christmas':
      return AppColors.success;
    default:
      return const Color(0xFF5B9BD5);
  }
}
String wishCategoryEmoji(String cat) {
  switch (cat) {
    case 'Birthday':
      return '🎂';
    case 'Anniversary':
      return '💕';
    case "Valentine's":
      return '💝';
    case 'Christmas':
      return '🎄';
    case 'Favorites':
      return '⭐';
    default:
      return '✨';
  }
}
class WishCopySheet extends StatelessWidget {
  final List<Person> people;
  final VoidCallback onCopyPlain;
  final ValueChanged<Person> onCopyForPerson;
  const WishCopySheet({
    super.key,
    required this.people,
    required this.onCopyPlain,
    required this.onCopyForPerson,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copy Wish',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Personalize with a name, or copy as plain text.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 18.h),
            Material(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(14.r),
              child: InkWell(
                onTap: onCopyPlain,
                borderRadius: BorderRadius.circular(14.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Copy plain text',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              'Just the wish content',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sp,
                        color: AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (people.isNotEmpty) ...[
              SizedBox(height: 18.h),
              Text(
                'COPY FOR SOMEONE',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 10.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 240.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: people.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (_, i) {
                    final p = people[i];
                    final color = Color(
                      resolveAvatarColor(p.name, p.avatarPath),
                    );
                    return Material(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14.r),
                      child: InkWell(
                        onTap: () => onCopyForPerson(p),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 11.h,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16.r,
                                backgroundColor: color,
                                child: Text(
                                  p.name.isNotEmpty
                                      ? p.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(
                                      p.relationship,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.favorite_rounded,
                                size: 16.sp,
                                color: AppColors.primary.withValues(alpha: 0.55),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class WishPersonFilterBar extends StatelessWidget {
  final List<Person> people;
  final int? selectedPersonId;
  final ValueChanged<int?> onPersonTap;
  const WishPersonFilterBar({
    super.key,
    required this.people,
    required this.selectedPersonId,
    required this.onPersonTap,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 5.w),
              Text(
                'FOR SOMEONE',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _anyoneChip(
                  active: selectedPersonId == null,
                  onTap: () => onPersonTap(null),
                ),
                ...people.map((p) {
                  final active = selectedPersonId == p.id;
                  final color = Color(
                    resolveAvatarColor(p.name, p.avatarPath),
                  );
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () => onPersonTap(p.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: EdgeInsets.fromLTRB(4.w, 4.h, 12.w, 4.h),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.bg,
                          borderRadius: BorderRadius.circular(100.r),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 11.r,
                              backgroundColor: active
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : color,
                              child: Text(
                                p.name.isNotEmpty
                                    ? p.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(width: 8.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _anyoneChip({required bool active, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.bg,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.all_inclusive_rounded,
                size: 13.sp,
                color: active ? Colors.white : AppColors.textTertiary,
              ),
              SizedBox(width: 5.w),
              Text(
                'Anyone',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class WishBestForBanner extends StatelessWidget {
  final String personName;
  final List<WishTemplate> wishes;
  final Widget Function(WishTemplate wish, {bool highlight}) buildCard;
  const WishBestForBanner({
    super.key,
    required this.personName,
    required this.wishes,
    required this.buildCard,
  });
  @override
  Widget build(BuildContext context) {
    if (wishes.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySurface,
            AppColors.primaryLight,
            AppColors.bg,
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 15.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best for $personName',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Top matches by relationship & tone',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...wishes.map(
            (w) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: buildCard(w, highlight: true),
            ),
          ),
        ],
      ),
    );
  }
}
class WishEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const WishEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 72.h),
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('💌', style: TextStyle(fontSize: 30.sp)),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
