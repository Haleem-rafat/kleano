import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/booking/data/models/create_order_request_model.dart';
import 'package:thewasher/modules/booking/data/models/payment_methods_request.dart';
import 'package:thewasher/modules/booking/data/response/calender_avalibale_response.dart';
import 'package:thewasher/modules/booking/data/response/create_order_response.dart';
import 'package:thewasher/modules/booking/data/response/order_by_id_response.dart';
import 'package:thewasher/responses/base_response.dart';

class BookingOrderRepo {
  static Future<CreateOrderResponse> createOrder({
    required CreateOrderRequest request,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (request.washingServices != null)
        'washingServices': request.washingServices,
      if (request.addOns != null) 'addOns': request.addOns,
      'vehicle': request.vehicleId,
      'location': request.locationRequest.toJson(),
      if (request.description != null) 'description': request.description,
      'startTime': request.startTime,
      'bookingDate': request.bookingDate,
      'type': request.type,
      if (request.subscriptionId != null)
        'subscription': request.subscriptionId,
      'totalPrice': request.totalPrice,
      if (request.code != null) 'code': request.code,
      if (request.paymentType != null) 'paymentType': request.paymentType,
      'isCarFreshened': request.isCarFreshened,
      'userOS': request.userOS,
      if (request.timeSlot != null) 'timeSlot': request.timeSlot,
      'appliedPoints': request.appliedPoints,
    };
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.createOrder,
      isAuth: true,
      body: body,
    );
    return CreateOrderResponse(
      json: response?.data,
      statusCode: response!.statusCode!,
    );
  }

  static Future<BaseResponseWithoutResponse> userCancelOrder({
    required String orderId,
  }) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.cancelOrder,
      isAuth: true,
      body: <String, dynamic>{'order': orderId},
    );
    return BaseResponseWithoutResponse(
      json: response?.data,
      statusCode: response!.statusCode!,
    );
  }

  static Future<BaseResponseWithoutResponse> userPayOrder({
    required String orderId,
    required PaymentDetailsRequest? paymentDetailsRequest,
    required String? applePayId,
  }) async {
    final body = <String, dynamic>{
      'order': orderId,
      'applePaymentId': ?applePayId,
      'paymentDetails': ?paymentDetailsRequest,
    };
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.payOrder,
      isAuth: true,
      body: body,
    );

    return BaseResponseWithoutResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<OrderResponse> userViewOrderById({
    required String orderId,
  }) async {
    final Response<dynamic>? response = await ApiService.getApi(
      '${ApiPaths.orders}${ApiPaths.user}${ApiPaths.orderDetails}/$orderId',
      isAuth: true,
    );
    return OrderResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<BaseResponse> rateOrder({
    required String orderId,
    required double starsNum,
  }) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.rateOrder,
      isAuth: true,
      body: {'order': orderId, 'starsNum': starsNum},
    );
    return BaseResponse(statusCode: response!.statusCode!, json: response.data);
  }

  static Future<List<CalenderAvalibleResponse>> getBookingCalenderAvalabile({
    required String city,
    required String area,
    required String day,
    required String date,
  }) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "/user/biker-schedules?city=$city&area=$area&day=$day&date=$date",
      isAuth: true,
    );
    return List<CalenderAvalibleResponse>.from(
      response!.data['data'].map((x) => CalenderAvalibleResponse.fromJson(x)),
    );
  }
}
