import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/my_vehicles/data/model/car_model.dart';
import 'package:thewasher/modules/my_vehicles/data/response/vehicles_response.dart';
import 'package:thewasher/responses/base_response.dart';

class VehiclesRepo {
  static Future<VehiclesResponse?> getVehicles() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.vehicles,
        isAuth: true,
      );
      if (response != null) {
        return VehiclesResponse(json: response.data, isList: true);
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
    return null;
  }

  static Future<List<String>> getCarModel() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.carModel,
        isAuth: true,
      );
      if (response != null && response.data != null) {
        return (response.data['data'] as List<dynamic>)
            .map((dynamic car) => car.toString())
            .toList();
      }
    } catch (e) {
      print('Error fetching car models: $e');
    }
    return <String>[];
  }

  static Future<Either<ErrorModel, bool>> createNewCar(
    String brand,
    String model,
    String plateNumber,
    String color,
    String? carImage,
  ) async {
    try {
      List<File> files = <File>[];
      List<String> filesName = <String>[];
      if (carImage != null && carImage.isNotEmpty) {
        files.add(File(carImage));
        filesName.add("image");
      }

      final Response<dynamic>? response = await ApiService.postMultiPartApi(
        ApiPaths.createVehicles,
        body: <String, dynamic>{
          "brand": brand,
          "model": model,
          "plateNumber": plateNumber,
          "color": color,
        },
        files: files,
        filesName: filesName,
        isAuth: true,
      );

      if (response != null && response.data['success'] == true) {
        return const Right(true);
      } else if (response != null) {
        final ErrorModel errorModel =
            ErrorModel.fromJson(response.data['message']);
        return Left(errorModel);
      }
    } catch (e) {
      print('Error creating new car: $e');
      // Handle DioException to extract error message from response
      if (e is DioException && e.response != null && e.response!.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          try {
            final ErrorModel errorModel =
                ErrorModel.fromJson(responseData['message']);
            return Left(errorModel);
          } catch (parseError) {
            print('Error parsing error message: $parseError');
          }
        }
      }
    }
    return Left(ErrorModel(en: 'Failed to create car'));
  }

  static Future<Either<ErrorModel, bool>> updateCar(
    String id,
    String brand,
    String model,
    String plateNumber,
    String color,
    String? carImage,
  ) async {
    try {
      List<File> files = <File>[];
      List<String> filesName = <String>[];
      if (carImage != null && carImage.isNotEmpty) {
        files.add(File(carImage));
        filesName.add("image");
      }

      final Response<dynamic>? response = await ApiService.putMultiPartApi(
        "${ApiPaths.createVehicles}/$id",
        body: <String, dynamic>{
          "brand": brand,
          "model": model,
          "plateNumber": plateNumber,
          "color": color,
        },
        files: files,
        filesName: filesName,
        isAuth: true,
      );

      if (response != null && response.data['success'] == true) {
        return const Right(true);
      } else if (response != null) {
        final ErrorModel errorModel =
            ErrorModel.fromJson(response.data['message']);
        return Left(errorModel);
      }
    } catch (e) {
      print('Error updating car: $e');
      // Handle DioException to extract error message from response
      if (e is DioException && e.response != null && e.response!.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          try {
            final ErrorModel errorModel =
                ErrorModel.fromJson(responseData['message']);
            return Left(errorModel);
          } catch (parseError) {
            print('Error parsing error message: $parseError');
          }
        }
      }
    }
    return Left(ErrorModel(en: 'Failed to update car'));
  }

  static Future<bool> deleteCar(String id) async {
    try {
      final Response<dynamic>? response = await ApiService.deleteApi(
        "${ApiPaths.createVehicles}/$id",
        isAuth: true,
      );
      if (response != null && response.data['success'] == true) {
        return true;
      }
    } catch (e) {
      print('Error deleting car: $e');
    }
    return false;
  }

  static Future<List<CarBrandsModel>> getCarBrands() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.cars,
        isAuth: false,
      );
      if (response != null && response.data != null) {
        return (response.data['data'] as List)
            .map((item) => CarBrandsModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error fetching car brands: $e');
    }
    return <CarBrandsModel>[];
  }

  static Future<List<String>> getCarModelsByBrandId(
      {required String brandId}) async {
    final Response<dynamic>? response = await ApiService.getApi(
      '${ApiPaths.cars}/$brandId',
      isAuth: false,
    );
    final List<dynamic>? models = response?.data?['data']['models'];
    if (models != null) {
      return models.cast<String>().toList();
    }
    return <String>[];
  }
}
