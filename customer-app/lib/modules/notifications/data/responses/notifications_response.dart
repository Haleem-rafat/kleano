import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/responses/base_response.dart';

class NotificationsResponse {
  late final bool success;
  late final String message;
  NotificationsModel? results;
  ErrorModel? errorModel;

  NotificationsResponse({
    Map<String, dynamic>? json,
    required int statusCode,
  }) {
    if(statusCode >= 200 && statusCode <= 307){
      if(json != null) {
        results =  NotificationsModel.fromJson(json);
        success = true;
      } else {
        results = null;
        success = true;
        errorModel = ErrorModel.fromJson(json!['message']);
      }
    } else {
      results = null;
      success = false;
      message = checkStatusCode(statusCode);
    }
  }
}