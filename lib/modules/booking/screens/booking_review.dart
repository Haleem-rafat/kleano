// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:thewasher/core/resources/app_bar.dart';
// import 'package:thewasher/core/resources/app_styles.dart';
// import 'package:thewasher/core/resources/color_manager.dart';
// import 'package:thewasher/core/resources/constant_manager.dart';
// import 'package:thewasher/core/resources/strings_manager.dart';
// import 'package:thewasher/core/resources/values_manager.dart';
// import 'package:thewasher/layout/main_navigation_screen.dart';
// import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
// import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
// import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
// import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
// import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
// import 'package:thewasher/modules/booking/widgets/payment_webview.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/addons_details.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/apply_pomo_code.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/car_details.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/date_and_service_time.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/location_details.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/payment_method/select_points_or_wallet.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/services.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/total_and_discount.dart';
// import 'package:thewasher/modules/booking/widgets/review_order/totalpay_and_place_order.dart';
// import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
// import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
// import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
// import 'package:thewasher/modules/tracking_order/screens/tracking_order_main_screen.dart';
// import 'package:thewasher/responses/base_response.dart';
// import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
// import 'package:thewasher/shared/components/loading.dart';
// import 'package:thewasher/shared/components/snack_bar.dart';
// import 'package:thewasher/shared/services/service_locator.dart';
// import 'package:thewasher/shared/singleton.dart';
// import 'package:thewasher/utilties/navigator.dart';

// class BookingReviewScreen extends StatefulWidget {
//   final OrderModel order;
//   final num redeemLimit;
//   final bool isApplePay;
//   const BookingReviewScreen({
//     super.key,
//     required this.isApplePay,
//     required this.order,
//     required this.redeemLimit,
//   });

//   @override
//   State<BookingReviewScreen> createState() => _BookingReviewScreenState();
// }

// class _BookingReviewScreenState extends State<BookingReviewScreen> {
//   GeneralSingleton generalSingleton = GeneralSingleton();
//   @override
//   void initState() {
//     super.initState();
//     _setupSocketListener(context);
//     sl<PromoBloc>().totalPayModel = TotalPayModel();
//   }

//   void _setupSocketListener(BuildContext context) {
//     context.read<SocketBloc>.call().stream.listen((SocketState socketState) {
//       if (socketState is BikerAcceptedSuccess) {
//         if (socketState.acceptedOrderByBikerModel != null) {
//           _navigateToTrackingOrder(socketState.acceptedOrderByBikerModel!);
//         }
//       }
//     });
//   }

//   void _navigateToTrackingOrder(AcceptedOrderByBikerModel acceptedOrderModel) {
//     Navigator.of(context).popUntil((route) => route.isFirst);
//     generalSingleton.resetTimes();
//     pushPage(
//       context,
//       TrackingOrderMainScreen(
//         orderAcceptedModel: acceptedOrderModel,
//         orderModel: widget.order,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: _buildBodyContent(context),
//       bottomNavigationBar: _buildBottomNavigationPlaceOrder(),
//     );
//   }

//   PreferredSize _buildAppBar() {
//     return PreferredSize(
//       preferredSize: Size(AppSize.s375, AppSize.s60.h),
//       child: AppBarShared(
//         onTap: () {
//           pop(context);
//         },
//         titleAppBar: translate(AppStrings.bookingReview),
//         isTextOnly: false,
//       ),
//     );
//   }

//   Widget _buildBodyContent(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(AppPadding.p28.w, AppPadding.p17.h,
//             AppPadding.p28.w, AppPadding.p11.h),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               if (widget.order.vehicle != null)
//                 CarDetails(
//                   order: widget.order,
//                 ),
//               if (widget.order.location != null)
//                 LocationDetails(location: widget.order.location!),
//               if (_hasValidServiceTime())
//                 DateAndServiceTime(
//                   startTime: widget.order.startTime!,
//                   createdAt: widget.order.createdAt!,
//                   totalDuration: widget.order.totalDuration!,
//                   isScheduled: widget.order.isScheduled!,
//                 ),
//               if (widget.order.paymentType == AppConstants.creadit ||
//                   widget.order.paymentType == "APPLE_PAY" &&
//                       widget.order.sId != null)
//                 ApplyPromCode(orderId: widget.order.sId!),
//               if (widget.order.washingServices!.isNotEmpty)
//                 ServicesDetails(
//                   services: widget.order.washingServices!,
//                 ),
//               if (widget.order.addOns!.isNotEmpty)
//                 AddOnsDetails(
//                   addons: widget.order.addOns!,
//                 ),
//               if (widget.order.sId != null)
//                 SelectPaymentMethodsPointsOrWallet(
//                   orderId: widget.order.sId!,
//                   points: widget.redeemLimit,
//                 ),
//               if (widget.order.totalPrice != null) ...[
//                 16.verticalSpace,
//                 DiscountAndTotal(
//                   discount: widget.order.discount!,
//                   total: widget.order.totalPrice!,
//                 ),
//               ],
//               16.verticalSpace,
//               _cancelBookingButton(context)
//             ]),
//       ),
//     );
//   }

//   bool _hasValidServiceTime() {
//     return widget.order.startTime != null &&
//         widget.order.createdAt != null &&
//         widget.order.totalDuration != null &&
//         widget.order.isScheduled != null;
//   }

//   Align _cancelBookingButton(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: GestureDetector(
//         onTap: () {
//           if (widget.order.sId != null) {
//             AlertHelper.cancelBooking(context, widget.order.sId!, false);
//           }
//         },
//         behavior: HitTestBehavior.opaque,
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 19.w),
//           child: Text(
//             translate(AppStrings.cancelBooking),
//             style: AppStyles.body14Medium.copyWith(
//               color: ColorManager.red,
//               decoration: TextDecoration.underline,
//               decorationColor: ColorManager.red,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   BlocConsumer<BookingOrderBloc, BookingOrderState>
//       _buildBottomNavigationPlaceOrder() {
//     return BlocConsumer<BookingOrderBloc, BookingOrderState>(
//       listener: (context, state) {
//         if (state is PlaceOrderFailed) {
//           _showErrorSnackBar(state.errormodel);
//         } else if (state is PlaceOrderSuccess) {
//           debugPrint("sassasa");
//           state.paymentUrl != null
//               ? _onOrderSuccess(context, transactionUrl: state.paymentUrl)
//               : popALlAndPushPage(
//                   context, MainNavigationScreen(selectedIndex: 0));
//         }
//       },
//       builder: (context, state) {
//         if (state is PlaceOrderLoading) {
//           return const LoadingWidget();
//         }
//         return TotalPayAndPlaceOrder(
//             createdAt: widget.order.createdAt,
//             orderId: widget.order.sId,
//             isApplePay: widget.isApplePay,
//             totalDuration: widget.order.totalDuration ?? 0,
//             totalPay: widget.order.totalPay ?? 0.0,
//             onTap: () {
//               context.read<BookingOrderBloc>().add(PlaceOrder(
//                   applePayId: applePayId,
//                   orderId: widget.order.sId!,
//                   paymentDetailsRequest: PaymentDetailsRequest(
//                     name: sl<OffersBloc>().cardHolderName,
//                     number: sl<OffersBloc>().cardNumber,
//                     cvc: sl<OffersBloc>().cardCvv,
//                     month: sl<OffersBloc>().expiryMonth,
//                     year: sl<OffersBloc>().expiryYear,
//                   )));
//             });
//       },
//     );
//   }

//   void _showErrorSnackBar(ErrorModel? errorModel) {
//     showSnackBar(
//       buildContext: context,
//       message: Localizations.localeOf(context).languageCode == 'en'
//           ? errorModel?.en ?? "Failed to process payment"
//           : errorModel?.ar ?? "فشل في معالجة الدفع.",
//     );
//   }

//   void _onOrderSuccess(BuildContext context, {String? transactionUrl}) async {
//     context.read<BookingOrderBloc>().add(ClearCartOrder());
//     sl<PromoBloc>().totalPayModel = TotalPayModel();
//     // sl<PromoBloc>().totalPayModel = null;
//     if (transactionUrl != null) {
//       final paymentResult = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentWebview(
//             transactionUrl: transactionUrl,
//             onPaymentComplete: (status) {
//               if (status == 'Payment success') {
//                 Navigator.pop(context, true);
//                 AlertHelper.createOrderSuccess(context);
//               } else {
//                 showSnackBar(buildContext: context, message: 'Payment Failed');
//               }
//             },
//           ),
//         ),
//       );
//       if (paymentResult == true) {}
//     }
//   }

//   void actionPlaceOrder(String orderId, {bool? payOrder = true}) {
//     if (orderId.isNotEmpty) {
//       debugPrint('kkkskkskskksk: $orderId');
//       debugPrint('kkkskkskskksk: ${sl<OffersBloc>().cardHolderName}');
//       debugPrint('kkkskkskskksk: ${sl<OffersBloc>().cardNumber}');
//       debugPrint('kkkskkskskksk: ${sl<OffersBloc>().cardCvv}');
//       debugPrint('kkkskkskskksk: ${sl<OffersBloc>().expiryMonth}');
//       debugPrint('kkkskkskskksk: ${sl<OffersBloc>().expiryYear}');
//     }
//   }
// }
