import 'package:thewasher/core/error/error.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';

class AddOnsResponse {
  late final bool success;
  late final String message;
  List<Error>? error;
  AddOnsModel? result;
  List<AddOnsModel>? results;

  AddOnsResponse({
    Map<String, dynamic>? json,
    bool isList = false,
  }) {
    if (json != null) {
      success = resultSuccess(json) as bool;
      message = json['message'];

      if (json['errors'] != null) {
        error = <Error>[];
        json['errors'].forEach((dynamic v) {
          error!.add(Error.fromJson(v as Map<String, dynamic>));
        });
      }

      if (resultMap(json) != null) {
        if (isList) {
          results = (resultMap(json) as List<dynamic>).map((dynamic e) {
            return AddOnsModel.fromJson(e as Map<String, dynamic>);
          }).toList();
        } else {
          result = AddOnsModel.fromJson(resultMap(json) as Map<String, dynamic>);
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
