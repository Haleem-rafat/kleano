import 'package:thewasher/core/network/status_code.dart';

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

class BaseResponseWithoutResponse {
  late final bool success;
  late final String message;
  // bool? isExist;
  String? errorMessage;
  ErrorModel? errorModel;
  String? result;

  BaseResponseWithoutResponse({
    required int statusCode,
    Map<String, dynamic>? json,
    this.result,
  }) {
    if (statusCode >= 200 && statusCode <= 307) {
      success = true;
      if (json != null && json['data'] != null) {
        // Check if data is a string (direct URL)
        if (json['data'] is String) {
          result = json['data'] as String;
        } else if (json['data'] is Map && json['data']['paymentUrl'] != null) {
          result = json['data']['paymentUrl'];
        } else {
          result = null;
        }
      } else if (json != null &&
          json['result'] != null &&
          json['result']['paymentUrl'] != null) {
        result = json['result']['paymentUrl'];
      } else {
        result = null;
      }
    } else {
      success = false;
      // errorModel = ErrorModel.fromJson(json!['message']);
      message = checkStatusCode(statusCode);
    }
  }
}

class ErrorModel {
  String? ar;
  String? en;

  ErrorModel({this.ar, this.en});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ar'] = ar;
    data['en'] = en;
    return data;
  }
}
