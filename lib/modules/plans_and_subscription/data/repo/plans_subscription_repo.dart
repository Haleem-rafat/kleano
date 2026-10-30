import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
import 'package:thewasher/modules/plans_and_subscription/data/responses/get_subscription_response.dart';
import 'package:thewasher/modules/plans_and_subscription/data/responses/plans_response.dart';
import 'package:thewasher/responses/base_response.dart';

class PlansAndSubscriptionRepo {
  static Future<PlansResponse> getAllPlans({
    required double latitude,
    required double longitude,
    required String country,
  }) async {
    final Response<dynamic>? response = await ApiService.getApi(
      '${AppShared.token.isNotEmpty ? ApiPaths.plansUserAll : ApiPaths.plansGuestAll}?latitude=${latitude.toStringAsFixed(6)}&longitude=${longitude.toStringAsFixed(6)}&country=${Uri.encodeQueryComponent(country)}',
      isAuth: AppShared.token.isNotEmpty ? true : false,
    );
    return PlansResponse(
      json: response?.data,
    );
  }

  static Future<SubscriptionResponse> getUserSubscription() async {
    final Response<dynamic>? response = await ApiService.getApi(
      ApiPaths.subscriptionUser,
      isAuth: true,
    );
    return SubscriptionResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<SubscriptionResponse> createUserSubscription(
      {required String planId, required String paymentType}) async {
    final Response<dynamic>? response =
        await ApiService.postApi(ApiPaths.subscriptions, isAuth: true, body: {
      'plan': planId,
      'paymentType': paymentType,
    });
    return SubscriptionResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<BaseResponseWithoutResponse> paySubscription(
      {required String subscriptionId,
      String? applePayId,
      PaymentDetailsRequest? paymentDetailsRequest}) async {
    final Response<dynamic>? response = await ApiService.patchApi(
        ApiPaths.paySubscription,
        isAuth: true,
        body: {
          "applePayId": ?applePayId,
          'subscription': subscriptionId,
          'paymentDetails': ?paymentDetailsRequest,
        });
    return BaseResponseWithoutResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<SubscriptionResponse> getSubscriptionByLocation({
    required double latitude,
    required double longitude,
    required String country,
  }) async {
    final Response<dynamic>? response = await ApiService.getApi(
      '${ApiPaths.subscriptionsUserLocation}?latitude=${latitude.toStringAsFixed(6)}&longitude=${longitude.toStringAsFixed(6)}&country=${Uri.encodeQueryComponent(country)}',
      isAuth: true,
    );
    return SubscriptionResponse(
      json: response?.data,
      statusCode: response!.statusCode!,
      // message: response.data
    );
  }
}
