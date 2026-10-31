import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/notifications/data/responses/notifications_response.dart';

class NotificationsRepo {
  static Future<NotificationsResponse> fetchNotifications({
    required int pageNumber,
  }) async {
    final Response<dynamic>? response = await ApiService.getApi(
      '${ApiPaths.notifications}?page=$pageNumber&perPage=10',
      isAuth: true,
    );
    return NotificationsResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<bool> enableNotification({
    required String permission,
  }) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.notificationPermission,
      isAuth: true,
      body: {
        'allow': permission,
      },
    );
    return response != null && response.statusCode == 200;
  }

  static Future<bool> readNotification({
    required String id,
  }) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      '${ApiPaths.notifications}/$id/set-read',
      isAuth: true,
    );
    return response != null && response.statusCode == 200;
  }
}
