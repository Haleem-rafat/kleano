import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/modules/profile/screens/account_screen.dart';
import 'package:thewhsherbiker/modules/profile/screens/biker_schedule.dart';
import 'package:thewhsherbiker/modules/profile/screens/settings_screen.dart';
import 'package:thewhsherbiker/modules/profile/widget/biker_status_switch.dart';
import 'package:thewhsherbiker/modules/profile/widget/logout_widget.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/date_joined_container.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/commission_container.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile_shimmering_screen.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    sl<ProfileBloc>().add(BikerGetTotalWashes(status: "COMPLETED"));
    sl<ProfileBloc>().add(BikerGetTotalCommission());
  }

  @override
  Widget build(BuildContext context) {
    final ProfileBloc _profileBloc = context.read<ProfileBloc>();
    final ProfileModel _profile = _profileBloc.profile;

    return Scaffold(
      backgroundColor: ColorManager.backGround,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: sl<ProfileBloc>(),
        builder: (BuildContext context, ProfileState state) {
          if (state is BikerProfileLoading) {
            return const ProfileShimmiring();
          } else {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildModernHeader(context, _profile),
                  24.verticalSpace,
                  BikerStatusSwitchWidget(),
                  32.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: <Widget>[
                        _buildStatsSection(_profile),
                        24.verticalSpace,
                        // Display Total Commission if available
                        if (_profile.totalCommission != null) ...[
                          _buildTotalCommissionSection(
                              _profile.totalCommission!),
                          24.verticalSpace,
                        ],
                        // CommissionContainer(
                        //   commission: _profile.commission?.toString() ?? "0",
                        //   minimumCommission:
                        //       _profile.minimumCommission?.toString() ?? "0",
                        //   ordersBeforeCommission:
                        //       _profile.ordersBeforeCommission?.toString() ??
                        //           "0",
                        // ),
                        // 24.verticalSpace,
                        if (_profile.createdAt != null)
                          DateJoinedContainer(
                            timeCreateAt: _profile.createdAt!,
                          ),
                      ],
                    ),
                  ),
                  32.verticalSpace,
                  _buildMenuSection(context),
                  32.verticalSpace,
                  LogOutWidget(),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, ProfileModel profile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.primary,
            ColorManager.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 16.h,
            bottom: 32.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: ColorManager.white,
                      size: 18.sp,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              24.verticalSpace,
              CircleImageShared(
                imageUrl: profile.imageLink ?? '',
                radius: 50.r,
                name: profile.userName ?? AppStrings.noName,
              ),
              16.verticalSpace,
              if (profile.userName != null)
                Text(
                  profile.userName!,
                  style: AppStyles.title24Bold.copyWith(
                    color: ColorManager.white,
                  ),
                ),
              if (profile.phone != null) ...[
                8.verticalSpace,
                Text(
                  profile.phone!,
                  style: AppStyles.subtext14Regular.copyWith(
                    color: ColorManager.white.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(ProfileModel profile) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildModernStatCard(
            icon: ImageAssets.ratingLogo,
            title: translate(AppStrings.rating),
            value: profile.rating != null
                ? profile.rating!.toStringAsFixed(1)
                : "0.0",
            showRating: true,
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _buildModernStatCard(
            icon: ImageAssets.totalWashesLogo,
            title: translate(AppStrings.totalWashes),
            value: profile.totalWashes?.toString() ?? "0",
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required String icon,
    required String title,
    required String value,
    bool showRating = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            icon,
            width: 32.w,
            height: 32.h,
          ),
          12.verticalSpace,
          Text(
            title,
            style: AppStyles.captionGray12Medium.copyWith(
              fontSize: FontSize.s12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,
          if (showRating)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  value,
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.darkGrey,
                    fontSize: FontSize.s20.sp,
                  ),
                ),
                4.horizontalSpace,
                SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: SvgPicture.asset(ImageAssets.starSelected),
                ),
              ],
            )
          else
            Text(
              value,
              style: AppStyles.title16Bold.copyWith(
                color: ColorManager.primary,
                fontSize: FontSize.s24.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildModernMenuItem(
            context: context,
            icon: Icons.calendar_today_outlined,
            title: translate(AppStrings.mySchedule),
            onTap: () => pushPage(context, BikerSchedule()),
          ),
          _buildDivider(),
          _buildModernMenuItem(
            context: context,
            icon: Icons.person_outline,
            title: translate(AppStrings.personalInformation),
            onTap: () => pushPage(context, AccountScreen()),
          ),
          _buildDivider(),
          _buildModernMenuItem(
            context: context,
            icon: Icons.settings_outlined,
            title: translate(AppStrings.settings),
            onTap: () => pushPage(context, SettingScreen()),
          ),
          _buildDivider(),
          _buildModernMenuItem(
            context: context,
            icon: Icons.info_outline,
            title: translate(AppStrings.aboutUs),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: ColorManager.primaryLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: ColorManager.primary,
                  size: 22.sp,
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.title16Regular.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: ColorManager.medGray,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Divider(
        height: 1,
        thickness: 1,
        color: ColorManager.divider2,
      ),
    );
  }

  Widget _buildTotalCommissionSection(TotalCommissionModel totalCommission) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: ColorManager.primaryLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SvgPicture.asset(
                  ImageAssets.walletCoin,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              12.horizontalSpace,
              Text(
                translate(AppStrings.totalCommission),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
            ],
          ),
          20.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: _buildModernCommissionItem(
                  translate(AppStrings.today),
                  '${totalCommission.today.totalCommission}',
                  '${totalCommission.today.ordersCount}',
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: _buildModernCommissionItem(
                  translate(AppStrings.allTime),
                  '${totalCommission.allTime.totalCommission}',
                  '${totalCommission.allTime.ordersCount}',
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: _buildModernCommissionItem(
                  translate(AppStrings.weekends),
                  '${totalCommission.allWeekends.totalCommission}',
                  '${totalCommission.allWeekends.ordersCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernCommissionItem(
      String label, String commission, String orders) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: ColorManager.gray,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            commission,
            style: AppStyles.title16Bold.copyWith(
              color: ColorManager.primary,
              fontSize: FontSize.s18.sp,
            ),
          ),
          6.verticalSpace,
          Text(
            label,
            style: AppStyles.captionGray12Medium.copyWith(
              fontSize: FontSize.s10.sp,
            ),
            textAlign: TextAlign.center,
          ),
          4.verticalSpace,
          Text(
            '$orders ${translate(AppStrings.orders)}',
            style: AppStyles.caption12Regular.copyWith(
              color: ColorManager.darkGrey,
              fontSize: FontSize.s10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
