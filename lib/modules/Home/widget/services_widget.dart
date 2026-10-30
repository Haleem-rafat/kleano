import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class ServicesWidget extends StatelessWidget {
  const ServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OffersBloc, OffersState>(
      bloc: sl<OffersBloc>(),
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GetServicesLoading || state is GetGuestServicesLoading) {
          return const LoadingWidget();
        }
        if (state is EmptyServices || state is EmptyGuestServices) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Container(
              height: 182.h,
              width: 316.w,
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: <Widget>[
                   AppPadding.p8.ph,
                  Lottie.asset(
                    'assets/empty.json',
                    repeat: true,
                    width: 103.w,
                    height: 69.h,
                  ),
                  AppPadding.p8.ph,
                  Text(
                    translate(AppStrings.ourServicesNotAvailable),
                    style: AppStyles.caption12Regular,
                  )
                ],
              ),
            ),
          );
        } else {
          return ListView.separated(
            itemCount: sl<OffersBloc>().servicesList.length,
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
                          color: sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])
                              ? ColorManager.primary
                              : ColorManager.white),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: ColorManager.black.withValues(alpha: .12), blurRadius: 2.r, offset: const Offset(0, 0))
                      ]),
                  child: Column(
                    children: <Widget>[
                      AppPadding.p24.ph,
                      ImageShared(
                        image: sl<OffersBloc>().servicesList[index].icon!.iconLink!,
                        height: 50.h,
                        width: 50.w,
                      ),
                      AppPadding.p25.ph,
                      Text(
                        sl<OffersBloc>().servicesList[index].name!,
                        style: AppStyles.caption12Regular.copyWith(color: ColorManager.darkGrey, fontSize: FontSize.s10.sp),
                      ),
                      15.ph,
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
                              ),
                              backgroundColor: Colors.white,
                              context: context,
                              elevation: 0,
                              useRootNavigator: true,
                              enableDrag: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
                                  return SizedBox(
                                      height: 370.h,
                                      child: Column(
                                        children: <Widget>[
                                          45.ph,
                                          Container(
                                            height: 80.h,
                                            width: 323.w,
                                            decoration: BoxDecoration(
                                                color: ColorManager.white,
                                                borderRadius: BorderRadius.circular(15.r),
                                                boxShadow: <BoxShadow>[
                                                  BoxShadow(
                                                      color: ColorManager.black.withValues(alpha: .08),
                                                      blurRadius: 6.r,
                                                      offset: const Offset(0, 3))
                                                ]),
                                            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 14.h),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  height: 50.h,
                                                  width: 50.w,
                                                  decoration: BoxDecoration(
                                                    color: ColorManager.gray,
                                                    borderRadius: BorderRadius.circular(5.r),
                                                  ),
                                                  padding: const EdgeInsets.all(10),
                                                  child: ColorFiltered(
                                                    colorFilter: ColorFilter.mode(ColorManager.secondary, BlendMode.color),
                                                    child: Image.network(
                                                      sl<OffersBloc>().servicesList[index].icon!.iconLink!,
                                                    ),
                                                  ),
                                                ),
                                                AppPadding.p9.pw,
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      sl<OffersBloc>().servicesList[index].name!,
                                                      style: AppStyles.body14Medium.copyWith(color: ColorManager.darkGrey),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        SvgPicture.asset(
                                                          AssetsManager.timeIconLogo,
                                                        ),
                                                        AppPadding.p12.pw,
                                                        Text(
                                                          "${sl<OffersBloc>().servicesList[index].duration!} ${sl<OffersBloc>().servicesList[index].durationUnit!} service",
                                                          style: AppStyles.caption12Medium.copyWith(color: ColorManager.medGray),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        SvgPicture.asset(
                                                          AssetsManager.serviceCoinSvg,
                                                        ),
                                                        AppPadding.p12.pw,
                                                        Text(
                                                          "\$${sl<OffersBloc>().servicesList[index].price!}",
                                                          style: AppStyles.caption12Medium.copyWith(color: ColorManager.medGray),
                                                        ),
                                                        AppPadding.p12.pw,
                                                        /*Row(
                                                          children: <Widget>[
                                                            SvgPicture.asset(
                                                              AssetsManager.walletCoin,
                                                            ),
                                                            Text(
                                                              "\$${sl<OffersBloc>().servicesList[index].pointsToPay!}",
                                                              style: AppStyles.caption12Medium.copyWith(color: ColorManager.medGray),
                                                            ),
                                                          ],
                                                        )*/
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          AppPadding.p24.ph,
                                          SizedBox(
                                            height: 100.h,
                                            child: ListView.separated(
                                              itemCount: sl<OffersBloc>().servicesList[index].description!.length,
                                              separatorBuilder: (BuildContext context, int index) {
                                                return AppSize.s1_5.ph;
                                              },
                                              padding: EdgeInsets.symmetric(horizontal: 49.w),
                                              itemBuilder: (context, descriptionIndex) {
                                                return Row(
                                                  children: <Widget>[
                                                    const Icon(
                                                      Icons.check,
                                                      color: ColorManager.darkGrey,
                                                    ),
                                                    13.pw,
                                                    Text(
                                                      sl<OffersBloc>().servicesList[index].description![descriptionIndex],
                                                      style: AppStyles.subtext14Regular.copyWith(color: ColorManager.darkGrey),
                                                    )
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          AppPadding.p24.ph,
                                          InkWell(
                                            onTap: () {
                                              if (AppShared.token.isNotEmpty) {
                                                if (sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])) {
                                                  var deleteCartService =
                                                      sl<OffersBloc>().cartServicesList.indexOf(sl<OffersBloc>().servicesList[index]);
                                                  sl<OffersBloc>().add(DeleteServiceCart(
                                                      index: deleteCartService, service: sl<OffersBloc>().servicesList[index]));
                                                } else {
                                                  sl<OffersBloc>().add(AddServiceCart(service: sl<OffersBloc>().servicesList[index]));
                                                }
                                                mystate(() {});
                                              } else {
                                                AlertHelper.guestAlert(context);
                                              }
                                            },
                                            child: Container(
                                              width: 327.w,
                                              height: 50.h,
                                              decoration: BoxDecoration(
                                                  color: sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])
                                                      ? ColorManager.primary
                                                      : ColorManager.primaryLight,
                                                  borderRadius: BorderRadius.circular(25.r),
                                                  border: Border.all(color: ColorManager.primary),
                                                  boxShadow: <BoxShadow>[
                                                    BoxShadow(color: ColorManager.primaryLight, blurRadius: 6.r, offset: const Offset(0, 3))
                                                  ]),
                                              child: Center(
                                                child: Text(
                                                  sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])
                                                      ? translate(AppStrings.serviceBooked)
                                                      : translate(AppStrings.bookService),
                                                  style: AppStyles.title16Bold.copyWith(
                                                      color:
                                                          sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])
                                                              ? ColorManager.white
                                                              : ColorManager.primary),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ));
                                });
                              });
                        },
                        child: Container(
                          width: 76.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])
                                ? ColorManager.primary
                                : ColorManager.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: ColorManager.primary),
                          ),
                          child: Center(
                            child: sl<OffersBloc>().cartServicesList.contains(sl<OffersBloc>().servicesList[index])
                                ? const Icon(
                                    Icons.check,
                                    color: ColorManager.white,
                                    size: 15,
                                  )
                                : Text(
                                    translate(AppStrings.viewDetails),
                                    style: AppStyles.subtext14Regular.copyWith(color: ColorManager.primary, fontSize: FontSize.s10.sp),
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
        }
      },
    );
  }
}
