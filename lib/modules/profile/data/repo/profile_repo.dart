import 'dart:io';

import 'package:dio/dio.dart';
import 'package:thewhsherbiker/api/api_path.dart';
import 'package:thewhsherbiker/api/api_service.dart';
import 'package:thewhsherbiker/modules/profile/data/model/biker_schedule_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/responses/base_response.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';

class ProfileRepo {
  static Future<GenericResponse> bikerProfile() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.bikers,
      );

      if (response != null && response.data != null) {
        return GenericResponse(
          json: response.data,
          fromJson: ProfileModel.fromJson,
        );
      }
    } catch (e) {
      print('Error in bikerProfile: $e');
    }

    return GenericResponse(fromJson: ProfileModel.fromJson);
  }

  static Future<bool> bikerUpdateStatus(String status) async {
    try {
      final Response<dynamic>? response = await ApiService.patchApi(
        ApiPaths.updateStatus,
        body: <String, dynamic>{
          'status': status,
        },
        isAuth: true,
      );
      if (response != null && response.data != null) {
        return response.data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in bikerUpdateStatus: $e');
      return false;
    }
  }

  static Future<bool> bikerProfileEdit(String name, String? image) async {
    try {
      List<File> files = <File>[];
      List<String> filesName = <String>[];

      if (image != null && image.isNotEmpty) {
        files.add(File(image));
        filesName.add("image");
      }

      final Response<dynamic>? response = await ApiService.putMultiPartApi(
        ApiPaths.updateInfo,
        body: <String, dynamic>{
          'userName': name,
        },
        files: files,
        filesName: filesName,
        isAuth: true,
      );

      if (response != null && response.data != null) {
        return response.data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in bikerProfileEdit: $e');
      return false;
    }
  }

  static Future<BaseResponse> updateBikerLanguage(
      {required String language}) async {
    try {
      final Response<dynamic>? response = await ApiService.patchApi(
        ApiPaths.updatelanguage,
        body: <String, dynamic>{'language': language},
        isAuth: true,
      );
      if (response != null &&
          response.statusCode != null &&
          response.data != null) {
        return BaseResponse(
          statusCode: response.statusCode!,
          json: response.data,
        );
      }
    } catch (e) {
      print('Error in updateBikerLanguage: $e');
    }

    return BaseResponse(statusCode: 400);
  }

  static Future<int> getTotalWashes({required String status}) async {
    var response = await ApiService.getApi(
      "/orders/biker/total-orders?status=$status",
      isAuth: true,
    );
    return response?.data['data'] ?? 0;
  }

  static Future<TotalCommissionModel?> getTotalCommission() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.bikerTotalCommission,
        isAuth: true,
      );

      if (response != null &&
          response.data != null &&
          response.data['success'] == true) {
        return TotalCommissionModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Error in getTotalCommission: $e');
    }
    return null;
  }

  static Future<BikerScheduleModel?> getBikerSchedule() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.bikerSchedule,
        isAuth: true,
      );

      if (response != null &&
          response.data != null &&
          response.data['success'] == true) {
        return BikerScheduleModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Error in getBikerSchedule: $e');
    }
    return null;
  }
}
