import 'package:thewasher/modules/plans_and_subscription/data/models/plans_model.dart';
import 'package:thewasher/core/error/error.dart';

// class PlansResponse {
//   late final bool success;
//   late final String message;
//   PlansModel? results;
//   ErrorModel? errorModel;

//   PlansResponse({
//     Map<String, dynamic>? json,
//     required int statusCode,
//   }) {
//     if (statusCode >= 200 && statusCode <= 307) {
//       if (json != null) {
//         results = PlansModel.fromJson(json);
//         success = true;
//       } else {
//         results = null;
//         success = true;
//       }
//     } else {
//       results = null;
//       success = false;
//       errorModel = ErrorModel.fromJson(json!['message']);
//       message = checkStatusCode(statusCode);
//     }
//   }
// }

class PlansResponse {
  late final bool success;
  late final String message;
  List<Error>? error;
  PlansModel? result;
  List<Plan>? results;

  PlansResponse({
    Map<String, dynamic>? json,
    bool isList = true,
  }) {
    if (json != null) {
      success = resultSuccess(json) as bool;

      if (json['errors'] != null) {
        error = <Error>[];
        json['errors'].forEach((dynamic v) {
          error!.add(Error.fromJson(v as Map<String, dynamic>));
        });
      }

      if (resultMap(json) != null) {
        if (isList) {
          results = (resultMap(json) as List<dynamic>).map((dynamic e) {
            return Plan.fromJson(e as Map<String, dynamic>);
          }).toList();
        } else {
          result = PlansModel.fromJson(resultMap(json) as Map<String, dynamic>);
        }
      } else {
        result = null;
      }
    } else {
      success = false;
      error = <Error>[Error(message: 'Not authorized')];
    }
  }

  dynamic resultMap(Map<String, dynamic> json) {
    if (json['data'] == null) return json['data'];
    return json['data'];
  }

  dynamic resultSuccess(Map<String, dynamic> json) {
    if (json['success'] == null) return json['success'];
    return json['success'];
  }

  dynamic resultError(Map<String, dynamic> json) {
    if (json['errors'] == null) return json['errors'];
    return json['errors'];
  }
}
