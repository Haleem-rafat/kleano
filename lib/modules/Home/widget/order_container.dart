import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/user_details_widget.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OrderContainer extends StatelessWidget {
  final int index;
  const OrderContainer({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.darkGrey,
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 11.h,
          ),
          Text(
            "${translate(AppStrings.arrivedTime)} ${sl<HomeBloc>().orderList[index].startTime != null ? AppDateFormatter.allDate(sl<HomeBloc>().orderList[index].startTime!) + ' ' + AppDateFormatter.dateToStringHHMMA(sl<HomeBloc>().orderList[index].startTime!.toLocal()) : ''}",
            style: AppStyles.caption12Regular.copyWith(
              color: ColorManager.white,
              fontSize: FontSize.s10.sp,
            ),
          ),
          SizedBox(
            height: 11.h,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.all(Radius.circular(15.r)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: ColorManager.black.withOpacity(.08),
                        blurRadius: 6.r,
                        offset: const Offset(0, 3))
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 24.h,
                  ),
                  UserDetailsWidget(
                    userData: sl<HomeBloc>().orderList[index],
                    textStyle: AppStyles.title16Bold,
                  ),
                  SizedBox(
                    height: 11.h,
                  ),
                  if (sl<HomeBloc>().orderList[index].bookingDate != null)
                    RowInfoWidget(
                      title: translate(AppStrings.washingDate),
                      infoText:
                          '${AppDateFormatter.allDateWithDayName(sl<HomeBloc>().orderList[index].startTime!)} ${AppDateFormatter.dateToStringHHMMA(sl<HomeBloc>().orderList[index].startTime!.toLocal())}',
                    ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: ButtonsShared(
                          height: 30.h,
                          // width: 128.w,
                          showShadow: false,
                          onPressed: () {
                            pushPage(
                                context,
                                OrderDetailsScreen(
                                    data: sl<HomeBloc>().orderList[index],
                                    complete: false,
                                    index: index));
                          },
                          text: translate(AppStrings.viewDetails),
                          colorText: ColorManager.primary,
                          colorButton: ColorManager.white,
                          borderRadius: 8,
                          textStyle: AppStyles.body14Medium,
                        ),
                      ),
                      15.horizontalSpace,
                      BlocBuilder<HomeBloc, HomeState>(
                        builder: (BuildContext context, HomeState state) {
                          if ((state is BikerAcceptOrderLoading) &&
                              (index == sl<HomeBloc>().selected)) {
                            return LoadingWidget();
                          } else {
                            return Expanded(
                              child: ButtonsShared(
                                height: 30.h,
                                // width: 128.w,
                                showShadow: false,
                                onPressed: () {
                                  if (sl<AuthBloc>().currentPosition !=
                                      LatLng(0, 0)) {
                                    sl<HomeBloc>().add(BikerAcceptOrder(
                                      context: context,
                                      orderId:
                                          sl<HomeBloc>().orderList[index].sId!,
                                      orderIndex: index,
                                      lat: sl<AuthBloc>()
                                          .currentPosition
                                          .latitude
                                          .toString(),
                                      lng: sl<AuthBloc>()
                                          .currentPosition
                                          .longitude
                                          .toString(),
                                      streetName: sl<AuthBloc>().currentAddress,
                                      subAdministrativeArea:
                                          sl<AuthBloc>().administrativeArea,
                                      details: false,
                                    ));
                                  }
                                },
                                text: translate(AppStrings.accept),
                                borderRadius: 8,
                                textStyle: AppStyles.body14Medium,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 24.h,
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
