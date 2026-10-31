import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/booking/data/models/apply_promo_code_model.dart';
import 'package:thewasher/modules/booking/data/response/apply_promo_code_response.dart';
import 'package:thewasher/modules/profile/data/models/promo_code_model.dart';
import 'package:thewasher/modules/profile/data/repo/promo_code_repo.dart';
import 'package:thewasher/modules/profile/data/responses/promo_code_response.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/responses/base_response.dart';

part 'promo_event.dart';

part 'promo_state.dart';

class PromoBloc extends Bloc<PromoEvent, PromoState> {
  List<PromoCodeModel> activeList = <PromoCodeModel>[];
  List<PromoCodeModel> expiredList = <PromoCodeModel>[];
  List<PromoCodeModel> usedList = <PromoCodeModel>[];
  TotalPayModel totalPayModel = TotalPayModel();
  String code = '';

  PromoBloc() : super(PromoInitial()) {
    on<GetActivePromo>((GetActivePromo event, Emitter<PromoState> emit) async {
      try {
        debugPrint("Get All Active Promo Code");
        emit(GetActivePromoLoading());
        final PromoCodeResponse response = await PromoCodesRepo.getPromoCodes(
          PromoCodeTypes.active.name.toUpperCase(),
        );
        if (response.success) {
          activeList = <PromoCodeModel>[];
          activeList = response.results!;
          if (activeList.isEmpty) {
            emit(GetActivePromoEmpty());
          } else {
            emit(GetActivePromoSuccess(activeList: activeList));
          }
        } else {
          emit(GetActivePromoError(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetActivePromoError(error: e.toString()));
      }
    });
    on<GetExpiredPromo>((
      GetExpiredPromo event,
      Emitter<PromoState> emit,
    ) async {
      try {
        debugPrint("Get All Expired Promo Code");
        emit(GetExpiredPromoLoading());
        final PromoCodeResponse response = await PromoCodesRepo.getPromoCodes(
          PromoCodeTypes.expired.name.toUpperCase(),
        );
        if (response.success) {
          expiredList = <PromoCodeModel>[];
          expiredList = response.results!;
          if (expiredList.isEmpty) {
            emit(GetExpiredPromoEmpty());
          } else {
            emit(GetExpiredPromoSuccess(expiredList: expiredList));
          }
        } else {
          emit(GetExpiredPromoError(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetExpiredPromoError(error: e.toString()));
      }
    });
    on<GetUsedPromo>((GetUsedPromo event, Emitter<PromoState> emit) async {
      try {
        debugPrint("Get All Used Promo Code");
        emit(GetUsedPromoLoading());
        final PromoCodeResponse response = await PromoCodesRepo.getPromoCodes(
          PromoCodeTypes.used.name.toUpperCase(),
        );
        if (response.success) {
          usedList = <PromoCodeModel>[];
          usedList = response.results!;
          if (usedList.isEmpty) {
            emit(GetUsedPromoEmpty());
          } else {
            emit(GetUsedPromoSuccess(usedList: usedList));
          }
        } else {
          emit(GetUsedPromoError(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetUsedPromoError(error: e.toString()));
      }
    });

    on<ApplyPromoCode>((ApplyPromoCode event, Emitter<PromoState> emit) async {
      try {
        emit(ApplyPromoLoading());
        final ApplyPromoCodeResponse response =
            await PromoCodesRepo.applyPromoCode(
              code: event.code,
              orderId: event.orderId,
            );
        if (response.success) {
          totalPayModel = response.result!;
          code = '';
          emit(ApplyPromoSuccess(totalPayModel: totalPayModel));
        } else {
          emit(ApplyPromoError(errorModel: response.errorModel));
        }
      } catch (e) {
        emit(ApplyPromoError(error: e.toString()));
      }
    });
    on<GetPromoCodeDetail>((
      GetPromoCodeDetail event,
      Emitter<PromoState> emit,
    ) async {
      try {
        emit(GetPromoCodeDetailLoading());
        final NewPromoCodeModel response =
            await PromoCodesRepo.getPromoCodeDetailById(
              promoCode: event.promoCode,
              totalPrice: event.totalPrice,
            );
        // Store the promo code when successfully applied
        code = event.promoCode;
        emit(GetPromoCodeDetailSuccess(promoCodeDetail: response));
      } on DioException catch (e) {
        // Handle DioException to extract error message from response
        if (e.response != null && e.response!.data != null) {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic> &&
              responseData['message'] != null) {
            try {
              final ErrorModel errorModel = ErrorModel.fromJson(
                responseData['message'],
              );
              emit(GetPromoCodeDetailError(errorModel: errorModel));
            } catch (parseError) {
              debugPrint('Error parsing error message: $parseError');
              emit(GetPromoCodeDetailError(error: e.toString()));
            }
          } else {
            emit(GetPromoCodeDetailError(error: e.toString()));
          }
        } else {
          emit(GetPromoCodeDetailError(error: e.toString()));
        }
      } catch (e) {
        emit(GetPromoCodeDetailError(error: e.toString()));
      }
    });
    on<ClearPromoCodeDetail>((
      ClearPromoCodeDetail event,
      Emitter<PromoState> emit,
    ) {
      code = ''; // Clear the stored promo code
      emit(PromoCodeDetailCleared());
    });
  }
}
