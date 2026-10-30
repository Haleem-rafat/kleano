import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/points/bloc/point_bloc.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  @override
  void initState() {
    super.initState();
    sl<PointBloc>().add(GetUserPoints());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.myPoints),
        ),
      ),
      body: BlocBuilder<PointBloc, PointState>(
        builder: (context, state) {
          if (state is PointLoading) {
            return const Center(
              child: LoadingWidget(),
            );
          } else if (state is PointFailed) {
            return Container();
          } else if (state is PointLoaded) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 19.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26.w),
                  child: Container(
                    width: 323.w,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: ColorManager.black.withValues(alpha: .08),
                            blurRadius: 6.r,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 31.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 27.w),
                          child: Text(
                            translate(AppStrings.points),
                            style: AppStyles.title16Regular.copyWith(
                              color: ColorManager.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 27.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                sl<PointBloc>().pointResponse.points! >= 1000000
                                    ? "${sl<PointBloc>().pointResponse.points! / 1000000} M"
                                    : sl<PointBloc>().pointResponse.points! >=
                                            1000
                                        ? "${sl<PointBloc>().pointResponse.points! / 1000} K"
                                        : "${sl<PointBloc>().pointResponse.points!}",
                                style: AppStyles.title16Regular.copyWith(
                                    color: ColorManager.black,
                                    fontSize:
                                        sl<PointBloc>().pointResponse.points! >=
                                                1000000
                                            ? FontSize.s16
                                            : sl<PointBloc>()
                                                        .pointResponse
                                                        .points! >=
                                                    1000
                                                ? FontSize.s20
                                                : FontSize.s24),
                              ),
                              SizedBox(
                                width: 9.w,
                              ),
                              SvgPicture.asset(
                                AssetsManager.walletCoin,
                                height: 20.h,
                                width: 20.w,
                              ),
                              SizedBox(
                                width: 42.w,
                              ),
                              Text(
                                "=",
                                style: AppStyles.title16Regular.copyWith(
                                    color: ColorManager.darkGrey,
                                    fontSize: FontSize.s36),
                              ),
                              SizedBox(
                                width: 22.w,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      sl<PointBloc>()
                                                  .pointResponse
                                                  .pointsExchange! >=
                                              1000000
                                          ? "${(sl<PointBloc>().pointResponse.pointsExchange! / 1000000).toStringAsFixed(2)} M "
                                          : sl<PointBloc>()
                                                      .pointResponse
                                                      .pointsExchange! >=
                                                  1000
                                              ? "${(sl<PointBloc>().pointResponse.pointsExchange! / 1000).toStringAsFixed(2)} K "
                                              : "${sl<PointBloc>().pointResponse.pointsExchange!.toStringAsFixed(2)} ",
                                      style: AppStyles.title16Regular.copyWith(
                                          color: ColorManager.black,
                                          fontSize: sl<PointBloc>()
                                                      .pointResponse
                                                      .pointsExchange! >=
                                                  1000000
                                              ? FontSize.s16
                                              : sl<PointBloc>()
                                                          .pointResponse
                                                          .pointsExchange! >=
                                                      1000
                                                  ? FontSize.s20
                                                  : FontSize.s24),
                                    ),
                                    SvgPicture.asset(
                                      AssetsManager.saudiRiyalSymbol,
                                      height: sl<PointBloc>()
                                                  .pointResponse
                                                  .pointsExchange! >=
                                              1000000
                                          ? 16.h
                                          : sl<PointBloc>()
                                                      .pointResponse
                                                      .pointsExchange! >=
                                                  1000
                                              ? 20.h
                                              : 24.h,
                                      width: sl<PointBloc>()
                                                  .pointResponse
                                                  .pointsExchange! >=
                                              1000000
                                          ? 16.w
                                          : sl<PointBloc>()
                                                      .pointResponse
                                                      .pointsExchange! >=
                                                  1000
                                              ? 20.w
                                              : 24.w,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 27.w),
                          child: const Divider(
                            color: ColorManager.divider,
                            thickness: 1,
                          ),
                        ),
                        SizedBox(
                          height: 25.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "0 pt",
                                style: AppStyles.caption12Regular.copyWith(
                                  color: ColorManager.black,
                                ),
                              ),
                              Text(
                                "${sl<PointBloc>().pointResponse.redeemLimit!} pt",
                                style: AppStyles.caption12Regular.copyWith(
                                  color: ColorManager.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 27.w),
                          child: LinearPercentIndicator(
                            width: 265.w,
                            animation: false,
                            padding: EdgeInsets.zero,
                            lineHeight: 7.h,
                            animationDuration: 2500,
                            isRTL:
                                Localizations.localeOf(context).languageCode ==
                                        "en"
                                    ? false
                                    : true,
                            percent: sl<PointBloc>().pointResponse.points! /
                                        sl<PointBloc>()
                                            .pointResponse
                                            .redeemLimit! >
                                    1.0
                                ? 1.0
                                : sl<PointBloc>().pointResponse.points! /
                                    sl<PointBloc>().pointResponse.redeemLimit!,
                            barRadius: Radius.circular(5.r),
                            progressColor: ColorManager.secondary,
                          ),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 27.w),
                          child: Text(
                            "${translate(AppStrings.earn)} ${sl<PointBloc>().pointResponse.redeemLimit!} pt ${translate(AppStrings.moreToRedeemYourPoints)}",
                            style: AppStyles.caption12Regular.copyWith(
                              color: ColorManager.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            debugPrint("nnnn");
            return const Center(
              child: LoadingWidget(),
            );
          }
        },
      ),
    );
  }
}
