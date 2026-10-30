
import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/responses/base_response.dart';

class CreateOrderResponse {
  late final bool success;
  String? message;
  // late final String errorMessage;
  ReviewOrderModel? result;
  num? redeemLimit;
  ErrorModel? errorModel;

  CreateOrderResponse({
    Map<String, dynamic>? json,
    required int statusCode,
    this.message,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      if (json != null) {
        result = ReviewOrderModel.fromJson(json);
        success = true;
        message = json['message'];
        redeemLimit = json['data']['redeemLimit'] ?? 0;
      } else {
        result = null;
        success = true;
      }
    } else {
      result = null;
      success = false;
      // errorMessage = json!['message'];
      errorModel = ErrorModel.fromJson(json!['message']);
      message = checkStatusCode(statusCode);
    }
  }
}
