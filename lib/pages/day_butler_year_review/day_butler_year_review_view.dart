import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../components/gradient_app_bar.dart';
import '../../main.dart';
import 'day_butler_year_review_logic.dart';
class DayButlerYearReviewView extends GetView<DayButlerYearReviewLogic> {
  const DayButlerYearReviewView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: GradientAppBar(
        title: Text(
          'Year in Review · ${controller.currentYear}',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.encouragementText.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          color: primaryColor,
          onRefresh: controller.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        '🎂',
                        'Birthdays\nRemembered',
                        '${controller.birthdaysRemembered.value}',
                        const Color(0xFFE4577C),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _statCard(
                        '🎁',
                        'Gifts\nGiven',
                        '${controller.giftsGiven.value}',
                        const Color(0xFF5B9BD5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        '💰',
                        'Total\nSpent',
                        controller.totalSpentFormatted,
                        const Color(0xFF2EAD6C),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _statCard(
                        '🌹',
                        'Flowers\nSent',
                        '${controller.flowersSent.value}',
                        const Color(0xFFE8A06A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _bigCard(
                  emoji: '⭐',
                  title: 'Most Remembered',
                  subtitle: controller.mostRememberedName.value,
                  detail: controller.mostRememberedRelationship.value,
                  color: const Color(0xFFF39C12),
                ),
                SizedBox(height: 12.h),
                _bigCard(
                  emoji: '📅',
                  title: 'Next Big Day',
                  subtitle: controller.nextBigDayText.value.isEmpty
                      ? 'No upcoming dates'
                      : controller.nextBigDayText.value,
                  detail: '',
                  color: const Color(0xFF9B59B6),
                ),
                SizedBox(height: 16.h),
                _buildEncouragement(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }
  Widget _buildEncouragement() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8EF), Color(0xFFFFF0F3)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        controller.encouragementText.value,
        style: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF444444),
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _statCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 26.sp)),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF888888),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
  Widget _bigCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String detail,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF888888),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
