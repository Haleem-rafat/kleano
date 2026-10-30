import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/user_details_widget.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/screens/order_details_screen.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/utilties/app_date_formatter.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class CompletedCard extends StatelessWidget {
  final OrderModel order;
  const CompletedCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pushPage(context, OrderDetailsScreen(data: order, complete: true));
      },
      child: Container(
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
              AppDateFormatter.dateFormate(order.createdAt!),
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
                width: 326.6.w,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 24.h,
                    ),
                    UserDetailsWidget(
                      userData: order,
                      textStyle: AppStyles.title16Bold,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ButtonsShared(
                        height: 30.h,
                        width: 130.w,
                        onPressed: () {
                          pushPage(context,
                              OrderDetailsScreen(data: order, complete: true));
                        },
                        text: translate(AppStrings.viewDetails),
                        colorText: ColorManager.primary,
                        colorButton: ColorManager.white,
                        borderRadius: 8,
                        showShadow: false,
                        textStyle: AppStyles.body14Medium,
                      ),
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
      ),
    );
  }
}
