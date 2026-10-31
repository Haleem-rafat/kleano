import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
import 'package:thewasher/responses/base_response.dart';

class ApplyPromoCodeResponse {
  late final bool success;
  String? message;
  TotalPayModel? result;
  ErrorModel? errorModel;

  ApplyPromoCodeResponse({
    Map<String, dynamic>? json,
    required int statusCode,
    this.message,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      if (json != null) {
        result = TotalPayModel.fromJson(json['data']);
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
