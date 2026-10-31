part of 'booking_order_bloc.dart';

class BookingOrderEvent {}

class CreateOrder extends BookingOrderEvent {
  final CreateOrderRequest createOrderRequest;

  CreateOrder({required this.createOrderRequest});
}

class ClearCartOrder extends BookingOrderEvent {}

class CancelOrder extends BookingOrderEvent {
  final String orderId;
  CancelOrder({required this.orderId});
}

class PlaceOrder extends BookingOrderEvent {
  final String orderId;
  final PaymentDetailsRequest? paymentDetailsRequest;
  final String? applePayId;
  PlaceOrder({
    this.applePayId,
    required this.orderId,
    this.paymentDetailsRequest,
  });
}

class GetOrderById extends BookingOrderEvent {
  final String orderId;
  final bool? refresh;

  GetOrderById({required this.orderId, this.refresh = true});
}

class RateOrder extends BookingOrderEvent {
  final String orderId;
  final double starsNum;

  RateOrder({required this.orderId, required this.starsNum});
}

class GetCalenderAvalible extends BookingOrderEvent {
  final String? city;
  final String? area;
  final String? day;
  final String? date;
  GetCalenderAvalible({this.city, this.area, this.day, this.date});
}

class ClearSelectedTimeSlot extends BookingOrderEvent {}
