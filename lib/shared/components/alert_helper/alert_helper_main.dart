import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/src/places.dart';
import 'package:thewasher/shared/components/alert_helper/cancel_booking.dart';
import 'package:thewasher/shared/components/alert_helper/clear_place_alert.dart';
import 'package:thewasher/shared/components/alert_helper/confirm_phone_number.dart';
import 'package:thewasher/shared/components/alert_helper/create_subscription_alert.dart';
import 'package:thewasher/shared/components/alert_helper/delete_user_account.dart';
import 'package:thewasher/shared/components/alert_helper/delete_car_alert.dart';
import 'package:thewasher/shared/components/alert_helper/feedback_success.dart';
import 'package:thewasher/shared/components/alert_helper/guest_alert.dart';
import 'package:thewasher/shared/components/alert_helper/location_confirmation.dart';
import 'package:thewasher/shared/components/alert_helper/order_success.dart';
import 'package:thewasher/shared/components/alert_helper/pay_with_wallet_not_enough.dart';
import 'package:thewasher/shared/components/alert_helper/payment_add_card_success.dart';
import 'package:thewasher/shared/components/alert_helper/phone_already_exist.dart';
import 'package:thewasher/shared/components/alert_helper/point_alert.dart';
import 'package:thewasher/shared/components/alert_helper/rating_alert.dart';
import 'package:thewasher/shared/components/alert_helper/saved_alert.dart';
import 'package:thewasher/shared/components/alert_helper/success_save_location.dart';
import 'package:thewasher/shared/components/alert_helper/update_car_alert.dart';
import 'package:thewasher/shared/components/alert_helper/verification_code_done.dart';
import 'package:thewasher/shared/components/alert_helper/wallet_topup_success.dart';

class AlertHelper {
  static verificationCodeDone(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const VerificationCodeDone());

  static guestAlert(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const GuestAlert());

  // static savedAlert(BuildContext context, TextEditingController nameController,
  //         bool recent, {PlacesDetailsResponse? detail, int? index}) async =>
  //     showDialog(
  //         context: context,
  //         barrierDismissible: true,
  //         builder: (BuildContext context) => SavedAlert(
  //             detail: detail,
  //             nameController: nameController,
  //             recent: recent,
  //             index: index));

  static updateCarAlert(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const UpdateCarAlert());

  static deleteCarAlert(BuildContext context, String sId, int index) async =>
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              DeleteCarAlert(sId: sId, index: index));

  static clearPlaceAlert(
          BuildContext context, Function() delete, String title) async =>
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              ClearPlaceAlert(delete: delete, name: title));

  static pointAlert(
    BuildContext context,
  ) async =>
      showDialog(
          context: context,
          builder: (BuildContext context) => const PointAlert());

  static confirmPhoneNumber({
    required BuildContext context,
    required String phoneNumber,
    String? userName,
    String? email,
    required bool comeFromSignUp,
  }) async =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => ConfirmPhoneNumber(
                phoneNumber: phoneNumber,
                userName: userName ?? '',
                email: email,
                comeFromSignUpScreen: comeFromSignUp,
              ));

  static deleteUserAccount(BuildContext context) async => showDialog(
      context: context,
      builder: (BuildContext context) => const DeleteUserAccount());

  static phoneAlreadyExist(BuildContext context, String phone) async =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => PhoneAlreadyExist(
                phoneNumber: phone,
              ));

  static createSubscription(
          {required BuildContext context,
          required String planType,
          required double price,
          required String planId,
          required String createdAt}) async =>
      showDialog(
          context: context,
          builder: (BuildContext context) => CreateSubscription(
                createdAt: createdAt,
                planType: planType,
                price: price,
                planId: planId,
              ));

  static locationConfirmation(BuildContext context) async => showDialog(
      context: context,
      builder: (BuildContext context) => const LocationConfirmation());

  static paymentAddCardSuccess(BuildContext context) async => showDialog(
      context: context,
      builder: (BuildContext context) => const PaymentAddCardSuccess());

  static cancelBooking(BuildContext context, String orderId,
          bool? comeFromWashDetails) async =>
      showDialog(
          context: context,
          builder: (BuildContext context) => CancelBooking(
                orderId: orderId,
                comeFromWashDetails: comeFromWashDetails,
              ));

  static userRatingOrder(BuildContext context, String orderId) async =>
      showDialog(
          context: context,
          builder: (BuildContext context) => RatingOrderAlert(
                orderId: orderId,
              ));

  static feedbackSuccess(BuildContext context) async => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const FeedbackSuccessSubmit(),
      );
  static payWithWalletNotEnoughAmount(BuildContext context) async => showDialog(
        context: context,
        builder: (BuildContext context) => const PayWithWalletNotEnoughAmount(),
      );

  static createOrderSuccess(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const OrderSuccess());

  static successSavedLocation(BuildContext context,
          {required String message}) async =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => SuccessAlert(
                message: message,
              ));

  static walletTopupSuccess(BuildContext context) async => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const WalletTopupSuccess());
}
