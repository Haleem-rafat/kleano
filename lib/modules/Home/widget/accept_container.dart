import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/core/utilis/launch_map.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class AcceptContainer extends StatelessWidget {
  final OrderModel acceptOrder;
  final int index;
  const AcceptContainer(
      {Key? key, required this.acceptOrder, required this.index})
      : super(key: key);

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) {
      return;
    }

    final String cleanedPhone =
        phone.replaceAll('+', '').replaceAll(' ', '').trim();
    final String whatsappNumber =
        cleanedPhone.startsWith('966') ? cleanedPhone : '966$cleanedPhone';
    final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showCancelDialog() {
      if (acceptOrder.sId == null) {
        return;
      }
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext ctx) => CupertinoActionSheet(
          title: Text(
            translate(AppStrings.cancelOrder),
            style: AppStyles.title16Bold,
          ),
          message: Text(
            translate(AppStrings.cancelOrderConfirmation),
            style: AppStyles.title16Regular,
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                sl<HomeBloc>().add(BikerCancelOrder(
                  orderId: acceptOrder.sId!,
                  orderIndex: index,
                  context: context,
                ));
              },
              isDestructiveAction: true,
              child: Text(
                translate(AppStrings.confirm),
                style:
                    AppStyles.title16Regular.copyWith(color: ColorManager.red),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              translate(AppStrings.cancel),
              style: AppStyles.title16Regular,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        pushPage(
            context,
            OrderDetailsScreen(
              data: acceptOrder,
              complete: true,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: acceptOrder.isAssigned!
              ? ColorManager.secondary
              : ColorManager.darkGrey,
          borderRadius: BorderRadius.all(Radius.circular(15.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 10.h,
            ),
            acceptOrder.isAssigned!
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          translate(AppStrings.adminRequest),
                          style: AppStyles.caption12Regular.copyWith(
                            color: ColorManager.white,
                            fontSize: FontSize.s10.sp,
                          ),
                        ),
                        Text(
                          "${translate(AppStrings.washTime)} ${acceptOrder.washingServices!.first.duration}",
                          style: AppStyles.caption12Regular.copyWith(
                            color: ColorManager.white,
                            fontSize: FontSize.s10.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    "${translate(AppStrings.washTime)} ${AppDateFormatter.allDate(acceptOrder.startTime!)} ${AppDateFormatter.dateToStringHHMMA(acceptOrder.startTime!)}",
                    style: AppStyles.caption12Regular.copyWith(
                      color: ColorManager.white,
                      fontSize: FontSize.s10.sp,
                    ),
                  ),
            SizedBox(
              height: 10.h,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 326.8.w,
                decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: ColorManager.black.withOpacity(.08),
                          blurRadius: 6.r,
                          offset: const Offset(0, 3))
                    ]),
                padding: EdgeInsets.symmetric(horizontal: 22.5.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 8.h,
                    ),
                    Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            print("llll ${acceptOrder.sId}");
                          },
                          child: Text(
                            "${acceptOrder.vehicle!.brand} ${acceptOrder.vehicle!.model}",
                            style: AppStyles.body14Medium.copyWith(
                              color: ColorManager.darkGrey,
                            ),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            launchUrl(Uri(
                              scheme: 'tel',
                              path: acceptOrder.user!.phone,
                            ));
                          },
                          child: SvgPicture.asset(ImageAssets.phoneLogo),
                        ),
                        16.horizontalSpace,
                        InkWell(
                          onTap: () => _openWhatsApp(acceptOrder.user?.phone),
                          child: SvgPicture.asset(
                            "assets/svg/whatsapp_icon.svg",
                            height: 20.h,
                            width: 20.w,
                            color: const Color(0xFF25D366),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Row(
                      children: <Widget>[
                        acceptOrder.user?.imageLink != null
                            ? CircleImageShared(
                                imageUrl: acceptOrder.user!.imageLink ?? '',
                                radius: 12.r,
                                name: acceptOrder.user!.userName!,
                              )
                            : CircleAvatar(
                                radius: 12.r,
                                backgroundColor: ColorManager.primaryLight,
                                child: Text(
                                  acceptOrder.user!.userName!.split('').first,
                                  style: AppStyles.title16Bold.copyWith(
                                    color: ColorManager.secondary,
                                    fontSize: FontSize.s10.sp,
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: 8.w,
                        ),
                        InkWell(
                          onTap: () {
                            print("kkkk ${acceptOrder.user!.sId}");
                          },
                          child: Text(
                            acceptOrder.user?.userName ?? "N/A",
                            style: AppStyles.title16Regular.copyWith(
                                // color: ColorManager.medGray,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    InkWell(
                      onTap: () async {
                        await launchMap(
                            lat: acceptOrder.location?.latitude?.toString() ??
                                "",
                            long: acceptOrder.location?.longitude?.toString() ??
                                "");
                      },
                      child: Row(
                        textBaseline: TextBaseline.alphabetic,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          SvgPicture.asset(ImageAssets.locationIcon),
                          Expanded(
                            child: Text(
                              acceptOrder.location?.streetName ?? "N/A",
                              style: AppStyles.title16Regular.copyWith(
                                  // color: ColorManager.medGray,
                                  ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.verticalSpace,
                    Container(
                      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 5.h),
                      decoration: BoxDecoration(
                        color: orderStateColor(acceptOrder.status!),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        orderStateName(acceptOrder.status!),
                        style: AppStyles.caption12Regular
                            .copyWith(color: ColorManager.darkGrey),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(createRoute(OrderChangeStatus(
                          order: acceptOrder,
                          index: index,
                          notification: false,
                        )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorManager.primaryLight,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: ColorManager.primary),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 6.h, horizontal: 22.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              translate(AppStrings.washProgress),
                              style: AppStyles.body14Medium
                                  .copyWith(color: ColorManager.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    // BlocBuilder<HomeBloc, HomeState>(
                    //   bloc: sl<HomeBloc>(),
                    //   builder: (BuildContext context, HomeState state) {
                    //     final bool isLoading =
                    //         state is BikerCancelOrderLoading &&
                    //             state.orderId == acceptOrder.sId;
                    //     return InkWell(
                    //       onTap: isLoading || acceptOrder.sId == null
                    //           ? null
                    //           : _showCancelDialog,
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           color: ColorManager.red.withOpacity(0.08),
                    //           borderRadius: BorderRadius.circular(8.r),
                    //           border:
                    //               Border.all(color: ColorManager.red, width: 1),
                    //         ),
                    //         padding: EdgeInsets.symmetric(
                    //             vertical: 6.h, horizontal: 22.w),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: <Widget>[
                    //             if (isLoading)
                    //               SizedBox(
                    //                 height: 16.r,
                    //                 width: 16.r,
                    //                 child: CircularProgressIndicator(
                    //                   strokeWidth: 2,
                    //                   valueColor: AlwaysStoppedAnimation<Color>(
                    //                       ColorManager.red),
                    //                 ),
                    //               )
                    //             else
                    //               Text(
                    //                 translate(AppStrings.cancelOrder),
                    //                 style: AppStyles.body14Medium.copyWith(
                    //                   color: ColorManager.red,
                    //                 ),
                    //               ),
                    //           ],
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),

                    SizedBox(
                      height: 16.73.h,
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
}
