import 'package:thewasher/core/error/error.dart';
import 'package:thewasher/responses/base_response.dart';

class GenericResponse<T> {
  late final bool success;
  late final String message;
  late final int totalPages;
  late final int totalUnRead;
  late final int totalItems;
  List<Error>? error;
  T? result;
  List<T>? results;
  ErrorModel? errorModel;

  GenericResponse(
      {Map<String, dynamic>? json,
      bool isList = false,
      required T Function(Map<String, dynamic>) fromJson}) {
    if (json != null) {
      success = json['success'] ?? true;
      totalPages = json['totalPages'] ?? 0;
      totalItems = json['totalItems'] ?? 0;
      totalUnRead = json['totalUnRead'] ?? 0;

      if (json['errors'] != null) {
        error = <Error>[];
        json['errors'].forEach((dynamic v) {
          error!.add(Error.fromJson(v as Map<String, dynamic>));
        });
      }
      if (json['message'] != null) {
        errorModel = ErrorModel.fromJson(json['message']);
        print('+++++++${errorModel!.en}');
      }
      if (json['data'] != null) {
        if (isList) {
          results = (json['data'] as List<dynamic>).map((dynamic e) {
            return fromJson(e as Map<String, dynamic>);
          }).toList();
        } else {
          result = fromJson(json['data'] as Map<String, dynamic>);
          if (json['message'] != null) {
            errorModel = ErrorModel.fromJson(json['message']);
          }
        }
      } else {
        result = fromJson(json);
      }
    } else {
      success = false;
      error = <Error>[Error(message: 'Not authorized')];
    }
  }
}
