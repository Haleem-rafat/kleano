import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/my_booking/data/models/my_booking_model.dart';
import 'package:thewasher/responses/base_response.dart';

class MyBookingResponse {
  late final bool success;
  late final String message;
  MyBookingModel? results;
  ErrorModel? errorModel;

  MyBookingResponse({
    Map<String, dynamic>? json,
    required int statusCode,
  }) {
    if(statusCode >= 200 && statusCode <= 307){
      if(json != null) {
        results =  MyBookingModel.fromJson(json);
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