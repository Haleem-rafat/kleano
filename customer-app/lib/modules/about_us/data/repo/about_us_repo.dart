import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/about_us/data/responses/contact_response.dart';
import 'package:thewasher/utilties/multilingual_helper.dart';

class AboutUsRepo {
  static Future<ContactResponse> getContactDataInfo() async {
    final Response<dynamic>? response = await ApiService.getApi(
      ApiPaths.contactInfo,
      isAuth: false,
    );
    return ContactResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<String?> getTermsAndConditions() async {
    try {
      final Response<dynamic>? response = await ApiService.getApi(
        ApiPaths.termsAndConditions,
        isAuth: false,
      );

      if (response?.statusCode == 404) {
        // Return null for 404 errors to indicate content not found
        return null;
      }

      if (response != null && response.data['data'] != null) {
        final content = response.data['data']['content'];
        return MultilingualHelper.parseMultilingualField(content);
      }
      
      return null;
    } catch (e) {
      // If it's a DioException with 404 status, return null
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      // Re-throw other exceptions
      rethrow;
    }
  }
}
