import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/event_stepper.dart';
import 'package:thewhsherbiker/modules/Home/widget/order_user_details.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/modules/order/widgets/button_complete_wash.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class StatusOrderBottomSheet extends StatefulWidget {
  final OrderModel order;
  final int index;
  const StatusOrderBottomSheet(
      {super.key, required this.order, required this.index});

  @override
  State<StatusOrderBottomSheet> createState() => _StatusOrderBottomSheetState();
}

class _StatusOrderBottomSheetState extends State<StatusOrderBottomSheet> {
  void _showCancelDialog() {
    final String? orderId = widget.order.sId;
    if (orderId == null) {
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
                orderId: orderId,
                orderIndex: widget.index,
                context: context,
              ));
            },
            isDestructiveAction: true,
            child: Text(
              translate(AppStrings.confirm),
              style: AppStyles.title16Regular.copyWith(color: ColorManager.red),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          20.verticalSpace,
          Align(
            child: Container(
              height: 10.h,
              width: 104.w,
              decoration: BoxDecoration(
                  color: ColorManager.medGray,
                  borderRadius: BorderRadius.circular(999.r)),
            ),
          ),
          OrderUserDetails(),
          SizedBox(
            height: 20.h,
          ),
          EventsStepper(
            order: widget.order,
            orderIndex: widget.index,
          ),
          31.verticalSpace,
          // ActionSlider.standard(
          //   height: 50.h,

          //   child: Text('Slide to confirm'),
          //   action: (controller) async {
          //     controller.loading(); //starts loading animation
          //     await Future.delayed(const Duration(seconds: 3));
          //     controller.success();
          //   },
          //   //many more parameters
          // ),
          //       ActionSlider.standard(
          //   height: 50,
          //   child: Text('Slide to confirm', style: TextStyle(fontSize: 16)),
          //   action: (controller) async {
          //     controller.loading(); // Starts loading animation
          //     await Future.delayed(const Duration(seconds: 3)); // Simulate a task
          //     controller.success(); // Show success state
          //   },
          //   backgroundColor: ColorManager.medGray,

          //   // successIcon: Container(
          //   //   height: 50.h,
          //   //   width: 227.w,
          //   //   decoration: BoxDecoration(
          //   //     borderRadius: BorderRadius.circular(25.r),
          //   //     color: ColorManager.primary,
          //   //   ),
          //   // )
          //   //  Icon(Icons.check, color: Colors.white),
          //   // loadingIcon: CircularProgressIndicator(color: Colors.white),// How long to show success state
          // )
          // SizedBox(
          //     // height: 50.h,
          //     child: SliderButton(
          //   // height: 50.0,
          //   // buttonSize: 40.w,
          //   // height: 50.h,
          //   width: 327.w,
          //   buttonSize: 90.r,
          //   // baseColor: Colors.red,
          //   disable: isCompleted ? true : false,
          //   // buttonColor: Colors.blue,
          //   backgroundColor: isCompleted ? ColorManager.primary : ColorManager.medGray,
          //   // highlightedColor: Colors.amber,
          //   action: () async {
          //     ///Do something here OnSlide
          //     // return true;
          //     debugPrint("working");
          //     return isCompleted == true ? false : true;
          //   },
          //   label: Text(
          //     "Slide to cancel Event",
          //     style: TextStyle(color: Color(0xff4a4a4a), fontWeight: FontWeight.w500, fontSize: 17),
          //   ),
          //   icon: Text(
          //     "x",
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.w400,
          //       fontSize: 44,
          //     ),
          //   ),
          // )),
          // SwipeButton.expand(
          //   height: 50.h,
          //   width: 327.w,
          //   enabled: sl<HomeBloc>().orderDetails.status != "COMPLETED" ? false : true,
          //   inactiveThumbColor: ColorManager.white,
          //   thumbPadding: EdgeInsets.all(3.r),
          //   thumb: Icon(
          //     Icons.double_arrow_rounded,
          //     color: Colors.white,
          //   ),
          //   activeThumbColor: ColorManager.white,
          //   activeTrackColor: ColorManager.primary,
          //   inactiveTrackColor: ColorManager.medGray,
          //   onSwipe: () {
          //     if (sl<HomeBloc>().orderStep < 3) {
          //       sl<HomeBloc>().add(BikerCompleteOrder(
          //           orderId: widget.order.sId!, orderIndex: widget.index == null ? -1 : widget.index!, context: context));
          //     }
          //   },
          //   child: Text(
          //     'Complete Wash',
          //     style: AppStyles.title16Bold.copyWith(color: ColorManager.white),
          //   ),
          // ),
          // CustomSwipeButton(
          //   height: 50,
          //   width: 327,
          //   initialBackgroundColor:  sl<HomeBloc>().orderDetails.status == "COMPLETED" ? ColorManager.primary : ColorManager.divider,
          //   initialText: sl<HomeBloc>().orderDetails.status == "COMPLETED" ?  translate(AppStrings.washCompleted) : translate(AppStrings.completeWash),
          //   onChange: () {},
          //   textDirection: sl<HomeBloc>().orderDetails.status == "COMPLETED" ? TextDirection.rtl : TextDirection.ltr,
          //   isSuccess: sl<HomeBloc>().orderDetails.status != "COMPLETED" ? false : true,
          //   // successState: sl<HomeBloc>().state is BikerCompleteOrderSuccessState,
          // ),
          ButtonCompleteWashWidget(
            orderId: widget.order.sId!,
            index: widget.index,
          ),
          // 12.verticalSpace,
          // BlocBuilder<HomeBloc, HomeState>(
          //   bloc: sl<HomeBloc>(),
          //   builder: (BuildContext context, HomeState state) {
          //     final bool isLoading = state is BikerCancelOrderLoading &&
          //         state.orderId == widget.order.sId;
          //     final String? currentStatus =
          //         sl<HomeBloc>().orderDetails.status;
          //     final bool isCompleted = currentStatus == "COMPLETED";

          //     if (isCompleted) {
          //       return const SizedBox.shrink();
          //     }

          //     return InkWell(
          //       onTap: isLoading ? null : _showCancelDialog,
          //       child: Container(
          //         width: double.infinity,
          //         decoration: BoxDecoration(
          //           color: ColorManager.red.withValues(alpha: 0.08),
          //           borderRadius: BorderRadius.circular(8.r),
          //           border: Border.all(color: ColorManager.red),
          //         ),
          //         padding:
          //             EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
          //         child: Center(
          //           child: isLoading
          //               ? SizedBox(
          //                   height: 18.r,
          //                   width: 18.r,
          //                   child: CircularProgressIndicator(
          //                     strokeWidth: 2,
          //                     valueColor: AlwaysStoppedAnimation<Color>(
          //                         ColorManager.red),
          //                   ),
          //                 )
          //               : Text(
          //                   translate(AppStrings.cancelOrder),
          //                   style: AppStyles.body14Medium.copyWith(
          //                     color: ColorManager.red,
          //                   ),
          //                 ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          // AnimatedToggleSwitch<bool>.dual(
          //   current: sl<HomeBloc>().orderDetails.status == "COMPLETED" ? false : true,
          //   first: false,
          //   second: true,
          //   // dif: 250.0,
          //   // borderColor: Colors.transparent,
          //   // innerColor: sl<HomeBloc>().orderDetails.status == "COMPLETED" ? ColorManager.primary : ColorManager.medGray,
          //   borderWidth: 4,
          //   height: 50.h,

          //   loading: false,
          //   // boxShadow: const <BoxShadow>[
          //   //   BoxShadow(
          //   //     color: Colors.black26,
          //   //     spreadRadius: 1,
          //   //     blurRadius: 2,
          //   //     offset: Offset(0, 1.5),
          //   //   ),
          //   // ],
          //   onChanged: (bool b) {
          //     if (!b && sl<HomeBloc>().orderStep < 3) {
          //       sl<HomeBloc>().add(BikerCompleteOrder(orderId: widget.order.sId!, orderIndex: widget.index, context: context));
          //     }
          //     return Future.delayed(Duration(seconds: 2));
          //   },
          //   // colorBuilder: (bool b) => ColorManager.white,
          //   textBuilder: (bool value) => value
          //       ? Center(
          //           child: Text(
          //           translate(AppStrings.completeWash),
          //           style: AppStyles.title16Bold.copyWith(color: ColorManager.white),
          //         ))
          //       : Center(
          //           child: Text(
          //           translate(AppStrings.washCompleted),
          //           style: AppStyles.title16Bold.copyWith(color: ColorManager.white),
          //         )),
          // ),

          // SwipeToConfirmButton(
          //   onSwipeComplete: (bool isConfirmed) {
          //     if (isConfirmed && sl<HomeBloc>().orderStep < 3) {
          //       sl<HomeBloc>().add(BikerCompleteOrder(
          //         orderId: widget.order.sId!,
          //         orderIndex: widget.index == null ? -1 : widget.index!,
          //         context: context,
          //       ));
          //     }
          //   },
          //   label: translate(AppStrings.completeWash),
          // ),
          // SwipeToConfirmButton(
          //   onSwipeComplete: (bool isConfirmed) {
          //     if (isConfirmed && sl<HomeBloc>().orderStep < 3) {
          //       sl<HomeBloc>().add(BikerCompleteOrder(
          //         orderId: widget.order.sId!,
          //         orderIndex: widget.index == null ? -1 : widget.index!,
          //         context: context,
          //       ));
          //     }
          //   },
          //   label: translate(AppStrings.completeWash),
          //   initialColor: ColorManager.white,
          //   completedColor: ColorManager.primary,
          // ),
          // SwipeToConfirmButton(
          //   onSwipeComplete: (bool isConfirmed) {
          //     if (isConfirmed) {
          //       sl<HomeBloc>().add(BikerCompleteOrder(
          //         orderId: widget.order.sId!,
          //         orderIndex: widget.index == null ? -1 : widget.index!,
          //         context: context,
          //       ));
          //     }

          //   },
          //   label: translate(AppStrings.completeWash),
          //   completedColor: ColorManager.primary,
          //   isSwipeEnabled: sl<HomeBloc>().orderStep < 3, // Condition to enable/disable swipe
          // ),
        ],
      ),
    );
  }
}
