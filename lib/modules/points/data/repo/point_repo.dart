import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/points/data/models/apply_points_model.dart';
import 'package:thewasher/modules/points/data/models/point_model.dart';
import 'package:thewasher/modules/points/data/models/points_discount_model.dart';
import 'package:thewasher/responses/general_response.dart';

class PointRepo {
  static Future<GenericResponse<PointModel>> getUserPoints() async {
    final Response<dynamic>? response = await ApiService.getApi(
      ApiPaths.userPoints,
      isAuth: true,
    );
    return GenericResponse<PointModel>(
        json: response!.data, fromJson: PointModel.fromJson);
  }

  static Future<GenericResponse<ApplyPoint>> applyPoints(
      {required String orderId}) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      ApiPaths.applyPoints,
      isAuth: true,
      body: {
        'order': orderId,
      },
    );
    return GenericResponse<ApplyPoint>(
      json: response!.data,
      fromJson: ApplyPoint.fromJson,
    );
  }

  static Future<PointsDiscountModel> calculatePointsDiscount(
      {required num points}) async {
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.calculatePointsDiscount,
      isAuth: true,
      body: <String, dynamic>{
        'points': points,
      },
    );
    return PointsDiscountModel.fromJson(response!.data['data']);
  }
}
