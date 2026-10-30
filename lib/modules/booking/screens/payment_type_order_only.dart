// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:thewasher/core/resources/app_bar.dart';
// import 'package:thewasher/core/resources/app_styles.dart';
// import 'package:thewasher/core/resources/color_manager.dart';
// import 'package:thewasher/core/resources/strings_manager.dart';
// import 'package:thewasher/core/resources/values_manager.dart';
// import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
// import 'package:thewasher/modules/booking/data/models/payment_type_model.dart';
// import 'package:thewasher/modules/booking/screens/booking_review.dart';
// import 'package:thewasher/modules/booking/screens/payment_screen.dart';
// import 'package:thewasher/modules/booking/widgets/card_payment_type.dart';
// import 'package:thewasher/modules/booking/widgets/functions/create_order_data_request.dart';
// import 'package:thewasher/shared/components/buttons.dart';
// import 'package:thewasher/shared/components/loading.dart';
// import 'package:thewasher/shared/components/snack_bar.dart';
// import 'package:thewasher/shared/services/service_locator.dart';
// import 'package:thewasher/shared/singleton.dart';
// import 'package:thewasher/utilties/navigator.dart';
// import 'dart:io';

// class SelectPaymentTypeOrderScreen extends StatelessWidget {
//   GeneralSingleton generalSingleton = GeneralSingleton();

//   SelectPaymentTypeOrderScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     int? paymentType;
//     List<PaymentMethodModel> paymentMethods =
//         PaymentMethodModel.listPaymentMethods;
//     // Remove Apple Pay if not on iOS
//     if (!Platform.isIOS) {
//       paymentMethods = paymentMethods.where((m) => m.value != 3).toList();
//     }
//     BookingOrderBloc createOrderBloc = sl<BookingOrderBloc>();
//     return BlocProvider<BookingOrderBloc>.value(
//       value: createOrderBloc,
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size(AppSize.s375, 60.h),
//           child: AppBarShared(
//             titleAppBar: translate(AppStrings.payment),
//             isTextOnly: false,
//           ),
//         ),
//         body: Padding(
//           padding: EdgeInsets.fromLTRB(AppPadding.p24.w, AppPadding.p23.h,
//               AppPadding.p24.w, AppPadding.p64.h),
//           child: StatefulBuilder(
//             builder: (context, setState) {
//               bool isLoading = false;
//               return BlocListener<BookingOrderBloc, BookingOrderState>(
//                 listener: (context, state) {
//                   if (state is CreateOrderLoading) {
//                     setState(() {
//                       isLoading = true;
//                     });
//                   } else {
//                     setState(() {
//                       isLoading = false;
//                     });
//                   }
//                   if (state is CreateOrderSuccess) {
//                     // createOrderBloc.add(ClearCartOrder());
//                     generalSingleton.orderId =
//                         state.reviewOrderModel.data!.sId!;
//                     pushPage(
//                         context,
//                         BookingReviewScreen(
//                           isApplePay: paymentType == 3 ? true : false,
//                           order: state.reviewOrderModel.data!,
//                           redeemLimit: state.redeemLimit ?? 0,
//                         ));
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     AbsorbPointer(
//                       absorbing: isLoading,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             translate(AppStrings.choosePaymentMethod),
//                             style: AppStyles.titleWhite16Bold
//                                 .copyWith(color: ColorManager.black),
//                           ),
//                           SizedBox(
//                             height: AppPadding.p16.h,
//                           ),
//                           Column(
//                             children:
//                                 paymentMethods.map((PaymentMethodModel type) {
//                               return GestureDetector(
//                                   onTap: isLoading
//                                       ? null
//                                       : () {
//                                           setState(() {
//                                             createOrderBloc.paymentType =
//                                                 type.value;
//                                             paymentType = type.value;
//                                           });
//                                           if (type.value == 2) {
//                                             showSnackBar(
//                                                 buildContext: context,
//                                                 message: "Comming Soon");
//                                           } else if (type.value == 3) {
//                                             CreateOrderFunction()
//                                                 .createOrderDataRequest();
//                                           }
//                                           if (type.value == 1) {
//                                             pushPage(
//                                                 context, const PaymentScreen());
//                                           }
//                                         },
//                                   behavior: HitTestBehavior.opaque,
//                                   child: CardPaymentMethod(
//                                     type: type,
//                                     borderColor: createOrderBloc.paymentType ==
//                                             type.value
//                                         ? ColorManager.secondary
//                                         : ColorManager.white,
//                                     groupValue: createOrderBloc.paymentType,
//                                   ));
//                             }).toList(),
//                           ),
//                           SizedBox(height: 12),
//                           Text(
//                             translate('coupon_hint'),
//                             style: AppStyles.titleWhite16Bold
//                                 .copyWith(color: ColorManager.black),
//                             textAlign: TextAlign.center,
//                           ),
//                           const Spacer(),
//                         ],
//                       ),
//                     ),
//                     // Overlay loading indicator when CreateOrderLoading
//                     BlocBuilder<BookingOrderBloc, BookingOrderState>(
//                       builder: (context, state) {
//                         if (state is CreateOrderLoading) {
//                           return Container(
//                             width: double.infinity,
//                             height: double.infinity,
//                             child: const Center(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   LoadingWidget(),
//                                   SizedBox(height: 16),
//                                   Text(
//                                     'Processing your payment...',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
