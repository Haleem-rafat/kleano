import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/my_booking/data/responses/my_booking_response.dart';

class MyBookingRepo {
  static Future<MyBookingResponse?> userViewAllMyBooking({
    required String status,
    required int pageNumber,
  }) async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        '${ApiPaths.orderUserAll}?status=$status&page=$pageNumber&perPage=10',
        isAuth: true,
      );
      if (response != null && response.statusCode == 200) {
        return MyBookingResponse(
          statusCode: response.statusCode!,
          json: response.data,
        );
      }
    } catch (e) {
      print(e);
    }

    return null;
  }
}
