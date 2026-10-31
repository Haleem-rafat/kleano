import 'package:thewasher/core/error/error.dart';
import 'package:thewasher/modules/Home/data/model/banner_model.dart';

class BannersResponse {
  late final bool success;
  late final String message;
  List<Error>? error;
  List<BannerModel>? results;

  BannersResponse({
    Map<String, dynamic>? json,
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
        results = (resultMap(json) as List<dynamic>).map((dynamic e) {
          return BannerModel.fromJson(e as Map<String, dynamic>);
        }).toList();
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
