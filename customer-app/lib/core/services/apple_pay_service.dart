import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart';
import 'package:thewasher/core/config/api_keys.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class ApplePayService {
  // static final MoyasarService _moyasarService =
  //     MoyasarService(ApiKeys.publishApiKey);

  /// Check if Apple Pay is available on the device
  static bool get isApplePayAvailable {
    return Platform.isIOS;
  }

  /// Show Apple Pay bottom sheet for subscription payment
  static void showApplePayBottomSheetForSubscription({
    required BuildContext context,
    required String subscriptionId,
    required num amount,
    required String createdAt,
    required Function(String paymentId) onPaymentSuccess,
    required Function(String error) onPaymentError,
  }) {
    if (!isApplePayAvailable) {
      onPaymentError('Apple Pay is not available on this device');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ApplePay(
            config: PaymentConfig(
              metadata: {
                "subscriptionId": subscriptionId,
                "userId": sl<GetUserProfileBloc>().profile.sId ?? "",
                "totalAmount": amount,
                "createdAt": createdAt,
                "orderType": "SUBSCRIPTION",
              },
              currency: "SAR",
              publishableApiKey: ApiKeys.publishApiKey,
              amount: (amount * 100).toInt(),
              description: 'Payment for Subscription #$subscriptionId',
              applePay: ApplePayConfig(
                saveCard: false,
                merchantId: 'merchant.kleanoDev',
                label: 'KleanO',
                manual: false,
              ),
            ),
            onPaymentResult: (result) async {
              debugPrint("Apple Pay Result: $result");

              if (result is UnprocessableTokenError) {
                debugPrint("Apple Pay Error: ${result.message}");
                onPaymentError(result.message);
              } else if (result is PaymentResponse) {
                debugPrint("Apple Pay Success: ${result.id}");
                onPaymentSuccess(result.id);
              } else {
                debugPrint("Apple Pay Cancelled or Failed");
                onPaymentError('Payment was cancelled or failed');
              }
            },
          ),
        );
      },
    );
  }

  
}
