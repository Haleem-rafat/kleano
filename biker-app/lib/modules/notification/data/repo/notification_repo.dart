import 'package:dio/dio.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/api_service.dart';
import 'package:thewhsherbiker/modules/notification/data/model/notification_model.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';

class NotificationRepo{

  static Future<GenericResponse<NotificationModel>> getNotification(int page ) async {
    final Response<dynamic>? response = await ApiService.getApi(
        "${ApiPaths.notifications}?page=$page&perPage=10",
        isAuth: true
    );


    return GenericResponse(
        json: response!.data,
        isList: true,
        fromJson: NotificationModel.fromJson
    );
  }

  static Future<bool> makeNotificationIsRead(String notificationID ) async {
    final Response<dynamic>? response = await ApiService.patchApi(
        "${ApiPaths.notifications}/$notificationID/set-read",
        isAuth: true
    );

    return response!.data['success'];
  }
}