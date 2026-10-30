import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/responses/base_response.dart';

class OrderResponse {
  late final bool success;
  String? message;
  OrderModel? result;
  ErrorModel? errorModel;


  OrderResponse({
    Map<String, dynamic>? json,
    required int statusCode,
    this.message,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      if (json != null) {
        result = OrderModel.fromJson(json['data']);
        success = true;
        message = json['message'];
      } else {
        result = null;
        success = true;
      }
    } else {
      result = null;
      success = false;
      errorModel = ErrorModel.fromJson(json!['message']);
      message = checkStatusCode(statusCode);
    }
  }
}