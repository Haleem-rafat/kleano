import 'package:thewasher/models/auth_model.dart';
import 'package:thewasher/responses/base_response.dart';

class UserRegisterResponse {
  AuthModel? result;
  late final bool success;
  ErrorModel? errorModel;

  UserRegisterResponse({
    Map<String, dynamic>? json,
    bool isList = false,
  }) {
    if (json != null) {
      result = AuthModel.fromJson(json);
      success = json['success'] as bool;
      errorModel = json['message'];
    } else {
      result = null;
      success = false;
      errorModel = ErrorModel.fromJson(json!['message']);
    }
  }
}

// class ModelUserResponse {
//   late final bool success;
//   late final String message;
//   RegisterModel? result;

//   ModelUserResponse({
//     Map<String, dynamic>? json,
//     required int statusCode,
//   }) {
//     if (statusCode >= 200 && statusCode <= 307) {
//       if (json != null) {
//         result = RegisterModel.fromJson(json);
//         success = true;
//       } else {
//         result = null;
//         success = true;
//       }
//     } else {
//       result = null;
//       success = false;
//       message = checkStatusCode(statusCode);
//     }
//   }
// }
