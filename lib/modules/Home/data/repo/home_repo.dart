import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/api_service.dart';
import 'package:thewhsherbiker/models/error_model.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';

class HomeRepo {
  static Future<GenericResponse<OrderModel>> bikerOrders(
      int page, String orderStatus) async {
    final Response<dynamic>? response = await ApiService.getApi(
        "${ApiPaths.bikerOrder}$orderStatus&page=$page&perPage=10",
        isAuth: true);

    return GenericResponse(
        json: response!.data, isList: true, fromJson: OrderModel.fromJson);
  }

  static Future<Either<ErrorModel, bool>> bikerOrderAccept(
    String orderId,
    String lat,
    String lng,
    String streetName,
    String subAdministrativeArea,
  ) async {
    ErrorModel? errorModel;
    final Response<dynamic>? response =
        await ApiService.patchApi(ApiPaths.bikerOrderAccept,
            body: {
              'order': orderId,
              "latitude": lat,
              "longitude": lng,
              "streetName": streetName,
              "subAdministrativeArea": subAdministrativeArea
            },
            isAuth: true);

    if (response!.data['success']) {
      return Right(response.data['success']);
    } else {
      errorModel = ErrorModel.fromJson(response.data['message']);
      return Left(errorModel);
    }
  }

  static Future<Either<ErrorModel, bool>> bikerOnTheWayOrder(
      String orderId) async {
    ErrorModel? errorModel;
    final Response<dynamic>? response =
        await ApiService.patchApi(ApiPaths.BikerOnTheWayOrder,
            body: {
              'order': orderId,
            },
            isAuth: true);

    if (response!.data['success']) {
      return Right(response.data['success']);
    } else {
      errorModel = ErrorModel.fromJson(response.data['message']);
      return Left(errorModel);
    }
  }

  static Future<Either<ErrorModel, bool>> bikerArrivedOrder(
      String orderId) async {
    ErrorModel? errorModel;
    final Response<dynamic>? response =
        await ApiService.patchApi(ApiPaths.BikerArrivedOrder,
            body: {
              'order': orderId,
            },
            isAuth: true);

    if (response!.data['success']) {
      return Right(response.data['success']);
    } else {
      errorModel = ErrorModel.fromJson(response.data['message']);
      return Left(errorModel);
    }
  }

  static Future<Either<ErrorModel, bool>> bikerOnWashingOrder(String orderId,
      {String? beforeWashImagePath}) async {
    ErrorModel? errorModel;

    if (beforeWashImagePath != null && beforeWashImagePath.isNotEmpty) {
      // Use multipart API for image upload
      final Response<dynamic>? response =
          await ApiService.patchMultiPartApi(ApiPaths.BikerOnWashingOrder,
              body: {
                'order': orderId,
              },
              files: [File(beforeWashImagePath)],
              filesName: ['image'],
              isAuth: true);

      if (response!.data['success']) {
        return Right(response.data['success']);
      } else {
        errorModel = ErrorModel.fromJson(response.data['message']);
        return Left(errorModel);
      }
    } else {
      // Use regular API without image
      final Response<dynamic>? response =
          await ApiService.patchApi(ApiPaths.BikerOnWashingOrder,
              body: {
                'order': orderId,
              },
              isAuth: true);

      if (response!.data['success']) {
        return Right(response.data['success']);
      } else {
        errorModel = ErrorModel.fromJson(response.data['message']);
        return Left(errorModel);
      }
    }
  }

  static Future<Either<ErrorModel, bool>> bikerCompleteOrder(String orderId,
      {String? afterWashImagePath}) async {
    ErrorModel? errorModel;

    if (afterWashImagePath != null && afterWashImagePath.isNotEmpty) {
      // Use multipart API for image upload
      final Response<dynamic>? response =
          await ApiService.patchMultiPartApi(ApiPaths.BikerCompleteOrder,
              body: {
                'order': orderId,
              },
              files: [File(afterWashImagePath)],
              filesName: ['image'],
              isAuth: true);

      if (response!.data['success']) {
        return Right(response.data['success']);
      } else {
        errorModel = ErrorModel.fromJson(response.data['message']);
        return Left(errorModel);
      }
    } else {
      // Use regular API without image
      final Response<dynamic>? response =
          await ApiService.patchApi(ApiPaths.BikerCompleteOrder,
              body: {
                'order': orderId,
              },
              isAuth: true);

      if (response!.data['success']) {
        return Right(response.data['success']);
      } else {
        errorModel = ErrorModel.fromJson(response.data['message']);
        return Left(errorModel);
      }
    }
  }

  static Future<Either<ErrorModel, bool>> bikerCancelOrder(
      String orderId) async {
    ErrorModel? errorModel;
    final Response<dynamic>? response = await ApiService.patchApi(
        ApiPaths.BikerCancelOrder,
        body: {'order': orderId},
        isAuth: true);

    if (response!.data['success']) {
      return Right(response.data['success']);
    } else {
      errorModel = ErrorModel.fromJson(response.data['message']);
      return Left(errorModel);
    }
  }

  static Future<GenericResponse<OrderModel>> bikerOrder(String orderId) async {
    final Response<dynamic>? response = await ApiService.getApi(
        "${ApiPaths.bikerOrderDetails}$orderId",
        isAuth: true);

    return GenericResponse(json: response!.data, fromJson: OrderModel.fromJson);
  }
}
