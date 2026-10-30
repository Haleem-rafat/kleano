import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
import 'package:thewasher/modules/booking/data/response/apply_promo_code_response.dart';
import 'package:thewasher/modules/profile/data/responses/promo_code_response.dart';

class PromoCodesRepo {
  static Future<PromoCodeResponse> getPromoCodes(String status) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "${ApiPaths.promoCode}?status=$status",
      isAuth: true,
    );

    return PromoCodeResponse(
      json: response?.data,
      isList: true,
    );
  }

  static Future<ApplyPromoCodeResponse> applyPromoCode({
    required String code,
    required String orderId,
  }) async {
    final Response<dynamic>? response = await ApiService.patchApi(
        ApiPaths.applyPromoCode,
        isAuth: true,
        body: <String, dynamic>{
          'code': code,
          'order': orderId,
        });

    return ApplyPromoCodeResponse(
      statusCode: response!.statusCode!,
      json: response.data,
    );
  }

  static Future<NewPromoCodeModel> getPromoCodeDetailById({
    required String promoCode,
    required String totalPrice,
  }) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "/orders/user/promo-code-discount?promoCode=$promoCode&totalPrice=$totalPrice",
      isAuth: true,
    );
    return NewPromoCodeModel.fromJson(response!.data['data']);
  }
}
