import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/about_us/data/models/contact_model.dart';
import 'package:thewasher/responses/base_response.dart';

class ContactResponse {
  late final bool success;
  late final String message;
  ContactDataModel? results;
  ErrorModel? errorModel;

  ContactResponse({
    Map<String, dynamic>? json,
    required int statusCode,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      if (json != null) {
        results = ContactDataModel.fromJson(json);
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
