import 'package:thewasher/core/network/status_code.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/responses/base_response.dart';

class ProfileResponse {
  late final bool success;
  late final String message;
  UserProfile? result;
  ErrorModel? errorModel;


  ProfileResponse({
    Map<String, dynamic>? json,
    required int statusCode,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      if (json != null) {
        result = UserProfile.fromJson(json);
        success = true;
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
