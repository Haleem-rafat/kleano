part of 'promo_bloc.dart';

abstract class PromoEvent {}

class GetActivePromo extends PromoEvent {}

class GetExpiredPromo extends PromoEvent {}

class GetUsedPromo extends PromoEvent {}

class ApplyPromoCode extends PromoEvent {
  final String orderId;
  final String code;

  ApplyPromoCode({required this.orderId, required this.code});
}

class GetPromoCodeDetail extends PromoEvent {
  final String promoCode;
  final String totalPrice;

  GetPromoCodeDetail({required this.promoCode, required this.totalPrice});
}

class ClearPromoCodeDetail extends PromoEvent {}
