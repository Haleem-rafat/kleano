part of 'booking_order_bloc.dart';

class BookingOrderState {}

class CreateOrderInitial extends BookingOrderState {}

class CreateOrderLoading extends BookingOrderState {}

class CreateOrderSuccess extends BookingOrderState {
  final ReviewOrderModel reviewOrderModel;
  final num? redeemLimit;
  CreateOrderSuccess({required this.reviewOrderModel, this.redeemLimit});
}

class CreateOrderFailed extends BookingOrderState {
  final String? error;
  final ErrorModel? errorModel;
  CreateOrderFailed({this.error, this.errorModel});
}

class CreateOrderConnectionError extends BookingOrderState {}

//////////////////
class ClearCartOrderLoading extends BookingOrderState {}

class ClearCartOrderSuccess extends BookingOrderState {}

class ClearCartOrderFailed extends BookingOrderState {
  final String error;
  ClearCartOrderFailed({required this.error});
}
//////////////////

class CancelOrderLoading extends BookingOrderState {}

class CancelOrderSuccess extends BookingOrderState {
  final bool? comeFromWashDetails;
  CancelOrderSuccess({this.comeFromWashDetails = false});
}

class CancelOrderFailed extends BookingOrderState {
  final ErrorModel? errormodel;
  final String? error;
  CancelOrderFailed({this.error, this.errormodel});
}

//////////////////////!SECTION
class PlaceOrderLoading extends BookingOrderState {}

class PlaceOrderSuccess extends BookingOrderState {
  final String? paymentUrl;
  PlaceOrderSuccess({required this.paymentUrl});
}

class PlaceOrderFailed extends BookingOrderState {
  final ErrorModel? errormodel;
  final String? error;
  PlaceOrderFailed({this.error, this.errormodel});
}

///////

class OrderByIdLoading extends BookingOrderState {}

class OrderByIdSuccess extends BookingOrderState {
  final OrderModel orderModel;
  OrderByIdSuccess({required this.orderModel});
}

class OrderByIdFailed extends BookingOrderState {
  final ErrorModel? errorModel;
  final String? error;
  OrderByIdFailed({this.errorModel, this.error});
}

/////////
class RateOrderLoading extends BookingOrderState {}

class RateOrderSuccess extends BookingOrderState {}

class RateOrderFailed extends BookingOrderState {
  final String? error;
  final ErrorModel? errorModel;

  RateOrderFailed({this.error, this.errorModel});
}

///////// Booking Avalabile
class CalenderAvailableInitial extends BookingOrderState {}

class CalenderAvailableLoading extends BookingOrderState {}

class CalenderAvailableSuccess extends BookingOrderState {
  final List<CalenderAvailableModel> calenderAvailableModel;
  CalenderAvailableSuccess({required this.calenderAvailableModel});
}

class CalenderAvailableFailed extends BookingOrderState {
  final String? error;
  final ErrorModel? errorModel;
  CalenderAvailableFailed({this.error, this.errorModel});
}
