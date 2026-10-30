import 'package:thewhsherbiker/core/network/status_code.dart';
import 'package:thewhsherbiker/models/error_model.dart';

class BaseResponse {
  late final bool success;
  late final String message;
  bool? isExist;
  String? errorMessage;
  ErrorModel? errorModel;

  BaseResponse({
    required int statusCode,
    Map<String, dynamic>? json,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      success = true;
      isExist = json!['isExist'];
    } else {
      success = false;
      errorModel = ErrorModel.fromJson(json!['message']);
      message = checkStatusCode(statusCode);
    }
  }
}
