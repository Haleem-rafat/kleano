import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class VechicleCardData extends StatelessWidget {
  final Vehicle vehicle;
  final bool? isScheduled;
  final DateTime? bookingDate;
  final DateTime? washingDate;
  const VechicleCardData({
    super.key,
    required this.vehicle,
    this.isScheduled = false,
    this.bookingDate,
    this.washingDate,
  });

  @override
  Widget build(BuildContext context) {
    int selectedColor = 0;
    selectedColor = colorList.indexWhere(
      (element) => element.colorName == vehicle.color,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${vehicle.brand!} ${vehicle.model}',
          style: AppStyles.body14Medium.copyWith(
            color: KColors.of(context).text,
          ),
        ),
        Divider(endIndent: 88.w, color: KColors.of(context).separator),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 90.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: KColors.of(context).surface,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: vehicle.imageLink!.isEmpty
                  ? const Icon(Icons.image)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: ImageShared(
                        image: vehicle.imageLink!,
                        width: 90.w,
                        height: 52.h,
                      ),
                    ),
            ),
            7.pw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RowInfoWidget(
                    title: translate(AppStrings.plateNo),
                    infoText: vehicle.plateNumber!,
                  ),
                  if (isScheduled != null ||
                      isScheduled == true ||
                      bookingDate != null ||
                      washingDate != null)
                    _bookingAndWashingDate(
                      bookingDate: bookingDate!,
                      washingDate: washingDate!,
                    ),
                  3.verticalSpace,
                  Row(
                    children: <Widget>[
                      Text(
                        translate(AppStrings.color),
                        style: AppStyles.caption12Regular.copyWith(
                          color: KColors.of(context).text,
                        ),
                      ),
                      6.pw,
                      Container(
                        height: 10.h,
                        width: 10.w,
                        decoration: BoxDecoration(
                          color:
                              colorList[selectedColor == -1 ? 0 : selectedColor]
                                  .color,
                          border: selectedColor == 0
                              ? Border.all(color: KColors.of(context).separator)
                              : null,
                          shape: BoxShape.circle,
                        ),
                      ),
                      4.pw,
                      Flexible(
                        child: Text(
                          vehicle.color!,
                          style: AppStyles.caption12Medium.copyWith(
                            color: KColors.of(context).text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _bookingAndWashingDate({
  required DateTime bookingDate,
  required DateTime washingDate,
}) {
  return Column(
    children: <Widget>[
      3.verticalSpace,
      RowInfoWidget(
        title: translate(AppStrings.bookingDate),
        infoText:
            '${AppDateFormatter.allDate(bookingDate)} ${AppDateFormatter.dateToStringHHMMA(bookingDate)}',
      ),
      3.verticalSpace,
      RowInfoWidget(
        title: translate(AppStrings.washingDate),
        infoText:
            '${AppDateFormatter.allDate(washingDate)} ${AppDateFormatter.dateToStringHHMMA(washingDate)}',
      ),
    ],
  );
}

class RowInfoWidget extends StatelessWidget {
  const RowInfoWidget({super.key, required this.title, required this.infoText});

  final String title;
  final String infoText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '${translate(title)} :',
          style: AppStyles.caption12Regular.copyWith(
            color: KColors.of(context).text,
            fontSize: 10.sp,
          ),
        ),
        6.pw,
        Flexible(
          child: Text(
            infoText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.caption12Medium.copyWith(
              color: KColors.of(context).text,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }
}
