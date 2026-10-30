import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/responses/base_response.dart';

class SubscriptionResponse {
  late final bool success;
  String? message;
  late final String errorMessage;
  SubscriptionUserModel? results;
  String? result;
  ErrorModel? errorModel;

  SubscriptionResponse({
    Map<String, dynamic>? json,
    required int statusCode,
    this.result,
    this.message,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      if (json != null) {
        results = SubscriptionUserModel.fromJson(json);
        success = true;
        message = json['message'];
      } else {
        results = null;
        success = true;
      }
    } else {
      results = null;
      success = false;
      errorModel = ErrorModel.fromJson(json!['message']);
      message = checkStatusCode(statusCode);
      errorMessage = errorModel?.en ?? "An unknown error occurred";
    }
  }
}
