import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/widget/services_widget.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, 60.h),
        child: const AppBarShared(
          titleAppBar: "TheWasher",
          isCenter: true,
          isTextOnly: false,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppPadding.p16.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                translate(AppStrings.offers),
                style: AppStyles.titleWhite16Bold
                    .copyWith(color: ColorManager.darkGrey),
              ),
            ),
            AppPadding.p12.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                height: 152.h,
                width: 334.w,
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        11.ph,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 99.h,
                              width: 211.w,
                              child: Image.asset(AssetsManager.offerCar),
                            ),
                            Column(
                              children: <Widget>[
                                AppPadding.p22.ph,
                                InkWell(
                                  onTap: () {
                                    pushPage(
                                      context,
                                      PlansAndSubscriptionScreen(
                                        profile: sl.call<GetUserProfileBloc>.call()
                                            .profile,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 26.h,
                                    width: 77.w,
                                    decoration: BoxDecoration(
                                      color: ColorManager.white,
                                      borderRadius: BorderRadius.circular(10.r),
                                      border:
                                          Border.all(color: ColorManager.white),
                                    ),
                                    child: Center(
                                      child: Text(
                                        translate(AppStrings.viewPlans),
                                        style: AppStyles.title16Bold.copyWith(
                                            color: ColorManager.darkGrey,
                                            fontSize: FontSize.s10.sp),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        10.ph,
                        SvgPicture.asset(AssetsManager.offerBookingSvg)
                      ],
                    ),
                    Positioned(
                      top: 21.h,
                      left: Localizations.localeOf(context).languageCode == 'en'
                          ? 173.w
                          : 34.w,
                      child: SizedBox(
                        height: 42.h,
                        width: 120.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Subscribe Now",
                              style: AppStyles.offerBigStyle
                                  .copyWith(color: ColorManager.white),
                            ),
                            AppSize.s1_5.ph,
                            Text(
                              "& get 30% off",
                              style: AppStyles.offerSmallStyle
                                  .copyWith(color: ColorManager.darkPrimary),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            AppPadding.p24.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                translate(AppStrings.services),
                style: AppStyles.titleWhite16Bold
                    .copyWith(color: ColorManager.darkGrey),
              ),
            ),
            AppPadding.p12.ph,
            SizedBox(
              height: 185.h,
              width: 1.sw,
              child: const ServicesWidget(),
            ),
            AppPadding.p24.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                translate(AppStrings.addOns),
                style: AppStyles.titleWhite16Bold
                    .copyWith(color: ColorManager.darkGrey),
              ),
            ),
            AppPadding.p12.ph,
            SizedBox(
              height: 182.h,
              width: 1.sw,
              child: BlocConsumer<OffersBloc, OffersState>(
                bloc: sl<OffersBloc>(),
                listener: (context, state) {},
                builder: (context, state) {
                  return ListView.separated(
                    itemCount: sl<OffersBloc>().addOnsList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return AppPadding.p8.pw;
                    },
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Container(
                          height: 182.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                              color: ColorManager.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: sl<OffersBloc>()
                                          .cartAddOnsList
                                          .contains(sl<OffersBloc>()
                                              .addOnsList[index])
                                      ? ColorManager.primary
                                      : ColorManager.white),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: ColorManager.black.withValues(alpha: .12),
                                    blurRadius: 2.r,
                                    offset: const Offset(0, 0))
                              ]),
                          child: Column(
                            children: <Widget>[
                              AppPadding.p24.ph,
                              ImageShared(
                                image: sl<OffersBloc>()
                                    .addOnsList[index]
                                    .icon!
                                    .iconLink!,
                                height: 50.h,
                                width: 50.w,
                              ),
                              25.ph,
                              Text(
                                sl<OffersBloc>().addOnsList[index].name!,
                                style: AppStyles.caption12Regular.copyWith(
                                    color: ColorManager.darkGrey,
                                    fontSize: FontSize.s10.sp),
                              ),
                              15.ph,
                              InkWell(
                                onTap: () {
                                  if (AppShared.token.isNotEmpty) {
                                    if (sl<OffersBloc>()
                                        .cartAddOnsList
                                        .contains(sl<OffersBloc>()
                                            .addOnsList[index])) {
                                      var deleteCartService = sl<OffersBloc>()
                                          .cartAddOnsList
                                          .indexOf(sl<OffersBloc>()
                                              .addOnsList[index]);
                                      sl<OffersBloc>().add(DeleteExtraCart(
                                          index: deleteCartService,
                                          extra: sl<OffersBloc>()
                                              .addOnsList[index]));
                                    } else {
                                      sl<OffersBloc>().add(AddExtraCart(
                                          extra: sl<OffersBloc>()
                                              .addOnsList[index]));
                                    }
                                  } else {
                                    AlertHelper.guestAlert(context);
                                  }
                                },
                                child: Container(
                                  width: 76.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: sl<OffersBloc>()
                                            .cartAddOnsList
                                            .contains(sl<OffersBloc>()
                                                .addOnsList[index])
                                        ? ColorManager.primary
                                        : ColorManager.white,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border:
                                        Border.all(color: ColorManager.primary),
                                  ),
                                  child: Center(
                                    child: sl<OffersBloc>()
                                            .cartAddOnsList
                                            .contains(sl<OffersBloc>()
                                                .addOnsList[index])
                                        ? const Icon(
                                            Icons.check,
                                            color: ColorManager.white,
                                            size: 15,
                                          )
                                        : Text(
                                            "+ ${sl<OffersBloc>().addOnsList[index].price} ${AppStrings.sAR}",
                                            style: AppStyles.subtext14Regular
                                                .copyWith(
                                                    color: ColorManager.primary,
                                                    fontSize: FontSize.s10.sp),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            AppPadding.p24.ph,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                translate(AppStrings.recentWashes),
                style: AppStyles.titleWhite16Bold
                    .copyWith(color: ColorManager.darkGrey),
              ),
            ),
            AppPadding.p12.ph,
            BlocBuilder<OffersBloc, OffersState>(
              bloc: sl<OffersBloc>(),
              builder: (context, state) {
                if (AppShared.token.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AppPadding.p20.ph,
                        SvgPicture.asset(
                          AssetsManager.emptyRecentWashesSvg,
                          height: 46.h,
                          width: 46.w,
                          fit: BoxFit.none,
                        ),
                        AppPadding.p12.ph,
                        Text(
                          translate(AppStrings.noWashesYet),
                          style: AppStyles.captionGray12Medium,
                        )
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            50.ph,
          ],
        ),
      ),
      bottomNavigationBar: AppShared.token.isEmpty
          ? null
          : Container(
              height: 104.h,
              width: 1.sw,
              decoration: BoxDecoration(
                  color: ColorManager.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: ColorManager.black.withValues(alpha: .16),
                        blurRadius: 10.r,
                        offset: const Offset(0, 3))
                  ]),
              child: BlocConsumer<OffersBloc, OffersState>(
                listener: (context, state) {
                  // Listener implementation for offers bloc state changes
                },
                builder: (context, state) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 31.h),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${sl<OffersBloc>().cartServicesList.length} * services - ${sl<OffersBloc>().cartAddOnsList.length} * Add-ons",
                              style: AppStyles.caption12Medium
                                  .copyWith(color: ColorManager.medGray),
                            ),
                            4.ph,
                            Text(
                              "Total Pay : ${sl<OffersBloc>().total}",
                              style: AppStyles.title16Bold
                                  .copyWith(color: ColorManager.darkGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
