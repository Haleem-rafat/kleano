part of 'promo_bloc.dart';

abstract class PromoState {}

class PromoInitial extends PromoState {}

class GetActivePromoLoading extends PromoState {}

class GetActivePromoSuccess extends PromoState {
  List<PromoCodeModel> activeList;

  GetActivePromoSuccess({required this.activeList});
}

class GetActivePromoEmpty extends PromoState {}

class GetActivePromoError extends PromoState {
  String error;

  GetActivePromoError({required this.error});
}

////////////////////////////////////////////////////

class GetExpiredPromoLoading extends PromoState {}

class GetExpiredPromoSuccess extends PromoState {
  List<PromoCodeModel> expiredList;

  GetExpiredPromoSuccess({required this.expiredList});
}

class GetExpiredPromoEmpty extends PromoState {}

class GetExpiredPromoError extends PromoState {
  String error;

  GetExpiredPromoError({required this.error});
}

////////////////////////////////////////////////////

class GetUsedPromoLoading extends PromoState {}

class GetUsedPromoSuccess extends PromoState {
  List<PromoCodeModel> usedList;

  GetUsedPromoSuccess({required this.usedList});
}

class GetUsedPromoEmpty extends PromoState {}

class GetUsedPromoError extends PromoState {
  String error;

  GetUsedPromoError({required this.error});
}

///////////////////////////////////////!SECTION

class ApplyPromoLoading extends PromoState {}

class ApplyPromoSuccess extends PromoState {
  final TotalPayModel totalPayModel;

  ApplyPromoSuccess({required this.totalPayModel});
}

class ApplyPromoError extends PromoState {
  final String? error;
  final ErrorModel? errorModel;
  ApplyPromoError({this.error, this.errorModel});
}

///////////////////////////////////////!SECTION

class GetPromoCodeDetailLoading extends PromoState {}

class GetPromoCodeDetailSuccess extends PromoState {
  final NewPromoCodeModel promoCodeDetail;

  GetPromoCodeDetailSuccess({required this.promoCodeDetail});
}

class GetPromoCodeDetailError extends PromoState {
  final String? error;
  final ErrorModel? errorModel;

  GetPromoCodeDetailError({this.error, this.errorModel});
}

class PromoCodeDetailCleared extends PromoState {}
