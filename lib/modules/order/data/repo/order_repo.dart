import 'package:dio/dio.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/api_service.dart';

class OrderRepo {
  static Future<bool> bikerRating(num starsNum, String orderId) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.bikerOrderRating,
      body: <String, dynamic>{
        'order': orderId,
        'starsNum': starsNum,
      },
      isAuth: true,
    );

    return response!.data['success'];
  }
}
