import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class EventsStepper extends StatefulWidget {
  final OrderModel order;
  final int orderIndex;
  const EventsStepper(
      {super.key, required this.order, required this.orderIndex});

  @override
  State<EventsStepper> createState() => _EventsStepperState();
}

class _EventsStepperState extends State<EventsStepper> {
  Color getStepColor(int index) {
    if (sl<HomeBloc>().orderStep == index) {
      return ColorManager.secondary;
    } else if (sl<HomeBloc>().orderStep > index) {
      return ColorManager.secondary;
    } else {
      return ColorManager.divider;
    }
  }

  String getStepName(int index) {
    if (index == 0) {
      return translate(AppStrings.onTheWayClient);
    } else if (index == 1) {
      return translate(AppStrings.arriveToClient);
    } else {
      return translate(AppStrings.startWashing);
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          translate(AppStrings.chooseBeforeWashPicture),
          style: AppStyles.title16Bold,
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              final XFile? image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                maxHeight: 800,
                maxWidth: 800,
                imageQuality: 100,
              );

              if (image != null && context.mounted) {
                sl<HomeBloc>().add(BikerOnWashingOrder(
                  orderId: widget.order.sId!,
                  orderIndex: widget.orderIndex,
                  context: context,
                  beforeWashImagePath: image.path,
                ));
              }
            },
            child: Text(
              translate(AppStrings.chooseFromGallery),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              final XFile? image = await ImagePicker().pickImage(
                source: ImageSource.camera,
                maxHeight: 800,
                maxWidth: 800,
                imageQuality: 80,
              );

              if (image != null && context.mounted) {
                sl<HomeBloc>().add(BikerOnWashingOrder(
                  orderId: widget.order.sId!,
                  orderIndex: widget.orderIndex,
                  context: context,
                  beforeWashImagePath: image.path,
                ));
              }
            },
            child: Text(
              translate(AppStrings.takeAPhoto),
              style: AppStyles.title16Regular
                  .copyWith(color: ColorManager.primary),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            translate(AppStrings.cancel),
            style:
                AppStyles.title16Regular.copyWith(color: ColorManager.darkGrey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, int index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: <Widget>[
                SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: Container(
                    height: 20.h,
                    width: 20.w,
                    decoration: BoxDecoration(
                      color: getStepColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (index != 2)
                  Container(
                    height: 57.h,
                    width: 4.w,
                    color: getStepColor(index),
                  )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getStepName(index),
                        style: AppStyles.caption12Regular
                            .copyWith(color: ColorManager.darkGrey),
                      ),
                      SizedBox(
                        height: 7.h,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Spacer(),
            Column(
              children: <Widget>[
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (BuildContext context, HomeState state) {
                    if ((state is BikerOnTheWayOrderLoading) &&
                        (index == 0) &&
                        (sl<HomeBloc>().orderStep == -1)) {
                      return LoadingWidget();
                    } else if ((state is BikerArrivedOrderLoading) &&
                        (index == 1) &&
                        (sl<HomeBloc>().orderStep == 0)) {
                      return LoadingWidget();
                    } else if ((state is BikerOnWashingOrderLoading) &&
                        (index == 2) &&
                        (sl<HomeBloc>().orderStep == 1)) {
                      return LoadingWidget();
                    } else {
                      return InkWell(
                        onTap: () {
                          if (index == 0 && sl<HomeBloc>().orderStep < 0) {
                            sl<HomeBloc>().add(BikerOnTheWayOrder(
                                orderId: widget.order.sId!,
                                orderIndex: widget.orderIndex,
                                context: context));
                          } else if (index == 1 &&
                              sl<HomeBloc>().orderStep < 1) {
                            sl<HomeBloc>().add(BikerArrivedOrder(
                                orderId: widget.order.sId!,
                                orderIndex: widget.orderIndex,
                                context: context));
                          } else if (index == 2 &&
                              sl<HomeBloc>().orderStep < 2) {
                            _showImagePickerDialog(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (index == 0 && sl<HomeBloc>().orderStep >= 0)
                                ? ColorManager.primary
                                : (index == 1 && sl<HomeBloc>().orderStep >= 1)
                                    ? ColorManager.primary
                                    : (index == 2 &&
                                            sl<HomeBloc>().orderStep >= 2)
                                        ? ColorManager.primary
                                        : ColorManager.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color:
                                  (index == 0 && sl<HomeBloc>().orderStep >= 0)
                                      ? ColorManager.primary
                                      : (index == 1 &&
                                              sl<HomeBloc>().orderStep >= 1)
                                          ? ColorManager.primary
                                          : (index == 2 &&
                                                  sl<HomeBloc>().orderStep >= 2)
                                              ? ColorManager.primary
                                              : ColorManager.darkGrey,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 7.h),
                            child: Text(
                              translate(AppStrings.done),
                              style: AppStyles.title16Bold.copyWith(
                                fontSize: FontSize.s10.sp,
                                color: (index == 0 &&
                                        sl<HomeBloc>().orderStep >= 0)
                                    ? ColorManager.white
                                    : (index == 1 &&
                                            sl<HomeBloc>().orderStep >= 1)
                                        ? ColorManager.white
                                        : (index == 2 &&
                                                sl<HomeBloc>().orderStep >= 2)
                                            ? ColorManager.white
                                            : ColorManager.darkGrey,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
