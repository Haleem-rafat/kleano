import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PointsExplanationScreen extends StatefulWidget {
  const PointsExplanationScreen({super.key});

  @override
  State<PointsExplanationScreen> createState() =>
      _PointsExplanationScreenState();
}

class _PointsExplanationScreenState extends State<PointsExplanationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backGround,
      appBar: AppBar(
        title: Text(
          translate(AppStrings.howPointsWorks),
          style: AppStyles.title16Bold.copyWith(
            color: ColorManager.black,
          ),
        ),
        backgroundColor: ColorManager.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorManager.black,
            size: 20.w,
          ),
          onPressed: () => pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            height: 1.h,
            color: ColorManager.divider,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Hero Animation Container
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorManager.primary,
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/point.json',
                      repeat: true,
                      width: 80.w,
                      height: 80.h,
                    ),
                  ),
                ),
                24.ph,

                // Main Title
                Text(
                  translate(AppStrings.howPointsWorks),
                  style: AppStyles.title24Bold.copyWith(
                    color: ColorManager.black,
                    fontSize: 28.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                16.ph,

                // Subtitle
                Text(
                  'Earn rewards with every service you book',
                  style: AppStyles.body14Medium.copyWith(
                    color: ColorManager.medGray,
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                40.ph,

                // Features Cards
                _buildFeatureCard(
                  icon: Icons.trending_up_rounded,
                  title: translate(AppStrings.watchPointsGrow),
                  description: translate(AppStrings.certainNumberPoints),
                  color: ColorManager.primary,
                ),
                20.ph,

                _buildFeatureCard(
                  icon: Icons.card_giftcard_rounded,
                  title: translate(AppStrings.redeemPoints),
                  description: translate(AppStrings.certainAmountPoints),
                  color: ColorManager.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28.w,
            ),
          ),
          16.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.black,
                  ),
                ),
                8.ph,
                Text(
                  description,
                  style: AppStyles.subtext14Regular.copyWith(
                    color: ColorManager.medGray,
                    height: 1.4,
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
